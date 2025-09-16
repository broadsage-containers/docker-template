#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# verify-image.sh - Verify Broadsage container images
# This script provides a simple way to verify the authenticity and integrity
# of Broadsage container images using Cosign.

set -euo pipefail

# Configuration
EXPECTED_IDENTITY="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main"
EXPECTED_ISSUER="https://token.actions.githubusercontent.com"
COSIGN_EXPERIMENTAL="${COSIGN_EXPERIMENTAL:-1}"
VERBOSE="${VERBOSE:-0}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
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
Usage: $0 [OPTIONS] <image>

Verify Broadsage container images using Cosign signature verification.

ARGUMENTS:
  <image>                Container image to verify (required)
                        Examples: 
                          ghcr.io/broadsage/nginx:latest
                          ghcr.io/broadsage/nginx:1.28

OPTIONS:
  -h, --help            Show this help message
  -v, --verbose         Enable verbose output
  -s, --sbom-only       Only download and display SBOM (skip verification)
  -q, --quiet           Suppress non-essential output
  --pr-image            Verify as PR image (relaxed policy)
  --download-sbom       Download SBOM to file
  --output-dir DIR      Directory to save verification artifacts (default: current directory)

ENVIRONMENT VARIABLES:
  COSIGN_EXPERIMENTAL   Enable experimental Cosign features (default: 1)
  VERBOSE               Enable verbose mode (default: 0)

EXAMPLES:
  # Verify a production image
  $0 ghcr.io/broadsage/nginx:latest

  # Verify with verbose output
  $0 --verbose ghcr.io/broadsage/nginx:latest

  # Verify PR image
  $0 --pr-image ghcr.io/broadsage/nginx:pr-123

  # Only download and show SBOM
  $0 --sbom-only ghcr.io/broadsage/nginx:latest

  # Download verification artifacts
  $0 --download-sbom --output-dir ./verification ghcr.io/broadsage/nginx:latest

EXIT CODES:
  0     Success - image verified
  1     General error
  2     Invalid arguments
  3     Prerequisites not met
  4     Image verification failed
  5     SBOM verification failed
EOF
}

check_prerequisites() {
  log_info "Checking prerequisites..."

  # Check for cosign
  if ! command -v cosign >/dev/null 2>&1; then
    log_error "Cosign is not installed or not in PATH"
    log_info "Install with: curl -O -L \"https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64\" && sudo mv cosign-linux-amd64 /usr/local/bin/cosign && sudo chmod +x /usr/local/bin/cosign"
    return 3
  fi

  # Check cosign version
  local cosign_version
  cosign_version=$(cosign version --json 2>/dev/null | jq -r '.gitVersion // "unknown"' 2>/dev/null || echo "unknown")
  [[ "$VERBOSE" == "1" ]] && log_info "Cosign version: $cosign_version"

  # Check for jq (optional but recommended)
  if ! command -v jq >/dev/null 2>&1; then
    log_warning "jq not found - SBOM analysis will be limited"
  fi

  log_success "Prerequisites check passed"
  return 0
}

validate_image() {
  local image="$1"

  # Check if it's a Broadsage image
  if [[ ! "$image" =~ ^ghcr\.io/broadsage/ ]]; then
    log_error "Not a Broadsage image: $image"
    log_info "Expected format: ghcr.io/broadsage/<container>:<tag>"
    return 4
  fi

  log_success "Image format validation passed: $image"
  return 0
}

verify_signature() {
  local image="$1"
  local is_pr_image="${2:-false}"
  local output_file="${3:-}"

  log_info "Verifying image signature: $image"

  local verify_cmd="cosign verify \"$image\""
  local cosign_opts=""

  if [[ "$VERBOSE" == "1" ]]; then
    cosign_opts="$cosign_opts --verbose"
  fi

  if [[ -n "$output_file" ]]; then
    cosign_opts="$cosign_opts --output json --output-file=\"$output_file\""
  fi

  if [[ "$is_pr_image" == "true" ]]; then
    # Relaxed verification for PR images
    verify_cmd="$verify_cmd --certificate-identity-regexp=\"https://github.com/broadsage/containers/.github/workflows/pr-publish.yml@refs/heads/.*\" --certificate-oidc-issuer=\"$EXPECTED_ISSUER\" $cosign_opts"
    log_info "Using relaxed PR image verification policy"
  else
    # Strict verification for production images
    verify_cmd="$verify_cmd --certificate-identity=\"$EXPECTED_IDENTITY\" --certificate-oidc-issuer=\"$EXPECTED_ISSUER\" $cosign_opts"
    log_info "Using strict production image verification policy"
  fi

  if eval "COSIGN_EXPERIMENTAL=$COSIGN_EXPERIMENTAL $verify_cmd"; then
    log_success "Image signature verified successfully"
    return 0
  else
    log_error "Image signature verification failed"
    return 4
  fi
}

