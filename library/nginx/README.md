<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Broadsage Community NGINX Container

## Enterprise-grade, security-hardened NGINX container by Broadsage

[![Docker Image Size](https://img.shields.io/docker/image-size/ghcr.io/broadsage/nginx/1.29)](https://github.com/broadsage/containers/pkgs/container/nginx)
[![Security Scanning](https://img.shields.io/badge/security-hardened-green)](../../SECURITY.md)
[![Enterprise Ready](https://img.shields.io/badge/enterprise-ready-blue)](../../CONTRIBUTING.md)

## Overview

This is an enterprise-grade, security-hardened NGINX container built as part of Broadsage's open source container initiative. It provides a production-ready nginx implementation with comprehensive security hardening, designed for mission-critical deployments and regulated environments.

**Key Features:**

- 🔒 **Security-Hardened**: Comprehensive security hardening with minimal attack surface
- ⚡ **Performance-Optimized**: Tuned for high-performance production workloads
- 🛡️ **Enterprise-Grade**: Suitable for regulated industries and high-security environments
- 🔄 **CVE-Responsive**: Rapid security updates and vulnerability management
- 📊 **Transparency**: Complete SBOM and vulnerability reporting
- 🏗️ **Production-Ready**: Battle-tested for mission-critical deployments

## Quick Start

### Basic Usage

```bash
# Run with default configuration
docker run --name nginx -p 80:80 ghcr.io/broadsage/nginx:1.29

# Health check
curl http://localhost/health
# Response: healthy
```

### Custom Configuration

```bash
# Mount custom nginx configuration
docker run --name nginx -p 80:80 \
  -v /path/to/nginx.conf:/etc/nginx/nginx.conf:ro \
  ghcr.io/broadsage/nginx:1.29

# Mount custom site configuration
docker run --name nginx -p 80:80 \
  -v /path/to/site.conf:/etc/nginx/conf.d/default.conf:ro \
  ghcr.io/broadsage/nginx:1.29

# Mount custom content
docker run --name nginx -p 80:80 \
  -v /path/to/html:/usr/share/nginx/html:ro \
  ghcr.io/broadsage/nginx:1.29
```

### Docker Compose

```yaml
services:
  nginx:
    image: ghcr.io/broadsage/nginx:1.29
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
      - ./ssl:/etc/nginx/ssl:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Architecture & Design

This container is built with enterprise-grade security and performance as the primary design goals:

### Security Hardening

- **Non-root execution**: Runs as nginx user (UID 101) with minimal privileges
- **Minimal attack surface**: No SUID binaries, minimal packages, hardened base image
- **Security headers**: Comprehensive security headers (X-Frame-Options, CSP, HSTS, etc.)
- **Log isolation**: Logs forwarded to stdout/stderr for secure log aggregation
- **File system hardening**: Read-only root filesystem support, minimal writable areas

### Enterprise Features

- **Standard ports**: HTTP (80), HTTPS (443) for enterprise network compatibility
- **Configuration flexibility**: Standard nginx file layout for easy integration
- **Health monitoring**: Built-in health checks and monitoring endpoints
- **Signal handling**: Graceful shutdown and reload for zero-downtime deployments
- **Resource optimization**: Tuned for production workload performance

### Performance Optimizations

- **Worker tuning**: Auto-configured based on available CPU cores and memory
- **Connection handling**: Optimized for high-concurrency enterprise scenarios
- **Compression**: Advanced gzip and brotli compression for bandwidth efficiency
- **Caching**: Intelligent static file serving with proper cache headers

## Configuration

### Default Configuration Structure

```bash
/etc/nginx/
├── nginx.conf              # Main configuration
├── conf.d/
│   └── default.conf        # Default server block
└── ssl/                    # SSL certificates (if mounted)

/var/log/nginx/
├── access.log -> /dev/stdout
└── error.log -> /dev/stderr

/usr/share/nginx/html/
├── index.html              # Default welcome page
├── 404.html               # Custom 404 page
└── 50x.html               # Server error page
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_WORKER_PROCESSES` | `auto` | Number of worker processes |
| `NGINX_WORKER_CONNECTIONS` | `1024` | Max connections per worker |
| `NGINX_KEEPALIVE_TIMEOUT` | `65` | Keep-alive timeout in seconds |

### Health Check Endpoint

The container includes a built-in health check endpoint:

```bash
curl http://localhost/health
# Returns: healthy
```

## Development & Testing

### Local Development

```bash
# Clone the repository
git clone https://github.com/broadsage/containers.git
cd containers

# Build the container
make build CONTAINER=nginx

# Run tests
make test CONTAINER=nginx

# Development workflow (build + test)
make dev CONTAINER=nginx
```

### Running Tests

```bash
# Run all tests
cd tests
bats integration.bats functional.bats security.bats

# Run specific test suite
bats integration.bats    # Basic functionality tests
bats functional.bats     # Advanced feature tests  
bats security.bats       # Security and compliance tests
```

## Community & Support

### 🤝 Contributing

This container is developed as part of Broadsage's commitment to open source innovation:

- **Open Development**: All decisions documented in [Architecture Decision Records](../../docs/architecture/)
- **Community Input**: Contributions welcome via GitHub Issues and Pull Requests
- **Transparent Process**: Public roadmap and development discussions

See our [Contributing Guide](../../CONTRIBUTING.md) for details on how to participate.

### 📚 Documentation

- [Architecture Decisions](../../docs/architecture/) - Documented design decisions
- [Security Guide](../../SECURITY.md) - Security practices and reporting
- [Development Setup](../../docs/) - Local development instructions

### 🐛 Issues & Support

For all support options, reporting channels, and community resources, see our [Communication Guide](../../docs/communication.md).

**Quick Links:**

- **Bug Reports & Feature Requests**: See communication guide for appropriate channels
- **Security Issues**: See [SECURITY.md](../../SECURITY.md)

### 🏷️ Versioning & Releases

We follow semantic versioning aligned with nginx releases:

- **Major.Minor.Patch**: Matches nginx version (e.g., `1.29.1`)
- **Container Updates**: Additional patch versions for container-specific updates
- **Security Updates**: Immediate releases for security patches

## Roadmap

### Current Focus (Phase 2)

- [ ] Enhanced security hardening and compliance features
- [ ] Performance benchmarking against commercial solutions
- [ ] Enterprise governance and security certifications
- [ ] Advanced monitoring and observability features

### Future Plans

- [ ] Multi-architecture support (ARM64, s390x)
- [ ] Additional nginx modules and enterprise features
- [ ] Kubernetes operator integration
- [ ] SBOM and vulnerability scanning automation
- [ ] Industry compliance certifications (SOC2, FedRAMP, etc.)

## Competitive Advantages

### vs Commercial Hardened Solutions

- **🔍 Transparency**: Complete visibility into build process and security measures
- **⚡ Speed**: Faster security updates with direct upstream sources
- **💰 Cost**: No licensing fees or vendor lock-in
- **🔧 Customization**: Full control over configuration and features
- **🤝 Community**: Open development with community contributions
- **📊 Compliance**: Built-in SBOM generation and vulnerability reporting

## License & Legal

- **Container**: Apache 2.0 License
- **NGINX**: 2-clause BSD License
- **Copyright**: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

This project is not affiliated with F5 Networks or the official nginx project, but builds upon and contributes back to the nginx open source community.

---

### Built with ❤️ by the Broadsage community

*Part of the [Broadsage Open Source Container Initiative](https://github.com/broadsage/containers)*
