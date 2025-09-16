#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# enforce-verification.sh - Enable mandatory verification for Broadsage images
# This script helps organizations implement different levels of verification enforcement

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] <enforcement-level>

Enable different levels of image verification enforcement for Broadsage containers.

ENFORCEMENT LEVELS:
  docker-trust      Enable Docker Content Trust (signatures required)
  k8s-policy        Deploy Kubernetes admission controller policy  
  ci-pipeline       Generate CI/CD pipeline verification templates
  disable           Disable all enforcement mechanisms

OPTIONS:
  -h, --help        Show this help message
  -n, --dry-run     Show what would be done without making changes
  -f, --force       Skip confirmation prompts
  --namespace NS    Kubernetes namespace for policy (default: default)

EXAMPLES:
  # Enable Docker Content Trust
  $0 docker-trust

  # Deploy Kubernetes policy enforcement
  $0 k8s-policy --namespace production

  # Generate CI/CD templates
  $0 ci-pipeline

  # Dry run to see what would happen
  $0 --dry-run k8s-policy

  # Disable all enforcement
  $0 disable
EOF
}

enable_docker_trust() {
  local dry_run="$1"

  log_info "Enabling Docker Content Trust..."

  if [[ "$dry_run" == "true" ]]; then
    echo "Would execute: export DOCKER_CONTENT_TRUST=1"
    echo "Would add to ~/.bashrc: export DOCKER_CONTENT_TRUST=1"
    return 0
  fi

  # Add to current session
  export DOCKER_CONTENT_TRUST=1

  # Add to shell profile
  local shell_profile
  if [[ -f "$HOME/.bashrc" ]]; then
    shell_profile="$HOME/.bashrc"
  elif [[ -f "$HOME/.zshrc" ]]; then
    shell_profile="$HOME/.zshrc"
  else
    shell_profile="$HOME/.profile"
  fi

  if ! grep -q "DOCKER_CONTENT_TRUST=1" "$shell_profile" 2>/dev/null; then
    {
      echo ""
      echo "# Enable Docker Content Trust for Broadsage containers"
      echo "export DOCKER_CONTENT_TRUST=1"
    } >>"$shell_profile"
    log_success "Added DOCKER_CONTENT_TRUST=1 to $shell_profile"
  else
    log_warning "DOCKER_CONTENT_TRUST already enabled in $shell_profile"
  fi

  log_success "Docker Content Trust enabled"
  log_info "Note: This requires signed images. Broadsage images are signed, but other images may fail."
}

deploy_k8s_policy() {
  local dry_run="$1"
  local namespace="$2"

  log_info "Deploying Kubernetes admission controller policy..."

  # Check if kubectl is available
  if ! command -v kubectl >/dev/null 2>&1; then
    log_error "kubectl is not installed or not in PATH"
    return 1
  fi

  # Check if cluster is accessible
  if ! kubectl cluster-info >/dev/null 2>&1; then
    log_error "Cannot access Kubernetes cluster. Check your kubeconfig."
    return 1
  fi

  if [[ "$dry_run" == "true" ]]; then
    echo "Would execute:"
    echo "  kubectl apply -f https://github.com/sigstore/policy-controller/releases/latest/download/policy-controller.yaml"
    echo "  kubectl apply -f $PROJECT_DIR/.cosign/consumer-policy.yaml -n $namespace"
    return 0
  fi

  # Install Cosign Policy Controller
  log_info "Installing Cosign Policy Controller..."
  if kubectl apply -f https://github.com/sigstore/policy-controller/releases/latest/download/policy-controller.yaml; then
    log_success "Policy Controller installed"
  else
    log_error "Failed to install Policy Controller"
    return 1
  fi

  # Wait for policy controller to be ready
  log_info "Waiting for Policy Controller to be ready..."
  kubectl wait --for=condition=available deployment/policy-controller -n cosign-system --timeout=300s

  # Apply Broadsage policy
  log_info "Applying Broadsage verification policy..."
  if kubectl apply -f "$PROJECT_DIR/.cosign/consumer-policy.yaml" -n "$namespace"; then
    log_success "Broadsage verification policy applied to namespace: $namespace"
  else
    log_error "Failed to apply Broadsage verification policy"
    return 1
  fi

  # Test the policy
  log_info "Testing policy enforcement..."

  # This should fail (unsigned image)
  if kubectl run test-unsigned --image=nginx:latest --dry-run=server -n "$namespace" >/dev/null 2>&1; then
    log_warning "Policy may not be working - unsigned image was allowed"
  else
    log_success "Policy working - unsigned images are blocked"
  fi

  # Clean up test
  kubectl delete pod test-unsigned -n "$namespace" >/dev/null 2>&1 || true

  log_success "Kubernetes policy enforcement deployed"
  log_info "Only signed Broadsage images will be allowed in namespace: $namespace"
}

