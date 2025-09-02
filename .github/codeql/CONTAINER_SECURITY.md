# 🐳 Container Security Guidelines

This document provides comprehensive security guidelines for the Broadsage Containers project, focusing on Docker security best practices, secure coding standards, and container runtime security.

## 🔒 Security Philosophy

Our container security approach follows the **principle of least privilege** and **defense in depth**, implementing multiple layers of security controls throughout the container lifecycle.

### 🎯 Security Objectives

- **Minimize Attack Surface**: Reduce potential entry points for attackers
- **Secure by Default**: Apply security hardening from the ground up  
- **Supply Chain Security**: Ensure integrity of base images and dependencies
- **Runtime Protection**: Implement controls during container execution
- **Monitoring & Detection**: Enable comprehensive security observability

## 🐋 Dockerfile Security Best Practices

### ✅ Secure Base Images

```dockerfile
# ✅ Use specific, minimal base images
FROM debian:bookworm-slim@sha256:abc123...

# ❌ Avoid latest tags and bloated images
# FROM ubuntu:latest
# FROM node:alpine
```

**Requirements:**
- Use image digests (SHA256) for reproducible builds
- Prefer minimal distributions (Alpine, Distroless, Slim)
- Regularly update base images for security patches
- Scan base images for known vulnerabilities

### 🚫 Non-Root User Execution

```dockerfile
# ✅ Create and use non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser

# ❌ Never run as root
# USER root
# USER 0
```

**Security Benefits:**
- Prevents privilege escalation attacks
- Limits impact of container escape vulnerabilities
- Reduces blast radius of compromised containers

### 🔐 Secret Management

```dockerfile
# ✅ Use build secrets for sensitive data
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    configure_application "$API_KEY"

# ❌ Never hardcode secrets
# ENV API_KEY=sk-1234567890abcdef
# RUN echo "password=secret123" > config.txt
```

**Secret Management Practices:**
- Use Docker BuildKit secrets for build-time secrets
- Leverage Kubernetes secrets for runtime configuration
- Implement secret rotation policies
- Audit secret access and usage

### 🛡️ Minimal Privileges

```dockerfile
# ✅ Remove unnecessary packages and capabilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ✅ Set minimal filesystem permissions
RUN chmod 755 /app && \
    chown appuser:appgroup /app
```

### 🔒 Network Security

```dockerfile
# ✅ Expose only necessary ports
EXPOSE 8080

# ❌ Avoid exposing administrative ports
# EXPOSE 22   # SSH
# EXPOSE 3389 # RDP
# EXPOSE 5432 # Direct database access
```

## 🔧 Shell Script Security

### 🛡️ Input Validation

```bash
#!/bin/bash
set -euo pipefail  # Strict error handling

# ✅ Validate input parameters
validate_input() {
    local input="$1"
    if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Invalid input format" >&2
        exit 1
    fi
}

# ✅ Use parameter expansion safely
config_file="${CONFIG_FILE:-/app/config/default.conf}"
```

### 🔒 Command Injection Prevention

```bash
# ✅ Use arrays for command construction
declare -a cmd_args
cmd_args=("docker" "run" "--rm" "$image_name")
"${cmd_args[@]}"

# ✅ Proper quoting and escaping
user_input="$1"
docker run --name "$(printf '%q' "$user_input")" "$image"

# ❌ Never use unvalidated input directly
# docker run --name $user_input $image
```

### 🔐 Privilege Management

```bash
# ✅ Drop privileges when possible
if [[ $EUID -eq 0 ]]; then
    exec sudo -u appuser "$0" "$@"
fi

# ✅ Use specific sudo commands instead of full root access
# /etc/sudoers.d/appuser:
# appuser ALL=(root) NOPASSWD: /usr/bin/systemctl restart myapp
```

## 🏃 Runtime Security

### 🔒 Container Runtime Configuration

```bash
# ✅ Security-hardened container execution
docker run \
    --user 1001:1001 \
    --read-only \
    --tmpfs /tmp:noexec,nosuid,size=100m \
    --tmpfs /var/run:noexec,nosuid,size=100m \
    --no-new-privileges \
    --cap-drop ALL \
    --cap-add CHOWN \
    --cap-add SETGID \
    --cap-add SETUID \
    --security-opt=no-new-privileges:true \
    --security-opt=apparmor:docker-default \
    myapp:latest

# ❌ Avoid privileged containers
# docker run --privileged myapp:latest
```

### 🛡️ Network Security

