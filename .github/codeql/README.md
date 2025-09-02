<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# 🐳 Container Security CodeQL Analysis

This directory contains advanced CodeQL configuration and custom security queries specifically designed for Docker container projects, with focus on shell script security, Dockerfile best practices, and container runtime security.

## 🔍 Overview

Our CodeQL setup provides comprehensive security analysis for container environments using GitHub Advanced Security, following industry best practices for containerized applications and Docker security.

### 🎯 Container Security Focus Areas

- **🐳 Dockerfile Security**: Base image vulnerabilities, privilege escalation, secret exposure
- **🔧 Shell Script Security**: Command injection, input validation, privilege issues  
- **⚙️ Container Runtime**: Environment variable leaks, secret management, privilege boundaries
- **🔗 Supply Chain**: Dependency vulnerabilities, build process security
- **📦 Image Composition**: Layer optimization, minimal attack surface

## 📁 File Structure

```text
.github/codeql/
├── codeql-config.yml                    # Main configuration optimized for containers
├── custom-container-security.qls        # Container-focused query suite
├── custom-security-suite.qls            # Legacy general security suite
├── custom-queries/                      # Custom security queries
│   ├── hardcoded-credentials.ql         # Detects secrets in code
│   ├── shell-injection.ql               # Container shell injection patterns
│   ├── container-privilege-escalation.ql # Privilege escalation detection
│   └── insecure-dockerfile-patterns.ql  # Dockerfile security anti-patterns
└── README.md                           # This documentation
```

## ⚙️ Enhanced Configuration Features

### 🔒 Container Security Analysis

- **Multi-Language Support**: Python, JavaScript/TypeScript, Shell scripts
- **Container-Specific Queries**: Custom queries for Docker and container security
- **Dockerfile Analysis**: Security pattern detection in container definitions
- **Shell Script Scanning**: Command injection and privilege escalation detection
- **Secret Detection**: Enhanced hardcoded credential detection for containers

### 🚀 CI/CD Integration

- **Pre-Analysis Checks**: Hadolint (Dockerfile linting) and ShellCheck integration
- **Path-Aware Scanning**: Focuses on container-relevant files and excludes noise
- **Performance Optimized**: Configured for large container projects with multiple services
- **Enhanced Reporting**: Container-specific security summaries and recommendations

### 📊 Analysis Triggers

- **Push/PR Analysis**: Automatic analysis on container file changes
- **Daily Scheduled Scans**: Comprehensive security assessment at 02:00 UTC
- **Manual Dispatch**: On-demand analysis with customizable query suites
- **Path-Filtered**: Only runs when container-relevant files are modified

## 🔧 Container-Specific Queries

### 🛡️ Custom Security Queries

| Query | Purpose | Severity | CWE |
|-------|---------|----------|-----|
| `hardcoded-credentials.ql` | Detects secrets in source code | Warning | CWE-798 |
| `shell-injection.ql` | Command injection in containers | Error | CWE-78 |
| `container-privilege-escalation.ql` | Privilege escalation patterns | Warning | CWE-250 |
| `insecure-dockerfile-patterns.ql` | Dockerfile security anti-patterns | Warning | Multiple |

### 🎯 Security Categories Covered

- **CWE-78**: OS Command Injection
- **CWE-200**: Information Exposure  
- **CWE-250**: Execution with Unnecessary Privileges
- **CWE-285**: Improper Authorization
- **CWE-287**: Improper Authentication
- **CWE-295**: Improper Certificate Validation
- **CWE-327**: Use of a Broken Cryptographic Algorithm
- **CWE-377**: Insecure Temporary File
- **CWE-502**: Deserialization of Untrusted Data
- **CWE-522**: Insufficiently Protected Credentials
- **CWE-798**: Use of Hard-coded Credentials
- **CWE-829**: Inclusion of Functionality from Untrusted Control Sphere

## 🚀 Usage Guide

### 🔄 Automatic Analysis

CodeQL analysis runs automatically on:

