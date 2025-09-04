<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Container Image Standards & Guidelines

## Image Architecture

### Multi-Architecture Support

- **Required Platforms**: linux/amd64, linux/arm64
- **Optional Platforms**: linux/arm/v7 (for Raspberry Pi)
- **Build Strategy**: Use `docker buildx` with platform-specific optimizations

### Base Image Selection

```dockerfile
# Recommended: Use minimal, security-focused base images
FROM docker.io/bitnami/minideb:bookworm@sha256:...  # Debian minimal
# Alternative: FROM alpine:3.19@sha256:...  # Alpine Linux
```

## Security Requirements

### 1. Non-Root Execution

```dockerfile
# Create dedicated user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER 1001
```

### 2. Vulnerability Management

- **Zero Critical CVEs** in production images
- **Daily scanning** with Trivy, Grype, and Snyk
- **Automated patching** pipeline for base image updates

### 3. Supply Chain Security

- **SBOM Generation**: Every image must include Software Bill of Materials
- **Image Signing**: Cosign signatures for all published images  
- **Reproducible Builds**: Deterministic build process

## Image Optimization

### Size Optimization

```dockerfile
# Multi-stage builds
FROM node:18-alpine AS builder
WORKDIR /build
COPY package*.json ./
RUN npm ci --only=production

FROM alpine:3.19
# Copy only necessary artifacts
COPY --from=builder /build/node_modules ./node_modules
```

### Layer Optimization

```dockerfile
# Combine RUN commands to reduce layers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

## Metadata Standards

### Required Labels

```dockerfile
LABEL org.opencontainers.image.title="nginx"
LABEL org.opencontainers.image.description="NGINX Open Source web server"
LABEL org.opencontainers.image.version="1.29.1"
LABEL org.opencontainers.image.created="2025-01-01T00:00:00Z"
LABEL org.opencontainers.image.source="https://github.com/broadsage/containers"
LABEL org.opencontainers.image.documentation="https://github.com/broadsage/containers/tree/main/broadsage/nginx"
LABEL org.opencontainers.image.vendor="Broadsage, Inc."
LABEL org.opencontainers.image.licenses="Apache-2.0"
```

## Testing Requirements

### Automated Testing

1. **Build Tests**: Successful image builds across all platforms
2. **Security Tests**: Vulnerability scanning passes
3. **Functional Tests**: Container starts and serves expected content
4. **Performance Tests**: Resource usage within acceptable limits

### Test Structure

```bash
tests/
├── build/           # Build validation tests
├── security/        # Security scanning tests  
├── functional/      # Runtime functionality tests
└── performance/     # Resource usage tests
```

## Versioning Strategy

### Semantic Versioning

- **Major.Minor.Patch** (e.g., 1.29.1)
- **Tags**: latest, 1.29, 1.29.1, 1.29.1-debian-12

### Update Strategy

- **Security Updates**: Immediate patch releases
- **Minor Updates**: Monthly maintenance releases
- **Major Updates**: Quarterly feature releases

## Compliance Checklist

### Before Publishing

- [ ] Security scan passes (zero critical, minimal high CVEs)
- [ ] Multi-platform build successful
- [ ] SBOM generated and attached
- [ ] Image signed with Cosign
- [ ] Documentation updated
- [ ] Tests passing
- [ ] License compliance verified

This document serves as the foundation for building enterprise-grade, security-focused container images that meet industry standards.
