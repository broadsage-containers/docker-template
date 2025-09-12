<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Broadsage Open Source Containers

[![GitHub license](https://img.shields.io/github/license/broadsage/containers)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![REUSE compliance](https://img.shields.io/reuse/compliance/github.com%2Fbroadsage%2Fcontainers)](https://reuse.software/)
[![Security Scanning](https://img.shields.io/badge/security-hardened-green)](SECURITY.md)

## Enterprise-grade, security-hardened container images for modern applications

This open source project provides production-ready, security-focused container images for popular applications and services. Our goal is to create containers that are transparent, maintainable, and suitable for enterprise deployments while remaining community-driven.

## 🎯 Project Mission

Broadsage is committed to fostering open source innovation in the container ecosystem. This initiative provides enterprise-grade alternatives to commercial hardened container solutions:

- **Security-Hardened**: Enterprise-grade security with minimal attack surface and comprehensive hardening
- **Production-Ready**: Battle-tested containers suitable for mission-critical deployments
- **Multi-Application**: Support for web servers, databases, message queues, and application frameworks
- **CVE-Responsive**: Rapid security updates and vulnerability management
- **Enterprise-Grade**: Suitable for regulated industries and high-security environments
- **Community-Driven**: Open development with transparent decision-making and community contributions

## � Supported Containers

We provide enterprise-grade, security-hardened versions of popular applications:

### Web Servers & Reverse Proxies

- **[nginx](library/nginx/)** - High-performance web server and reverse proxy
- **httpd** - Apache HTTP Server *(coming soon)*
- **traefik** - Modern reverse proxy and load balancer *(planned)*

### Databases

- **mongodb** - Document-oriented NoSQL database *(coming soon)*
- **cassandra** - Distributed NoSQL database *(coming soon)*
- **postgresql** - Advanced open source relational database *(planned)*
- **mysql** - Popular relational database *(planned)*
- **redis** - In-memory data structure store *(planned)*

### Application Frameworks

- **node** - JavaScript runtime environment *(planned)*
- **python** - Python application runtime *(planned)*
- **openjdk** - Java development kit and runtime *(planned)*

### Message Queues & Streaming

- **rabbitmq** - Message broker *(planned)*
- **kafka** - Distributed event streaming platform *(planned)*

*Each container includes comprehensive security hardening, performance optimization, and enterprise-ready features.*

## 🚀 Quick Start

### Prerequisites

```bash
# Verify make is installed
make --version

# Verify docker is installed
docker --version
```

### Common Commands

```bash
# Show all available commands
make help

# Build specific containers
make build CONTAINER=nginx
make build CONTAINER=mongodb    # when available
make build CONTAINER=postgresql # when available

# Test containers
make test CONTAINER=nginx
make test                       # test all containers

# Development workflow (build + test)
make dev CONTAINER=nginx

# Full CI pipeline (all containers)
make ci

# Clean up build artifacts
make clean
```

### Quick Container Usage

```bash
# NGINX web server
docker run -p 80:80 ghcr.io/broadsage/nginx:1.29

# MongoDB (example - coming soon)
docker run -p 27017:27017 ghcr.io/broadsage/mongodb:7.0

# PostgreSQL (example - planned)
docker run -p 5432:5432 -e POSTGRES_PASSWORD=mypassword ghcr.io/broadsage/postgresql:16
```

## 📁 Project Structure

```bash
containers/
├── .github/workflows/     # CI/CD pipelines
├── library/              # Container definitions
│   └── nginx/           # NGINX container
├── scripts/             # Build and utility scripts
├── Makefile            # 🎯 Build automation
└── README.md           # This file
```

## 🛠️ Development

### Build Single Container

```bash
make build CONTAINER=nginx
```

### Test Single Container

```bash
make test CONTAINER=nginx
```

### Security Scan

```bash
make security CONTAINER=nginx
```

### Lint Dockerfiles

```bash
make lint
```

## �️ Build System

We use **Make** for build automation:

- ✅ **Cross-platform** - Works on macOS, Linux, Windows
- ✅ **Simple syntax** - Easy to understand and maintain  
- ✅ **Standard tooling** - No additional dependencies required
- ✅ **Proven reliability** - Time-tested build system
- ✅ **IDE integration** - Built-in support in most editors

## 📚 Documentation

- [Contributing Guidelines](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)

## 🤝 Contributing

We welcome contributions from the community! See our [Contributing Guide](CONTRIBUTORS.md) for detailed information on how to get started.

### Quick Start for Contributors

1. **Read the Guidelines**: Start with [CONTRIBUTORS.md](CONTRIBUTORS.md)
2. **Check Communication Channels**: See [docs/communication.md](docs/communication.md)
3. **Follow Our Standards**: Review coding and PR conventions below
4. **Join the Community**: See our [Communication Guide](docs/communication.md) for all community channels

### Pull Request Requirements

All PRs must follow our conventions:

#### Branch Names

Follow our [Branch Naming Guide](./docs/branch_naming.md):

```text
feat/user-authentication
fix/docker-build-issue
docs/update-readme
```

#### PR Titles

Follow our [Conventional Commits](./docs/CONVENTIONAL_COMMITS.md) format:

```text
feat: add nginx 1.29 support
fix(docker): resolve build issue  
docs: update README
```

**Why?** This enables:

- 🏷️ **Automatic labeling** - PRs get correct labels applied
- 📋 **Clean history** - Consistent commit messages
- 🚀 **Automated releases** - Semantic versioning support

**Validation**: The `pr-title-validation` check will guide you if your title doesn't match the required format.
