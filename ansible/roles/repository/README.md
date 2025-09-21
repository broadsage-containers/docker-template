<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Docker Repository Generator Role

## Overview

This Ansible role is the core template generator that creates complete, production-ready Docker container repositories with enterprise-grade security, CI/CD, and governance features. It's designed to rapidly scaffold new container projects with all the necessary infrastructure and best practices built-in.

## What This Role Does

This role generates a complete Docker container repository structure including:

- **Project Structure**: Complete directory layout with industry-standard organization
- **CI/CD Pipelines**: GitHub Actions workflows for building, testing, and publishing containers
- **Security Features**: Cosign signing, SLSA attestations, vulnerability scanning
- **Documentation**: Auto-generated README, contributing guidelines, and project docs  
- **Governance**: Issue templates, PR templates, code of conduct, security policies
- **Container Templates**: Multi-stage Dockerfiles with security hardening
- **Build System**: Make-based build automation with cross-platform support

## Key Features & Benefits

### 🚀 **Rapid Scaffolding**

- Generates complete repository in seconds
- No manual configuration needed - everything is pre-configured
- Consistent structure across all generated repositories

### 🛡️ **Enterprise Security**

- Built-in Cosign image signing
- SLSA Level 3 attestations
- Automated vulnerability scanning
- Security-hardened Dockerfiles

### 🏗️ **Production Ready**

- Multi-platform builds (13+ architectures)
- Comprehensive CI/CD pipelines
- Automated dependency management
- Performance optimization

### 📋 **Governance & Compliance**

- Complete governance model built-in
- REUSE compliance for licensing
- Conventional commit enforcement
- Automated issue/PR management

## Requirements

- **Ansible**: Version 2.1 or higher
- **Templates**: Requires template files in `templates/` directory
- **Project Config**: Requires `project.yml` configuration file

## Role Variables

### Core Configuration

```yaml
# Project identification
project: "docker-nginx"              # Project name
organization: "broadsage-containers" # GitHub organization
description: "High-performance web server"

# Build configuration  
build_platforms: "linux/amd64,linux/arm64"
registry_url: "ghcr.io"
image_namespace: "broadsage"

# Security settings
enable_security_scanning: true
enable_cosign_signing: true  
enable_slsa_attestations: true

# CI/CD features
enable_pr_validation: true
enable_auto_merge: false
enable_stale_management: true
```

### Maintainer Information

```yaml
maintainer_name: "Your Name"
maintainer_email: "your.email@domain.com"  
copyright_holder: "Your Organization"
copyright_year: "2025"
```

### Customization Options

```yaml
# Development tools
install_precommit: true
enable_dependabot: true

# License and compliance  
license_type: "Apache-2.0"

# Template metadata
template_version: "v1.0.0"
template_date: "2025-09-19"
```

## Usage Example

### Basic Usage

```yaml
- name: Generate Docker container repository
  hosts: localhost
  connection: local
  roles:
    - repository
  vars:
    project: "docker-nginx"
    path: "/workspace"
    maintainer_name: "John Doe"
    maintainer_email: "john@example.com"
```

### Advanced Configuration

```yaml
- name: Generate custom container repository  
  hosts: localhost
  connection: local
  roles:
    - repository
  vars:
    project: "docker-postgresql"
    path: "/tmp/docker-postgresql"
    organization: "mycompany"
    description: "Advanced PostgreSQL container"
    build_platforms: "linux/amd64,linux/arm64,linux/arm/v7"
    enable_auto_merge: true
    install_precommit: false
```

## Generated Repository Structure

```text
generated-repository/
├── .github/
│   ├── workflows/           # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/      # Issue templates  
│   └── PULL_REQUEST_TEMPLATE/ # PR templates
├── containers/
│   └── [project-name]/      # Container implementation
├── config/
│   ├── cosign/             # Signing configurations
│   └── linting/            # Code quality configs
├── docs/
│   └── architecture/       # Architecture decisions
├── scripts/                # Utility scripts
├── README.md              # Project documentation
├── CONTRIBUTING.md        # Contributor guidelines
├── SECURITY.md           # Security policy
└── LICENSE              # License information
```

## Why This Approach is Powerful

### 1. **Template-Driven Scalability**

Unlike manually maintaining multiple repositories, this role enables:

- Rapid creation of 100+ container repositories
- Consistent structure and standards
- Easy updates across all projects

### 2. **Enterprise-Grade from Day 1**

Every generated repository includes:

- Security scanning and signing
- Multi-architecture builds  
- Compliance automation
- Production monitoring

### 3. **Community-Ready**

Generated repositories include:

- Complete governance model
- Contributor onboarding
- Issue management automation
- Professional documentation

### 4. **Competitive Advantage**

This template system provides advantages over competitors:

- **vs Docker Official**: More comprehensive, enterprise-focused
- **vs Bitnami**: Automated generation, not manual maintenance  
- **vs Red Hat UBI**: Open source with equivalent security
- **vs Chainguard**: Broader application support

## Dependencies

This role depends on:

- Jinja2 templating (built into Ansible)
- Template files in `templates/` directory
- Configuration variables from `project.yml`

## License

MIT-0 (Public Domain equivalent)

## Contact Information

- **Project**: Broadsage Open Source Containers
- **Repository**: [docker-template](https://github.com/broadsage-containers/docker-template)
- **Issues**: [GitHub Issues](https://github.com/broadsage-containers/docker-template/issues)
- **Discussions**: [GitHub Discussions](https://github.com/broadsage-containers/docker-template/discussions)
