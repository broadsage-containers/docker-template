<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Image Verification Guide

This guide explains how to verify Broadsage container images using Cosign and other security tools to ensure image integrity and authenticity before deployment.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Verification Methods](#verification-methods)
- [Production Deployment](#production-deployment)
- [Policy-Based Verification](#policy-based-verification)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Basic Verification

For quick verification of any Broadsage container image:

```bash
# Install Cosign (if not already installed)
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# Verify a production image
cosign verify ghcr.io/broadsage/nginx:latest \
  --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

### Download and Inspect SBOM

```bash
# Download Software Bill of Materials
cosign download sbom ghcr.io/broadsage/nginx:latest > nginx-sbom.spdx.json

# View SBOM summary
jq -r '.packages[] | "\(.name): \(.versionInfo)"' nginx-sbom.spdx.json | head -20
```

## Prerequisites

### Required Tools

```bash
# Cosign for signature verification
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# jq for JSON processing (optional but recommended)
sudo apt-get update && sudo apt-get install -y jq  # Debian/Ubuntu
# or
brew install jq  # macOS
```

### Container Runtime

Any OCI-compatible container runtime:

- Docker
- Podman
- containerd
- CRI-O

## Verification Methods

### 1. Production Images (Strict Verification)

Production images are built from the `main` branch and have strict signing requirements:

```bash
IMAGE="ghcr.io/broadsage/nginx:latest"
EXPECTED_IDENTITY="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main"
EXPECTED_ISSUER="https://token.actions.githubusercontent.com"

# Verify signature
echo "🔍 Verifying production image: $IMAGE"
cosign verify "$IMAGE" \
  --certificate-identity="$EXPECTED_IDENTITY" \
  --certificate-oidc-issuer="$EXPECTED_ISSUER"

echo "✅ Signature verification passed"
```

### 2. Verify SBOM Attestation

```bash
IMAGE="ghcr.io/broadsage/nginx:latest"
EXPECTED_IDENTITY="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main"
EXPECTED_ISSUER="https://token.actions.githubusercontent.com"

# Verify SBOM attestation
cosign verify-attestation "$IMAGE" \
  --certificate-identity="$EXPECTED_IDENTITY" \
  --certificate-oidc-issuer="$EXPECTED_ISSUER" \
  --type=spdxjson

echo "✅ SBOM attestation verified"
```

### 3. Verify Build Provenance

```bash
IMAGE="ghcr.io/broadsage/nginx:latest"

# Download and verify build provenance
cosign verify-attestation "$IMAGE" \
  --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  --type=slsaprovenance | jq .
```

### 4. PR Images (Development/Testing)

PR images have relaxed verification for development environments:

```bash
PR_IMAGE="ghcr.io/broadsage/nginx:pr-123"

# Verify PR image (allows any branch)
cosign verify "$PR_IMAGE" \
  --certificate-identity-regexp="https://github.com/broadsage/containers/.github/workflows/pr-publish.yml@refs/heads/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

## Production Deployment

### Docker Compose with Verification

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  nginx:
    image: ghcr.io/broadsage/nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    # Add init container to verify image before starting
    depends_on:
      - verify-nginx

  verify-nginx:
    image: gcr.io/projectsigstore/cosign:v2.2.1
    command: >
      sh -c "
        cosign verify ghcr.io/broadsage/nginx:latest \
          --certificate-identity='https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main' \
          --certificate-oidc-issuer='https://token.actions.githubusercontent.com' &&
        echo '✅ Image verification passed'
      "
    restart: "no"
```

### Kubernetes Deployment

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
      annotations:
        # Add verification annotations
        cosign.sigstore.dev/verified: "true"
        broadsage.com/image-verified: "true"
    spec:
      initContainers:
      - name: verify-image
        image: gcr.io/projectsigstore/cosign:v2.2.1
        command:
        - sh
        - -c
        - |
          cosign verify ghcr.io/broadsage/nginx:latest \
            --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
            --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
          echo "✅ Image verification passed"
      containers:
      - name: nginx
        image: ghcr.io/broadsage/nginx:latest
        ports:
        - containerPort: 80
        - containerPort: 443
```

## Policy-Based Verification

### Using Cosign Policy Controller

1. **Install the Policy Controller in your Kubernetes cluster:**

```bash
kubectl apply -f https://github.com/sigstore/policy-controller/releases/latest/download/policy-controller.yaml
```

1. **Apply the Broadsage verification policy:**

```bash
# Download the consumer policy
curl -o broadsage-policy.yaml https://raw.githubusercontent.com/broadsage/containers/main/.cosign/consumer-policy.yaml

# Apply to your cluster
kubectl apply -f broadsage-policy.yaml
```

1. **Test policy enforcement:**

```bash
# This should succeed (signed image)
kubectl run test-nginx --image=ghcr.io/broadsage/nginx:latest

# This should fail (unsigned image)
kubectl run test-bad --image=nginx:latest
```

### OPA Gatekeeper Integration

```yaml
# gatekeeper-constraint.yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: broadsageimagesonly
spec:
  crd:
    spec:
      names:
        kind: BroadsageImagesOnly
      validation:
        type: object
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package broadsageimagesonly
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not startswith(container.image, "ghcr.io/broadsage/")
          msg := sprintf("Only Broadsage images are allowed, got: %v", [container.image])
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: BroadsageImagesOnly
metadata:
  name: must-use-broadsage-images
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment", "StatefulSet", "DaemonSet"]
      - apiGroups: [""]
        kinds: ["Pod"]
```

## Troubleshooting

### Common Issues

#### 1. Signature Verification Failed

```bash
Error: verifying signature: getting signature manifest: GET https://index.docker.io/v2/.../signatures/...: MANIFEST_UNKNOWN
```

**Solution:** Ensure you're using the correct registry and image name:

```bash
# Correct - use ghcr.io
cosign verify ghcr.io/broadsage/nginx:latest

# Incorrect - docker.io doesn't have our signatures yet
cosign verify broadsage/nginx:latest
```

#### 2. Certificate Identity Mismatch

```bash
Error: none of the expected identities matched what was in the certificate
```

**Solution:** Use the exact identity for production images:

```bash
cosign verify ghcr.io/broadsage/nginx:latest \
  --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

#### 3. Network Connectivity Issues

```bash
Error: getting signature manifest: Get "https://rekor.sigstore.dev/...": dial tcp: lookup rekor.sigstore.dev
```

**Solution:** Ensure your environment can access Sigstore infrastructure:

```bash
# Test connectivity
curl -I https://fulcio.sigstore.dev
curl -I https://rekor.sigstore.dev
```

### Debugging Commands

#### Inspect Image Signatures

```bash
# List all signatures for an image
cosign tree ghcr.io/broadsage/nginx:latest

# Download raw signature data
cosign download signature ghcr.io/broadsage/nginx:latest
```

#### Verify with Verbose Output

```bash
# Enable verbose logging
export COSIGN_VERBOSE=1
cosign verify ghcr.io/broadsage/nginx:latest \
  --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

#### Check Image Metadata

```bash
# Inspect image labels and annotations
docker inspect ghcr.io/broadsage/nginx:latest | jq '.[0].Config.Labels'

# Check for signing annotations
cosign verify ghcr.io/broadsage/nginx:latest \
  --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  --output json | jq '.[] | .optional.Bundle.Payload | @base64d | fromjson'
```

## Advanced Usage

### Custom Verification Script

```bash
#!/bin/bash
# verify-image.sh

set -euo pipefail

IMAGE="${1:-}"
if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image>"
  echo "Example: $0 ghcr.io/broadsage/nginx:latest"
  exit 1
fi

EXPECTED_IDENTITY="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main"
EXPECTED_ISSUER="https://token.actions.githubusercontent.com"

echo "🔍 Verifying Broadsage image: $IMAGE"

# Check if it's a Broadsage image
if [[ ! "$IMAGE" =~ ^ghcr\.io/broadsage/ ]]; then
  echo "❌ Not a Broadsage image: $IMAGE"
  exit 1
fi

# Verify signature
echo "🔑 Verifying signature..."
cosign verify "$IMAGE" \
  --certificate-identity="$EXPECTED_IDENTITY" \
  --certificate-oidc-issuer="$EXPECTED_ISSUER" \
  --output json > verification.json

echo "✅ Signature verified"

# Verify SBOM attestation
echo "📋 Verifying SBOM attestation..."
cosign verify-attestation "$IMAGE" \
  --certificate-identity="$EXPECTED_IDENTITY" \
  --certificate-oidc-issuer="$EXPECTED_ISSUER" \
  --type=spdxjson > sbom-attestation.json

echo "✅ SBOM attestation verified"

# Download SBOM
echo "📥 Downloading SBOM..."
cosign download sbom "$IMAGE" > sbom.spdx.json

# Basic security check
echo "🛡️ Checking for critical vulnerabilities..."
if command -v grype >/dev/null; then
  grype "$IMAGE" --only-fixed --fail-on critical
else
  echo "⚠️  Install grype for vulnerability scanning"
fi

echo "✅ Image $IMAGE passed all verification checks"
```

### Integration with CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy Application
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Verify container image
        env:
          COSIGN_EXPERIMENTAL: 1
        run: |
          cosign verify ghcr.io/broadsage/nginx:latest \
            --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
            --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
      
      - name: Deploy to production
        if: success()
        run: |
          # Your deployment commands here
          kubectl set image deployment/nginx nginx=ghcr.io/broadsage/nginx:latest
```

## Support

- **Documentation**: [GitHub Repository](https://github.com/broadsage/containers)
- **Issues**: [Report Issues](https://github.com/broadsage/containers/issues)
- **Security**: [Security Policy](https://github.com/broadsage/containers/security/policy)
- **Community**: [Discussions](https://github.com/broadsage/containers/discussions)
