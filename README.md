<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Docker Template Generator

[![GitHub license](https://img.shields.io/github/license/broadsage/containers)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![REUSE compliance](https://img.shields.io/reuse/compliance/github.com%2Fbroadsage%2Fcontainers)](https://reuse.software/)
[![Security Scanning](https://img.shields.io/badge/security-hardened-green)](docs/SECURITY.md)

**Generate production-ready, security-hardened container projects with enterprise-grade CI/CD pipelines.**

This template generator creates complete container repositories with built-in security, compliance, and automation features - designed to compete with commercial container platforms like Bitnami and Red Hat.

## 🚀 Quick Start

### 1. Create Your Project Configuration

Create a `project.yml` file:

```yaml
---
organization: "my-company"
project:
  name: "my-nginx"
  description: "Custom NGINX container with security hardening"
maintainer:
  name: "Your Name"
  email: "you@example.com"
```

### 2. Generate Your Project

Using Docker:

```bash
docker run --rm -v $(pwd):/workspace ghcr.io/broadsage/docker-template
```

Using Podman:

```bash
podman run --rm -v $(pwd):/workspace ghcr.io/broadsage/docker-template
```

### 3. What You Get

Your generated project includes:

- ✅ **Multi-platform builds** (13+ architectures)
- ✅ **Security scanning** with Trivy and vulnerability management
- ✅ **Image signing** with Cosign and SBOM generation
- ✅ **GitHub Actions** with automated testing and publishing
- ✅ **Compliance automation** with REUSE, mega-linter, and conventional commits
- ✅ **Enterprise features** like dependency management and auto-updates

## 🏆 Enterprise-Grade Features

### Security & Compliance

- **Supply Chain Security**: SLSA attestations, Cosign signing, SBOM generation
- **Zero CVE Policy**: Automated vulnerability scanning and patching
- **Compliance Ready**: REUSE, conventional commits, and governance automation
- **Multi-Architecture**: Native support for AMD64, ARM64, and 11 other platforms

### Automation & CI/CD

- **Intelligent Workflows**: Multi-stage pipelines with approval gates
- **Auto-Updates**: Dependabot integration with security prioritization
- **Quality Gates**: Comprehensive testing, linting, and validation
- **Release Management**: Semantic versioning and automated releases

## 📚 Documentation

- **[Development Guide](docs/DEVELOPMENT.md)** - Contributing, workflows, and conventions
- **[Security Guide](docs/SECURITY.md)** - Image verification, vulnerability management, and security standards
- **[Contributing Guidelines](CONTRIBUTING.md)** - How to contribute to this project

## 🤝 Contributing

We welcome contributions! See our [Development Guide](docs/DEVELOPMENT.md) for:

- Branch naming conventions
- Pull request requirements
- Auto-labeling system
- Development workflow

### Quick Contributing Steps

1. **Fork** the repository
2. **Create feature branch**: `feat/your-feature-name`
3. **Make changes** following our standards
4. **Submit PR** with conventional title: `feat: add your feature`

## 💡 Why Use This Template?

### vs. Manual Setup

- **10x Faster**: Generate in minutes, not days
- **Best Practices**: Enterprise security and compliance built-in
- **Consistency**: Standardized structure across all projects

### vs. Commercial Alternatives

- **Open Source**: Transparent, community-driven development
- **Full Control**: No vendor lock-in, customize everything
- **Enterprise-Ready**: Match features of paid solutions

### vs. Basic Templates

- **Production-Ready**: Real-world tested with enterprise features
- **Security-First**: Built-in vulnerability management and signing
- **Automation**: Complete CI/CD with minimal configuration

## 📞 Support

- **Issues**: [Report bugs or request features](https://github.com/broadsage/containers/issues)
- **Discussions**: [Community support and questions](https://github.com/broadsage/containers/discussions)
- **Security**: [Report vulnerabilities](docs/SECURITY.md)

## 📄 License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details.

---

*Built by [Broadsage](https://github.com/broadsage) • Join our mission to democratize enterprise-grade container infrastructure*