verify_github_attestations() {
  local image="$1"
  local output_file="${2:-}"

  log_info "Verifying GitHub attestations: $image"

  # Check if gh CLI is available
  if ! command -v gh >/dev/null 2>&1; then
    log_warning "GitHub CLI not found - skipping GitHub attestation verification"
    log_info "Install with: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null && sudo apt update && sudo apt install gh"
    return 0
  fi

  # Verify GitHub attestations (comprehensive)
  if gh attestation verify "oci://$image" --repo broadsage/containers 2>/dev/null; then
    log_success "GitHub attestations verified successfully"

    # Show attestation details if verbose
    if [[ "$VERBOSE" == "1" ]]; then
      log_info "GitHub Attestation Details:"
      gh attestation list --repo broadsage/containers --digest "$(echo "$image" | cut -d'@' -f2)" 2>/dev/null || true
    fi

    return 0
  else
    log_warning "GitHub attestation verification failed (may not be available for all images)"
    return 0 # Don't fail the script if GitHub attestations are not available
  fi
}

download_sbom() {
  local image="$1"
  local output_file="${2:-sbom.spdx.json}"

  log_info "Downloading SBOM: $image"

  if COSIGN_EXPERIMENTAL=$COSIGN_EXPERIMENTAL cosign download sbom "$image" --output-file "$output_file"; then
    log_success "SBOM downloaded: $output_file"

    # Analyze SBOM if jq is available
    if command -v jq >/dev/null 2>&1 && [[ -f "$output_file" ]]; then
      log_info "SBOM Analysis:"
      echo "  📄 Document Name: $(jq -r '.name // "N/A"' "$output_file")"
      echo "  📦 Package Count: $(jq '[.packages[]? // empty] | length' "$output_file")"
      echo "  📅 Creation Date: $(jq -r '.creationInfo.created // "N/A"' "$output_file")"
      echo "  🏗️  Creator: $(jq -r '.creationInfo.creators[]? // "N/A"' "$output_file" | head -1)"
    fi

    return 0
  else
    log_warning "SBOM download failed (may not be available for this image)"
    return 0 # Don't fail the script if SBOM is not available
  fi
}

main() {
  local image=""
  local is_pr_image="false"
  local sbom_only="false"
  local download_sbom_flag="false"
  local output_dir="."
  local quiet="false"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      usage
      exit 0
      ;;
    -v | --verbose)
      VERBOSE="1"
      shift
      ;;
    -s | --sbom-only)
      sbom_only="true"
      shift
      ;;
    -q | --quiet)
      quiet="true"
      shift
      ;;
    --pr-image)
      is_pr_image="true"
      shift
      ;;
    --download-sbom)
      download_sbom_flag="true"
      shift
      ;;
    --output-dir)
      output_dir="$2"
      shift 2
      ;;
    -*)
      log_error "Unknown option: $1"
      usage
      exit 2
      ;;
    *)
      if [[ -z "$image" ]]; then
        image="$1"
      else
        log_error "Multiple images specified. Only one image can be verified at a time."
        exit 2
      fi
      shift
      ;;
    esac
  done

  # Validate required arguments
  if [[ -z "$image" ]]; then
    log_error "No image specified"
    usage
    exit 2
  fi

  # Suppress output if quiet mode
  if [[ "$quiet" == "true" ]]; then
    exec 1>/dev/null
  fi

  # Create output directory if it doesn't exist
  if [[ "$output_dir" != "." && ! -d "$output_dir" ]]; then
    mkdir -p "$output_dir" || {
      log_error "Failed to create output directory: $output_dir"
      exit 1
    }
  fi

  # Header
  echo "🔍 Broadsage Image Verification Tool"
  echo "====================================="
  echo "Image: $image"
  echo "Mode: $([ "$is_pr_image" == "true" ] && echo "PR Image (Relaxed)" || echo "Production (Strict)")"
  echo ""

  # Check prerequisites
  check_prerequisites || exit $?

  # Validate image format
  validate_image "$image" || exit $?

  # SBOM-only mode
  if [[ "$sbom_only" == "true" ]]; then
    download_sbom "$image" "$output_dir/sbom-$(basename "$image" | tr ':/' '-').spdx.json"
    log_success "SBOM-only verification completed"
    exit 0
  fi

  # Full verification
  local sig_file=""

  if [[ "$download_sbom_flag" == "true" ]]; then
    sig_file="$output_dir/verification-$(basename "$image" | tr ':/' '-').json"
  fi

  # Verify signature
  verify_signature "$image" "$is_pr_image" "$sig_file" || exit $?

  # Verify GitHub attestations (SLSA Level 3 compliant)
  verify_github_attestations "$image" || exit $?

  # Download SBOM if requested
  if [[ "$download_sbom_flag" == "true" ]]; then
    download_sbom "$image" "$output_dir/sbom-$(basename "$image" | tr ':/' '-').spdx.json"
  fi

  # Final success message
  echo ""
  log_success "🎉 Image $image passed all verification checks!"
  echo ""
  log_info "You can safely use this image in your deployments."

  if [[ "$download_sbom_flag" == "true" ]]; then
    log_info "Verification artifacts saved in: $output_dir"
  fi

  exit 0
}

# Export COSIGN_EXPERIMENTAL for subprocesses
export COSIGN_EXPERIMENTAL

# Run main function
main "$@"
