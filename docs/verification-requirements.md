<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Image Verification Requirements

This document explains when and how image verification is required for Broadsage containers.

## 🚦 Verification Levels

### **Level 1: No Verification (Default)**

- **Use Case**: Development, testing, quick demos
- **Risk**: Low (development environments)
- **Command**: Standard container commands work directly

```bash
# Works immediately - no verification required
docker run ghcr.io/broadsage/nginx:latest
kubectl run nginx --image=ghcr.io/broadsage/nginx:latest
```

### **Level 2: Optional Verification (Recommended)**

- **Use Case**: Staging, integration testing
- **Risk**: Medium (pre-production environments)
- **Command**: Verification tools provided but not enforced

```bash
# Recommended: Verify before use
./scripts/verify-image.sh ghcr.io/broadsage/nginx:latest
docker run ghcr.io/broadsage/nginx:latest
```

### **Level 3: Mandatory Verification (Production)**

- **Use Case**: Production deployments, regulated environments
- **Risk**: High (production, compliance requirements)
- **Command**: Verification required via CI/CD or admission controllers

```bash
# Required in CI/CD pipelines
./scripts/verify-image.sh ghcr.io/broadsage/nginx:latest || exit 1
kubectl set image deployment/nginx nginx=ghcr.io/broadsage/nginx:latest
```

### **Level 4: Policy Enforcement (High Security)**

- **Use Case**: Financial, healthcare, government
- **Risk**: Critical (regulatory compliance, zero-trust)
- **Command**: Platform-level enforcement prevents unsigned images

```bash
# Kubernetes admission controller blocks unsigned images automatically
kubectl apply -f .cosign/consumer-policy.yaml
kubectl run nginx --image=ghcr.io/broadsage/nginx:latest  # ✅ Allowed (signed)
kubectl run bad --image=nginx:latest                      # ❌ Blocked (unsigned)
```

## 🏢 Industry Recommendations

### **Startups/Small Companies**

- **Development**: Level 1 (No verification)
- **Production**: Level 2 (Optional verification)
- **Rationale**: Balance security with development velocity

### **Medium/Large Enterprises**

- **Development**: Level 1-2 (No/Optional verification)
- **Staging**: Level 2 (Optional verification with monitoring)
- **Production**: Level 3 (Mandatory verification)
- **Rationale**: Enforce security in production, flexibility in development

### **Regulated Industries (Finance, Healthcare, Government)**

- **All Environments**: Level 4 (Policy enforcement)
- **Rationale**: Compliance requirements, zero-trust architecture

## 🛠️ Implementation Guide

### **For Developers (Level 1-2)**

No changes required. Verification tools are available if needed:

```bash
# Optional verification
./scripts/verify-image.sh ghcr.io/broadsage/nginx:latest

# Continue with normal workflow
docker-compose up
```

### **For DevOps Teams (Level 3)**

Add verification to CI/CD pipelines:

```yaml
# .github/workflows/deploy.yml
- name: Verify container images
  run: |
    for image in $(grep "ghcr.io/broadsage" docker-compose.yml | cut -d: -f2-); do
      ./scripts/verify-image.sh "$image"
    done
```

### **For Platform Teams (Level 4)**

Deploy admission controllers:

```bash
# Install Cosign Policy Controller
kubectl apply -f https://github.com/sigstore/policy-controller/releases/latest/download/policy-controller.yaml

# Apply Broadsage verification policy
kubectl apply -f https://raw.githubusercontent.com/broadsage/containers/main/.cosign/consumer-policy.yaml
```

## 🔧 Configuration Examples

### **Docker Compose with Optional Verification**

```yaml
# docker-compose.yml
version: '3.8'
services:
  nginx:
    image: ghcr.io/broadsage/nginx:latest
    ports:
      - "80:80"
    # Optional: Add verification init container
    depends_on:
      - verify-nginx

  # Optional verification service
  verify-nginx:
    image: gcr.io/projectsigstore/cosign:v2.2.1
    command: >
      sh -c "
        echo 'Verifying Broadsage nginx image...' &&
        cosign verify ghcr.io/broadsage/nginx:latest 
          --certificate-identity='https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main' 
          --certificate-oidc-issuer='https://token.actions.githubusercontent.com' &&
        echo '✅ Image verification passed'
      "
    restart: "no"
```

### **Kubernetes with Mandatory Verification**

```yaml
# nginx-deployment-verified.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-verified
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-verified
  template:
    metadata:
      labels:
        app: nginx-verified
    spec:
      # Mandatory verification init container
      initContainers:
      - name: verify-image
        image: gcr.io/projectsigstore/cosign:v2.2.1
        command:
        - sh
        - -c
        - |
          echo "🔍 Verifying Broadsage nginx image..."
          cosign verify ghcr.io/broadsage/nginx:latest \
            --certificate-identity="https://github.com/broadsage/containers/.github/workflows/release-pipeline.yml@refs/heads/main" \
            --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
          echo "✅ Verification passed - starting application"
      containers:
      - name: nginx
        image: ghcr.io/broadsage/nginx:latest
        ports:
        - containerPort: 80
```

## 🎯 Quick Decision Matrix

| Environment | Security Level | Verification Approach | Implementation |
|-------------|----------------|----------------------|----------------|
| **Local Development** | Low | Optional | Manual script usage |
| **CI/CD Testing** | Medium | Automated | CI pipeline step |
| **Staging** | Medium-High | Mandatory | Required CI step |
| **Production** | High | Mandatory | CI + Init containers |
| **Regulated** | Critical | Policy Enforced | Admission controllers |

## 🚀 Getting Started

1. **Choose your security level** based on environment and risk tolerance
2. **Start with Level 1** (no verification) for immediate use
3. **Gradually increase** verification requirements as you move to production
4. **Implement policy enforcement** for high-security environments

## 📞 Support

- **Questions**: [GitHub Discussions](https://github.com/broadsage/containers/discussions)
- **Issues**: [Report Problems](https://github.com/broadsage/containers/issues)
- **Security**: [Security Policy](https://github.com/broadsage/containers/security/policy)
