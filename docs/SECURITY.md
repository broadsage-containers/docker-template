<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Security Guide

This document provides comprehensive security information for Broadsage container images, including verification procedures, standards, and vulnerability reporting.

## 🚨 Reporting Security Vulnerabilities

**Do not report security vulnerabilities through public GitHub issues.**

Please report security vulnerabilities by emailing: **<security@broadsage.com>**

Include the following information:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

We will respond within 24 hours and provide updates every 72 hours.

## 🔐 Image Verification

All Broadsage images are cryptographically signed and include attestations for supply chain security.

### Quick Verification

For basic verification of any Broadsage container image:

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

### Verification Requirements by Environment

#### 🚦 Level 1: No Verification (Development)

- **When**: Local development, testing
- **Risk**: Low
- **Action**: Optional verification

#### 🚦 Level 2: Basic Verification (Staging)

- **When**: Staging environments, CI/CD pipelines
- **Risk**: Medium
- **Action**: Verify signatures before deployment

```bash
cosign verify ghcr.io/broadsage/nginx:latest \
  --certificate-identity-regexp="https://github.com/broadsage/containers" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

#### 🚦 Level 3: Strict Verification (Production)

- **When**: Production environments
- **Risk**: High
- **Action**: Mandatory signature and SBOM verification

```bash
IMAGE="ghcr.io/broadsage/nginx:latest"
EXPECTED_IDENTITY="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main"
EXPECTED_ISSUER="https://token.actions.githubusercontent.com"

# Verify signature
cosign verify "$IMAGE" \
  --certificate-identity="$EXPECTED_IDENTITY" \
  --certificate-oidc-issuer="$EXPECTED_ISSUER"

# Verify SBOM attestation
cosign verify-attestation "$IMAGE" \
  --certificate-identity="$EXPECTED_IDENTITY" \
  --certificate-oidc-issuer="$EXPECTED_ISSUER" \
  --type="https://spdx.dev/Document"
```

#### 🚦 Level 4: Policy Enforcement (High Security)

- **When**: Regulated industries, high-security environments
- **Risk**: Critical
- **Action**: Automated policy enforcement with Cosign policy

```bash
# Create and apply Cosign policy
cosign verify ghcr.io/broadsage/nginx:latest \
  --policy=cosign-policy.yaml
```

### Download and Inspect SBOM

```bash
# Download Software Bill of Materials
cosign download sbom ghcr.io/broadsage/nginx:latest > nginx-sbom.spdx.json

# View SBOM summary
jq -r '.packages[] | "\(.name): \(.versionInfo)"' nginx-sbom.spdx.json | head -20
```

## 🛡️ Container Security Standards

### Base Image Security

- **Minimal Base Images**: Alpine Linux or Debian minimal (bitnami/minideb)
- **Regular Updates**: Automated base image updates every 24 hours
- **CVE Scanning**: Zero critical CVEs in production images

### Runtime Security

All containers follow these security practices:

```dockerfile
# Non-root user execution
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER 1001

# Read-only root filesystem
FROM alpine:3.20
RUN addgroup -g 1001 appuser && \
    adduser -D -s /bin/sh -u 1001 -G appuser appuser
USER appuser
```

### Multi-Architecture Support

- **Primary Platforms**: linux/amd64, linux/arm64
- **Additional Platforms**: linux/arm/v7, linux/386, linux/ppc64le, linux/s390x
- **Security**: Same security standards across all architectures

## 🏗️ Supply Chain Security

### Image Signing

All images are signed using:

- **Keyless Signing**: Sigstore/Cosign with OIDC
- **Identity**: GitHub Actions OIDC tokens
- **Transparency**: All signatures logged in Rekor

### Attestations

Each image includes:

- **SBOM**: Software Bill of Materials (SPDX format)
- **Provenance**: Build provenance attestation (SLSA)
- **Vulnerability Scan**: Security scan results

### Build Security

- **Reproducible Builds**: Deterministic build process
- **Sealed Environments**: Builds run in isolated containers
- **Audit Trail**: Complete build logs and attestations

## 🔍 Vulnerability Management

### Scanning Pipeline

1. **Base Image Scanning**: Before build starts
2. **Build-Time Scanning**: During image creation
3. **Registry Scanning**: After image push
4. **Runtime Scanning**: Continuous monitoring

### Response Times

| Severity | Response Time | Patch Time |
|----------|--------------|------------|
| Critical | 2 hours | 24 hours |
| High | 4 hours | 72 hours |
| Medium | 24 hours | 1 week |
| Low | 1 week | Next release |

### Scanning Tools

- **Trivy**: Primary vulnerability scanner
- **Grype**: Secondary scanning for validation
- **Snyk**: Commercial scanning for enhanced coverage

## 🔧 Security Configuration

### Recommended Security Settings

#### Docker/Podman Runtime

```bash
# Run with security options
docker run --rm -it \
  --security-opt=no-new-privileges:true \
  --cap-drop=ALL \
  --read-only \
  --tmpfs /tmp \
  ghcr.io/broadsage/nginx:latest
```

#### Kubernetes

```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001
  containers:
  - name: nginx
    image: ghcr.io/broadsage/nginx:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### Network Security

- **Default**: No network access required for verification
- **Registry Access**: HTTPS-only connections
- **Transparency Logs**: Rekor integration for audit trail

## 📊 Security Metrics

We maintain and publish security metrics:

- **Mean Time to Patch**: Average time to fix vulnerabilities
- **CVE Coverage**: Percentage of CVEs detected and fixed
- **False Positive Rate**: Accuracy of security scanning
- **Verification Rate**: Percentage of deployments verified

## 🚀 Getting Started with Secure Deployment

### 1. Install Required Tools

```bash
# Cosign for verification
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# jq for JSON processing
sudo apt-get install -y jq  # Debian/Ubuntu
# or
brew install jq  # macOS
```

### 2. Create Verification Script

```bash
#!/bin/bash
# verify-image.sh

IMAGE="$1"
if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image>"
  exit 1
fi

echo "🔍 Verifying image: $IMAGE"

# Verify signature
cosign verify "$IMAGE" \
  --certificate-identity-regexp="https://github.com/broadsage/containers" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"

echo "✅ Image verification completed successfully"
```

### 3. Integrate with CI/CD

Add verification to your deployment pipeline:

```yaml
# GitHub Actions example
- name: Verify Container Image
  run: |
    cosign verify ghcr.io/broadsage/nginx:latest \
      --certificate-identity-regexp="https://github.com/broadsage/containers" \
      --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

## 📞 Security Support

- **Email**: <security@broadsage.com>
- **Response Time**: 24 hours for initial response
- **Updates**: Every 72 hours until resolution
- **Public Disclosure**: 90 days after fix (or earlier with consent)

For general security questions or guidance, create a [GitHub Discussion](https://github.com/broadsage/containers/discussions/categories/security).