- **Push Events**: `main`, `develop`, feature branches (`feature/**`, `hotfix/**`, `bugfix/**`, `release/**`)
- **Pull Requests**: Targeting `main` or `develop` branches  
- **Scheduled Scans**: Daily at 02:00 UTC for comprehensive analysis
- **File-Based Triggers**: Only when container-relevant files are modified:
  - Shell scripts (`**/*.sh`)
  - Dockerfiles (`**/Dockerfile*`)
  - Source code (`**/*.py`, `**/*.js`, `**/*.ts`)
  - Configuration files (`**/*.yml`, `**/*.yaml`)

### 🎛️ Manual Execution

Trigger manual analysis with custom parameters:

```bash
# Via GitHub CLI
gh workflow run "🔍 CodeQL Container Security Analysis" \
  --field queries="security-extended" \
  --field include_experimental="true"

# Via GitHub web interface
# Navigate to: Actions → 🔍 CodeQL Container Security Analysis → Run workflow
```

### ⚙️ Configuration Options

- **Query Suites**:
  - `security-extended` (recommended for containers)
  - `security-and-quality` (comprehensive analysis)
  - `custom-container-security` (container-specific queries)
- **Experimental Queries**: Enable cutting-edge security detection
- **Language Matrix**: Automatic detection of Python, JavaScript, and shell scripts

## 📊 Results & Reporting

### 🔍 Viewing Results

1. **Security Tab**: Navigate to `Settings → Security → Code scanning alerts`
2. **Workflow Summary**: Detailed container security metrics in Actions
3. **Pull Request Integration**: Security findings appear as PR comments
4. **Security Advisory**: Automated security advisories for critical findings

### 📈 Container-Specific Metrics

The workflow provides enhanced reporting with:

- **File Type Analysis**: Breakdown by Dockerfiles, shell scripts, source code
- **Security Category Distribution**: Privilege escalation, injection, secrets, etc.
- **Risk Assessment**: Severity levels with container-specific context
- **Remediation Guidance**: Container security best practices for each finding

### 🛡️ Pre-Analysis Security Checks

Before CodeQL analysis, the workflow runs:

- **Hadolint**: Dockerfile linting and security checks
- **ShellCheck**: Shell script security validation  
- **File Discovery**: Container asset inventory and analysis planning

## 🔒 Container Security Queries

### 🛡️ Built-in Security Coverage

| Security Domain | Coverage | CWE Categories |
|-----------------|----------|----------------|
| **Command Injection** | Shell scripts, Python `os.system()` | CWE-78 |
| **Secret Management** | Hardcoded credentials, API keys | CWE-798, CWE-522 |
| **Privilege Escalation** | Docker `--privileged`, sudo usage | CWE-250 |
| **Information Exposure** | Error messages, debug info | CWE-200, CWE-209 |
| **Dockerfile Security** | Base images, COPY patterns | Multiple |
| **Authentication** | Weak authentication patterns | CWE-287 |
| **Cryptography** | Weak algorithms, poor randomness | CWE-327, CWE-330 |

### 🎯 Container-Specific Detections

- **Docker Privilege Flags**: `--privileged`, `--cap-add` usage
- **Dangerous Mounts**: `/var/run/docker.sock`, `/proc`, `/sys` exposure
- **Root User Execution**: Container runtime user validation
- **Secret Exposure**: Environment variables containing credentials
- **Network Security**: Insecure port exposure patterns
- **Base Image Security**: Unversioned base images, known vulnerabilities

## 🔧 Customization & Extension

### 🎨 Adding Custom Queries

1. **Create Query File**: Add `.ql` files to `custom-queries/`
```ql
/**
 * @name Custom container security check
 * @description Detects custom security patterns
 * @kind problem
 * @tags security container
 */
```

2. **Register in Query Suite**: Update `custom-container-security.qls`
```yaml
queries:
  - query: custom-queries/my-custom-check.ql
```

3. **Configure Analysis**: Modify `codeql-config.yml` if needed

### 🎛️ Tuning Analysis Scope

**Focus on Container Assets**:
```yaml
# In codeql-config.yml
paths:
  - "**/Dockerfile*"
  - "**/*.sh"
  - "/broadsage/**"  # Container source directory
  - "/templates/**"  # Container templates

paths-ignore:
  - "**/test-data/**"
  - "**/*.md"
```

**Language-Specific Tuning**:
```yaml
python:
  setup-python-dependencies: true
  include-dependencies: false  # Skip third-party in containers

javascript:
  setup-node-dependencies: true
  include-dev-dependencies: false  # Production focus
```

