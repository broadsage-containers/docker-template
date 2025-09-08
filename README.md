<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# containers

[![GitHub license](https://img.shields.io/github/license/broadsage/containers)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![REUSE compliance](https://img.shields.io/reuse/compliance/github.com%2Fbroadsage%2Fcontainers)](https://reuse.software/)
[![Security Scanning](https://img.shields.io/badge/security-scanned-green)](SECURITY.md)

Primary source of truth for Broadsage Containers

## 🚀 Quick Start

This project provides container images with build automation using Make.

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

# Build a container
make build CONTAINER=nginx

# Test containers
make test CONTAINER=nginx

# Development workflow (build + test)
make dev CONTAINER=nginx

# Full CI pipeline
make ci

# Clean up
make clean
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
