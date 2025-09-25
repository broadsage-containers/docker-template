<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# ADR-003: Use Upstream Application Sources

## Status

Accepted

## Context

For our community-driven container project, we need to decide on the source of application packages and binaries across all supported containers (nginx, mongodb, postgresql, etc.). This decision impacts security response times, maintenance overhead, and our competitive positioning against commercial hardened container solutions.

Available options include:

1. **Distribution packages** (e.g., Debian/Ubuntu application packages)
2. **Upstream official packages** (official application repositories)
3. **Commercial hardened distributions** (vendor-specific security-hardened packages)
4. **Building from source** (compiling applications from upstream source code)

Key considerations for competitive positioning:

- **Security Response Time**: Speed of vulnerability patching and updates across all applications
- **Feature Completeness**: Module availability and advanced capabilities  
- **Enterprise Readiness**: Suitability for production and regulated environments
- **Maintenance Overhead**: Long-term support and update processes for multiple applications
- **Performance Optimization**: Build configuration and tuning capabilities
- **Consistency**: Uniform approach across different application types
- **Transparency**: Visibility into build process and security measures

## Decision

We will use packages directly from official upstream repositories for each supported application (nginx.org, MongoDB Inc., PostgreSQL Global Development Group, etc.).

## Rationale

**Fastest Security Updates**: Official upstream repositories provide the most timely security updates, often releasing patches within hours of vulnerability disclosure. Distribution packages may lag by days or weeks.

**Feature Completeness**: Upstream packages include the latest stable features and modules that may not be available in distribution packages for months.

**Community Alignment**: Using official upstream packages ensures 100% compatibility with official application documentation, tutorials, and community resources.

**Predictable Versioning**: Upstream packages follow application semantic versioning exactly, making it easier to track features and compatibility across our container portfolio.

**Official Support**: Configuration and behavior match exactly what upstream projects document and support.

**Ecosystem Compatibility**: Full compatibility with application-specific module and extension ecosystems.

## Implementation

**Repository Setup Pattern**:
Each container follows the pattern of adding the official upstream repository for the specific application.

**Example - NGINX**:

```dockerfile
# Add nginx.org signing key and repository
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget; \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add -; \
    echo "deb https://nginx.org/packages/debian/ bookworm nginx" > /etc/apt/sources.list.d/nginx.list
```

**Example - MongoDB**:

```dockerfile
# Add MongoDB official repository
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget; \
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -; \
    echo "deb https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" > /etc/apt/sources.list.d/mongodb-org-7.0.list
```

**Generic Package Installation**:

```dockerfile
# Install application from official repository
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ${APPLICATION_PACKAGE}; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
```

**Configuration Principles**:

- Follow upstream-recommended directory structures
- Use standard configuration file locations
- Implement upstream logging conventions
- Maintain upstream service management patterns

## Consequences

**Positive**:

- Fastest security updates and patches across all applications
- Full feature set and module compatibility for each application
- Perfect alignment with official application documentation
- Predictable behavior matching official upstream projects
- Active upstream maintenance and support for all containers

**Negative**:

- Additional repository setup required in each Dockerfile
- Slightly larger attack surface than minimal custom builds
- Dependency on multiple upstream infrastructure providers
- Increased complexity managing multiple upstream sources

**Neutral**:

- Package size similar to distribution packages
- Configuration complexity equivalent to standard application installations
- Update frequency requires active maintenance but provides better security
- Consistent approach across all container images in our portfolio
