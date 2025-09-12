<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# ADR-002: Establish Community-Driven Container Foundation

## Status

Accepted

## Context

Broadsage is launching a new community-driven container project as part of our open source initiative. The goal is to build production-ready, security-hardened container images for popular applications that can serve as competitive alternatives to commercial hardened container solutions.

This project represents Broadsage's commitment to fostering open source innovation in the container ecosystem, providing the community with enterprise-grade, security-focused container solutions that rival commercial offerings across multiple application categories (web servers, databases, application frameworks, etc.).

Key requirements for the foundation:

1. **Security Hardening**: Implement comprehensive security measures to minimize attack surface
2. **Enterprise-Grade**: Build for mission-critical deployments and regulated environments  
3. **Performance-Optimized**: Tune for high-performance production workloads
4. **CVE-Responsive**: Rapid security updates and vulnerability management
5. **Transparency**: Complete visibility into security posture and build process
6. **Multi-Application Support**: Consistent approach across different application types
7. **Community-Accessible**: Open development while maintaining enterprise security standards

The decision involves choosing between various approaches for container foundations:

- Commercial hardened container distributions
- Upstream application packages with custom hardening
- Building from source code with security patches
- Using existing community containers as a base

## Decision

We will establish the project foundation using upstream nginx.org packages on a standard Debian base.

## Rationale

**Community Standards**: Using nginx.org packages ensures compatibility with the vast majority of nginx documentation, tutorials, and community knowledge. This lowers the barrier to contribution.

**Docker Official Images Alignment**: Our approach mirrors the patterns used in Docker Official Images, making the container familiar to users and potentially suitable for official status.

**Security and Maintenance**: Direct upstream packages receive security updates faster and have fewer intermediary dependencies than vendor-repackaged versions.

**Flexibility**: Standard nginx configuration allows users to apply any nginx.org documentation or third-party modules without vendor-specific adaptations.

**Portability**: The container can be easily understood, modified, and deployed by anyone familiar with standard nginx configurations.

## Implementation

1. **Base Image**: Use `debian:bookworm-slim` as a minimal, well-maintained foundation
2. **Nginx Installation**: Install nginx directly from nginx.org APT repository
3. **Configuration Structure**: Follow standard nginx file layout (`/etc/nginx/`, `/var/log/nginx/`)
4. **User Management**: Use standard nginx user (UID 101) following nginx.org conventions
5. **Port Configuration**: Use standard HTTP (80) and HTTPS (443) ports
6. **Security Hardening**: Implement security best practices from the ground up

## Consequences

**Positive**:

- Higher community adoption potential
- Easier maintenance and contributions
- Better security posture with faster updates
- Compatibility with standard nginx documentation
- Potential eligibility for Docker Official Images

**Negative**:

- Requires establishing new documentation and examples
- Users familiar with vendor-specific setups need to learn standard configurations
- More responsibility for security hardening and best practices

**Neutral**:

- Initial setup effort is similar regardless of chosen foundation
- Long-term maintenance effort shifts from vendor compatibility to community standards