## 📈 Performance Optimization

### ⚡ Resource Configuration

```yaml
# Container-optimized performance settings
analysis:
  threads: 0  # Auto-detect optimal thread count
  timeout: 180  # Extended for comprehensive container analysis
  memory-limit: "8G"  # Sufficient for multi-service container projects
```

### 🔄 Workflow Optimization

- **Path-Based Triggers**: Reduces unnecessary runs
- **Matrix Strategy**: Parallel language analysis
- **Conditional Steps**: Skip irrelevant analysis based on project structure
- **Caching**: Dependency caching for faster subsequent runs

## 🏆 Best Practices

### 📋 Container Security Checklist

**Pre-Commit**:
- [ ] Run `hadolint` on all Dockerfiles
- [ ] Execute `shellcheck` on shell scripts
- [ ] Validate no hardcoded secrets in code
- [ ] Review privilege requirements

**CI/CD Integration**:
- [ ] Enable CodeQL on all container-relevant branches
- [ ] Configure security gates for high-severity findings
- [ ] Set up automatic security alerts
- [ ] Integrate with dependency scanning

**Ongoing Maintenance**:
- [ ] Review security findings weekly
- [ ] Update base images regularly
- [ ] Monitor for new container security queries
- [ ] Validate security fixes with re-analysis

### 🔐 Security Hardening

**Container Runtime**:
```dockerfile
# Use non-root user
USER 1001

# Remove unnecessary packages
RUN apt-get autoremove -y && apt-get clean

# Set read-only root filesystem
# Add to docker run: --read-only
```

**Secret Management**:
```bash
# Use build secrets
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    # Use API_KEY without storing it
```

**Network Security**:
```dockerfile
# Expose only necessary ports
EXPOSE 8080

# Avoid privileged ports
# EXPOSE 80  # Avoid if possible
```

## 🆘 Troubleshooting

### 🐛 Common Issues

**Analysis Timeout**:
- Increase timeout in `codeql-config.yml`
- Optimize paths to exclude unnecessary files
- Consider splitting large repositories

**Missing Dependencies**:
- Verify language setup steps in workflow
- Check package installation logs
- Ensure container dependencies are available

**False Positives**:
- Add exclusions to query suites
- Use path-based filtering
- Customize query sensitivity

**Performance Issues**:
- Adjust thread count and memory limits
- Use path filtering to focus analysis
- Enable debug mode for bottleneck identification

### 📞 Support

- **Documentation**: [Container Security Guide](docs/CONTAINER_SECURITY.md)
- **Issues**: [GitHub Issues](../../issues)
- **Security Reports**: [Security Policy](../../security/policy)

---

## 📜 License & Attribution

This CodeQL configuration is part of the Broadsage Containers project.

- **License**: Apache-2.0
- **Copyright**: © 2025 Broadsage <opensource@broadsage.com>
- **Security Queries**: Custom queries based on industry best practices and OWASP guidelines

1. **Enable Advanced Security**: Required for private repositories
2. **Configure Branch Protection**: Require CodeQL checks to pass
3. **Set Up Notifications**: Alert on new security findings

### Development Workflow

1. **Local Testing**: Use CodeQL CLI for local development
2. **Pre-commit Hooks**: Integrate basic security checks
3. **Regular Reviews**: Weekly security finding reviews

### Response Process

1. **Triage**: Classify findings by severity and validity
2. **Remediation**: Fix confirmed vulnerabilities promptly  
3. **Documentation**: Update security documentation
4. **Monitoring**: Track resolution metrics

## 🔗 Resources

- [CodeQL Documentation](https://codeql.github.com/docs/)
- [GitHub Advanced Security](https://docs.github.com/en/code-security/code-scanning)
- [Security Advisories](https://docs.github.com/en/code-security/repository-security-advisories)
- [CodeQL Query Libraries](https://github.com/github/codeql)

## 📞 Support

For issues with CodeQL configuration:

1. Check workflow logs in GitHub Actions
2. Review security findings in the Security tab  
3. Open an issue with the security team
4. Consult the [SECURITY.md](../../SECURITY.md) file

---

**Security is everyone's responsibility!** 🛡️