generate_ci_templates() {
  local dry_run="$1"
  local output_dir="$PROJECT_DIR/templates"

  log_info "Generating CI/CD pipeline verification templates..."

  if [[ "$dry_run" == "true" ]]; then
    echo "Would create templates in: $output_dir"
    return 0
  fi

  mkdir -p "$output_dir"

  # GitHub Actions template
  cat >"$output_dir/github-actions-verification.yml" <<'EOF'
# GitHub Actions template for mandatory image verification
# Add this to your .github/workflows/deploy.yml

name: Deploy with Image Verification
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      # MANDATORY: Verify all Broadsage images before deployment
      - name: Verify Broadsage images
        env:
          COSIGN_EXPERIMENTAL: 1
        run: |
          # Extract images from docker-compose.yml or deployment files
          IMAGES=$(grep -r "ghcr.io/broadsage" . --include="*.yml" --include="*.yaml" | 
                   grep -o "ghcr.io/broadsage/[^[:space:]]*" | sort -u)
          
          echo "Found Broadsage images:"
          echo "$IMAGES"
          
          # Verify each image
          for image in $IMAGES; do
            echo "🔍 Verifying: $image"
            cosign verify "$image" \
              --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
              --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
            echo "✅ Verified: $image"
          done
          
          echo "🎉 All images verified successfully"
      
      # Only deploy if verification passes
      - name: Deploy application
        if: success()
        run: |
          # Your deployment commands here
          # kubectl apply -f deployment.yaml
          # docker-compose up -d
          echo "Deploying verified images..."
EOF

  # GitLab CI template
  cat >"$output_dir/gitlab-ci-verification.yml" <<'EOF'
# GitLab CI template for mandatory image verification
# Add this to your .gitlab-ci.yml

stages:
  - verify
  - deploy

variables:
  COSIGN_EXPERIMENTAL: "1"

verify_images:
  stage: verify
  image: gcr.io/projectsigstore/cosign:v2.2.1
  script:
    - echo "🔍 Verifying Broadsage container images..."
    # Extract images from deployment files
    - IMAGES=$(grep -r "ghcr.io/broadsage" . --include="*.yml" --include="*.yaml" | grep -o "ghcr.io/broadsage/[^[:space:]]*" | sort -u)
    - echo "Found images:"
    - echo "$IMAGES"
    # Verify each image
    - |
      for image in $IMAGES; do
        echo "🔍 Verifying: $image"
        cosign verify "$image" \
          --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
          --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
        echo "✅ Verified: $image"
      done
    - echo "🎉 All images verified successfully"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

deploy:
  stage: deploy
  dependencies:
    - verify_images
  script:
    - echo "Deploying verified images..."
    # Your deployment commands here
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
EOF

  # Docker Compose template with verification
  cat >"$output_dir/docker-compose.verified.yml" <<'EOF'
# Docker Compose template with mandatory verification
# Use this instead of regular docker-compose.yml for verified deployments

version: '3.8'

services:
  # Verification service - runs first and verifies all Broadsage images
  verify-images:
    image: gcr.io/projectsigstore/cosign:v2.2.1
    environment:
      - COSIGN_EXPERIMENTAL=1
    command: >
      sh -c "
        echo '🔍 Verifying all Broadsage images before deployment...' &&
        
        # Verify each image used in this compose file
        cosign verify ghcr.io/broadsage/nginx:latest \
          --certificate-identity='https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main' \
          --certificate-oidc-issuer='https://token.actions.githubusercontent.com' &&
        
        # Add more images as needed
        # cosign verify ghcr.io/broadsage/redis:latest \
        #   --certificate-identity='https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main' \
        #   --certificate-oidc-issuer='https://token.actions.githubusercontent.com' &&
        
        echo '✅ All images verified successfully'
      "
    restart: "no"  # Only run once
    
  # Your application services - depend on verification
  nginx:
    image: ghcr.io/broadsage/nginx:latest
    ports:
      - "80:80"
    depends_on:
      verify-images:
        condition: service_completed_successfully
        
  # Add more services as needed
  # redis:
  #   image: ghcr.io/broadsage/redis:latest
  #   depends_on:
  #     verify-images:
  #       condition: service_completed_successfully
EOF

  # Jenkins pipeline template
  cat >"$output_dir/jenkins-verification.groovy" <<'EOF'
// Jenkins pipeline template for mandatory image verification

pipeline {
    agent any
    
    environment {
        COSIGN_EXPERIMENTAL = "1"
    }
    
    stages {
        stage('Verify Images') {
            steps {
                script {
                    echo '🔍 Verifying Broadsage container images...'
                    
                    // Extract images from deployment files
                    def images = sh(
                        script: 'grep -r "ghcr.io/broadsage" . --include="*.yml" --include="*.yaml" | grep -o "ghcr.io/broadsage/[^[:space:]]*" | sort -u',
                        returnStdout: true
                    ).trim().split('\n')
                    
                    echo "Found images: ${images}"
                    
                    // Verify each image
                    for (image in images) {
                        echo "🔍 Verifying: ${image}"
                        sh """
                            cosign verify "${image}" \
                              --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
                              --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
                        """
                        echo "✅ Verified: ${image}"
                    }
                    
                    echo '🎉 All images verified successfully'
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying verified images...'
                // Your deployment commands here
            }
        }
    }
    
    post {
        failure {
            echo '❌ Image verification or deployment failed'
        }
        success {
            echo '✅ Verified deployment completed successfully'
        }
    }
}
EOF

  log_success "CI/CD templates generated in: $output_dir"
  log_info "Available templates:"
  echo "  - GitHub Actions: $output_dir/github-actions-verification.yml"
  echo "  - GitLab CI: $output_dir/gitlab-ci-verification.yml"
  echo "  - Docker Compose: $output_dir/docker-compose.verified.yml"
  echo "  - Jenkins: $output_dir/jenkins-verification.groovy"
}

disable_enforcement() {
  local dry_run="$1"

  log_info "Disabling verification enforcement..."

  if [[ "$dry_run" == "true" ]]; then
    echo "Would remove DOCKER_CONTENT_TRUST from shell profiles"
    echo "Would remove Kubernetes policies"
    return 0
  fi

  # Remove Docker Content Trust from shell profiles
  for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [[ -f "$profile" ]] && grep -q "DOCKER_CONTENT_TRUST" "$profile"; then
      sed -i.bak '/DOCKER_CONTENT_TRUST/d' "$profile"
      log_success "Removed DOCKER_CONTENT_TRUST from $profile"
    fi
  done

  # Unset in current session
  unset DOCKER_CONTENT_TRUST

  # Remove Kubernetes policies (if kubectl is available)
  if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
    log_info "Removing Kubernetes verification policies..."
    kubectl delete clusterimagepolicy broadsage-consumer-policy >/dev/null 2>&1 || true
    log_success "Kubernetes policies removed"
  fi

  log_success "Verification enforcement disabled"
  log_warning "Images can now be used without verification"
}

main() {
  local enforcement_level=""
  local dry_run="false"
  local force="false"
  local namespace="default"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      usage
      exit 0
      ;;
    -n | --dry-run)
      dry_run="true"
      shift
      ;;
    -f | --force)
      force="true"
      shift
      ;;
    --namespace)
      namespace="$2"
      shift 2
      ;;
    docker-trust | k8s-policy | ci-pipeline | disable)
      if [[ -z "$enforcement_level" ]]; then
        enforcement_level="$1"
      else
        log_error "Multiple enforcement levels specified"
        exit 2
      fi
      shift
      ;;
    -*)
      log_error "Unknown option: $1"
      usage
      exit 2
      ;;
    *)
      log_error "Unknown argument: $1"
      usage
      exit 2
      ;;
    esac
  done

  # Validate required arguments
  if [[ -z "$enforcement_level" ]]; then
    log_error "No enforcement level specified"
    usage
    exit 2
  fi

  # Confirmation prompt (unless forced or dry-run)
  if [[ "$force" != "true" && "$dry_run" != "true" ]]; then
    echo -n "Enable '$enforcement_level' verification enforcement? [y/N]: "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_info "Operation cancelled"
      exit 0
    fi
  fi

  # Header
  echo "🔐 Broadsage Image Verification Enforcement"
  echo "=========================================="
  echo "Level: $enforcement_level"
  echo "Mode: $([ "$dry_run" == "true" ] && echo "Dry Run" || echo "Execute")"
  echo ""

  # Execute based on enforcement level
  case "$enforcement_level" in
  docker-trust)
    enable_docker_trust "$dry_run"
    ;;
  k8s-policy)
    deploy_k8s_policy "$dry_run" "$namespace"
    ;;
  ci-pipeline)
    generate_ci_templates "$dry_run"
    ;;
  disable)
    disable_enforcement "$dry_run"
    ;;
  *)
    log_error "Unknown enforcement level: $enforcement_level"
    exit 2
    ;;
  esac

  echo ""
  log_success "Enforcement configuration complete!"

  if [[ "$dry_run" == "true" ]]; then
    log_info "This was a dry run. No changes were made."
    log_info "Run without --dry-run to apply changes."
  fi
}

# Run main function
main "$@"
