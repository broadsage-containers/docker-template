<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| 1.29.x  | :white_check_mark: |
| < 1.29  | :x:                |

## Reporting a Vulnerability

We take the security of our container images seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

For detailed security reporting procedures, contact information, and response expectations, see our [Communication Guide](docs/communication.md#-email-contacts).

**Quick Reference:** Email [security@broadsage.com](mailto:security@broadsage.com)

### Response Timeline

- **Initial Response**: Within 48 hours of receiving your report
- **Triage**: Within 7 days we'll provide a detailed response indicating next steps
- **Resolution**: Critical vulnerabilities will be patched within 30 days

### Security Updates

Security updates are released through:

1. **Container Image Updates**: New image tags with patches
2. **Security Advisories**: Published on our GitHub repository
3. **CVE Database**: Registered vulnerabilities receive CVE numbers

## Security Features

Our container images include:

- **Minimal Attack Surface**: Based on minimal base images (debian-slim/alpine)
- **Non-Root Execution**: All processes run as non-root user (UID 1001)
- **Regular Security Scanning**: Daily automated vulnerability scans
- **Supply Chain Security**:
  - SBOM (Software Bill of Materials) generation
  - Image signing with Cosign
  - Reproducible builds
- **Security Hardening**:
  - Removed SUID/SGID binaries
  - No unnecessary packages
  - Read-only root filesystem support

## Best Practices for Users

When using our container images:

1. **Keep Images Updated**: Always use the latest tags for security patches
2. **Network Security**: Use proper network policies and firewalls
3. **Secrets Management**: Never embed secrets in images
4. **Runtime Security**:
   - Run with read-only root filesystem when possible
   - Use security contexts to drop capabilities
   - Enable SELinux/AppArmor when available

## Vulnerability Disclosure

We follow responsible disclosure practices:

1. We will acknowledge receipt of your vulnerability report
2. We will provide regular updates on our progress
3. We will credit you in our security advisory (if desired)
4. We will notify you when the vulnerability is resolved

Thank you for helping to keep our community safe!