```bash
# ✅ Use custom networks
docker network create --driver bridge app-network
docker run --network app-network myapp:latest

# ✅ Limit port exposure
docker run -p 127.0.0.1:8080:8080 myapp:latest  # Local only
```

### 📊 Resource Limits

```bash
# ✅ Set resource constraints
docker run \
    --memory=512m \
    --memory-swap=512m \
    --cpu-quota=50000 \
    --cpu-period=100000 \
    --pids-limit=100 \
    myapp:latest
```

## 🔍 Security Monitoring & Detection

### 📈 Container Security Metrics

Monitor these key security indicators:

- **Image Vulnerabilities**: CVE count and severity
- **Runtime Behavior**: Unexpected network connections, file access
- **Privilege Escalation**: Attempts to gain elevated permissions
- **Resource Usage**: CPU, memory, network anomalies
- **Secret Access**: Authentication and authorization events

### 🚨 Security Alerts

Implement alerting for:

```bash
# Suspicious container behavior
- Container running as root when configured otherwise
- Unusual network connections to external hosts
- High-privilege capability usage
- Unexpected file system modifications
- Container escape attempts
```

### 📊 Compliance Monitoring

```yaml
# Example monitoring configuration
security_policies:
  - name: "no-root-containers"
    description: "Containers must not run as root"
    rule: "user_id != 0"
    
  - name: "minimal-capabilities"  
    description: "Containers should have minimal Linux capabilities"
    rule: "capabilities.count <= 3"
    
  - name: "read-only-filesystem"
    description: "Application containers should use read-only root filesystem"
    rule: "read_only_root_fs == true"
```

## 🔄 CI/CD Security Integration

### ✅ Secure Build Pipeline

```yaml
# Security-focused build steps
steps:
  - name: Vulnerability Scan
    run: |
      # Scan base images for vulnerabilities
      trivy image --severity HIGH,CRITICAL base-image:latest
      
  - name: Dockerfile Security Lint
    run: |
      # Lint Dockerfiles for security issues
      hadolint Dockerfile --failure-threshold error
      
  - name: Secret Scanning
    run: |
      # Scan for hardcoded secrets
      truffleHog --regex --entropy=False .
      
  - name: Code Security Analysis
    uses: github/codeql-action/analyze@v3
```

### 🔒 Supply Chain Security

```yaml
# Dependency security measures
security_measures:
  - name: "dependency-scanning"
    tools: ["npm audit", "pip-audit", "bundler-audit"]
    
  - name: "container-signing"
    method: "cosign"
    verification: "required"
    
  - name: "sbom-generation"
    format: "SPDX"
    include: ["dependencies", "base-images"]
```

## 🆘 Incident Response

### 🚨 Security Incident Types

1. **Container Escape**: Process breaks out of container boundaries
2. **Privilege Escalation**: Unauthorized elevation of permissions
3. **Data Exfiltration**: Unauthorized access to sensitive data
4. **Resource Exhaustion**: DoS through resource consumption
5. **Supply Chain Compromise**: Malicious components in dependencies

### 🔧 Response Procedures

```bash
# Immediate containment
docker stop <compromised-container>
docker network disconnect <network> <container>

# Investigation
docker logs <container> > incident-logs.txt
docker inspect <container> > container-metadata.json

# Evidence preservation
docker commit <container> evidence-image:$(date +%Y%m%d-%H%M%S)
```

## 📚 Security Resources

### 🔗 External References

- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST Container Security Guide](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [OWASP Container Security Top 10](https://owasp.org/www-project-container-security/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### 🛠️ Security Tools

- **Vulnerability Scanning**: Trivy, Clair, Anchore
- **Policy Enforcement**: OPA Gatekeeper, Falco
- **Runtime Security**: Sysdig, Aqua Security
- **Static Analysis**: CodeQL, Semgrep, Bandit

### 📋 Security Checklists

- [ ] All base images use specific digests
- [ ] No containers run as root user
- [ ] All secrets use proper management systems
- [ ] Network access is restricted to necessary ports
- [ ] Resource limits are configured
- [ ] Security scanning is integrated in CI/CD
- [ ] Monitoring and alerting are configured
- [ ] Incident response procedures are documented

---

## 📞 Security Support

For security-related questions or to report vulnerabilities:

- **Security Email**: security@broadsage.com
- **Security Policy**: [SECURITY.md](../SECURITY.md)
- **Vulnerability Reports**: [GitHub Security Advisories](../../security/advisories)

---

*This document is maintained by the Broadsage Security Team and updated regularly to reflect current best practices and emerging threats.*
