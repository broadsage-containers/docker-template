<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# ADR-004: Enterprise-Grade Container Architecture and Security Hardening

## Status

Accepted

## Context

For our community-driven nginx container, we need to make architectural decisions that position it as a competitive alternative to commercial hardened container solutions. These decisions must prioritize security, enterprise readiness, and production performance while maintaining transparency and community accessibility.

Key architectural decisions needed:

1. **Security Hardening**: Comprehensive security measures to minimize attack surface
2. **Enterprise Integration**: Features required for enterprise deployments
3. **Performance Tuning**: Optimization for production workloads
4. **Monitoring & Observability**: Built-in monitoring capabilities
5. **Compliance Support**: Features for regulated industry requirements
6. **Zero-Downtime Operations**: Graceful handling of updates and maintenance

These decisions will establish our competitive positioning against commercial hardened solutions while providing superior transparency and community control.

## Decision

We will implement a security-first container architecture with the following decisions:

1. **Standard Ports**: Expose ports 80 (HTTP) and 443 (HTTPS)
2. **Non-root User**: Run nginx as dedicated nginx user (UID 101)
3. **Standard Layout**: Follow FHS and nginx.org file structure conventions
4. **Security Hardening**: Remove SUID binaries, implement proper signal handling
5. **Process Management**: Use nginx in foreground mode with proper signal forwarding
6. **Container Logging**: Log to stdout/stderr for container orchestration compatibility

## Rationale

**Standard Ports (80/443)**:

- Industry standard and expected by users
- Compatible with most deployment scenarios
- No need for port mapping in typical use cases
- Aligns with Docker Official Images patterns

**Non-root User (nginx UID 101)**:

- Follows security best practices and principle of least privilege
- Standard nginx user ID used across the ecosystem
- Prevents container breakout scenarios
- Required for security-conscious environments

**Standard File Layout**:

- `/etc/nginx/`: Configuration files (industry standard)
- `/var/log/nginx/`: Log files (FHS compliant)
- `/var/cache/nginx/`: Temporary and cache files
- `/run/nginx.pid`: PID file location

**Security Hardening**:

- Remove unnecessary SUID/SGID binaries
- Minimal package installation
- Proper file permissions
- Read-only root filesystem compatibility

**Process Management**:

- Run nginx in foreground (`daemon off;`)
- Proper signal handling for graceful shutdown
- Health check endpoint for orchestration

**Container Logging**:

- Nginx logs to `/var/log/nginx/` but symlinked to stdout/stderr
- Compatible with Docker logging drivers
- Supports log aggregation systems

## Implementation

**User Setup**:

```dockerfile
# Create nginx user with standard UID
RUN set -eux; \
    groupadd --system --gid 101 nginx; \
    useradd --system --gid nginx --no-create-home \
        --home-dir /nonexistent --comment "nginx user" \
        --shell /bin/false --uid 101 nginx
```

**Security Hardening**:

```dockerfile
# Remove SUID/SGID binaries
RUN find / -xdev -perm /6000 -type f -exec chmod a-s {} \; || true
```

**Directory Structure**:

```dockerfile
# Set up standard nginx directories with correct permissions
RUN set -eux; \
    mkdir -p /var/cache/nginx /var/log/nginx; \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx; \
    chmod 755 /var/cache/nginx /var/log/nginx
```

**Logging Setup**:

```dockerfile
# Forward logs to docker log collector
RUN set -eux; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log
```

## Consequences

**Positive**:

- Enhanced security posture with non-root execution
- Standard ports improve usability and deployment
- Container-native logging supports modern orchestration
- Architecture aligns with Docker Official Images standards
- Security hardening meets enterprise requirements

**Negative**:

- Non-root user requires proper permission setup
- Standard ports may conflict in development environments
- Additional complexity in Dockerfile for security measures

**Neutral**:

- File layout follows established conventions
- Process management standard for containerized nginx
- Security measures are industry best practices
