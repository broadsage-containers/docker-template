<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Contributing to Broadsage Open Source Containers

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?style=flat&logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![DCO - developer certificate of origin](https://img.shields.io/badge/DCO-Developer%20Certificate%20of%20Origin-lightyellow?style=flat)](https://developercertificate.org/)

Welcome! 👋 We're excited you want to contribute to Broadsage's open source container initiative!

This project is part of Broadsage's commitment to fostering open source innovation in the container ecosystem. We welcome contributors from all backgrounds and experience levels to help build production-ready, community-driven container solutions.

## 🚀 Quick Start

**First time contributor?** Here's the fastest way to get started:

1. **🍴 Fork** this repository
2. **📝 Create** an issue or pick an existing one
3. **🌿 Create** a branch: `git checkout -b fix/your-issue`
4. **✍️ Make** your changes
5. **✅ Test**: `task dev CONTAINER=nginx`
6. **� Submit** a pull request

**Need help?** Check [Getting Help](#-getting-help) or ask in [Discussions](../../discussions).

## 🎯 Ways to Contribute

- � **Report bugs** - Found something broken?
- ✨ **Request features** - Have a great idea?
- 🔧 **Fix issues** - Ready to code?
- 📚 **Improve docs** - Help others learn
- 🆕 **Add containers** - New image needed?

## 📋 Contribution Process

### 1. Issue Creation

Before starting work:

- **Check existing issues** to avoid duplication
- **Create an issue** describing your proposed changes
- **Get feedback** from maintainers before major changes
- **Use appropriate labels** (bug, enhancement, security, etc.)

### 2. Branch Strategy

We use a GitHub Flow model:

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/issue-description

# Keep branch updated
git pull upstream main
git merge upstream/main
```

### 3. Pull Request Process

1. **Push your branch**

   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Use the pull request template
   - Reference related issues
   - Provide clear description of changes
   - Include testing evidence

3. **Code Review**
   - Address reviewer feedback
   - Keep PR focused and small
   - Ensure CI/CD passes

4. **Merge Process**
   - Maintainer will merge after approval
   - Squash and merge for clean history

## 🐳 Container Development Standards

### Base Image Requirements

- **Official base images** preferred (debian, ubuntu, alpine)
- **Specific versions** (no `latest` tags)
- **Security updates** applied
- **Minimal attack surface** (remove unnecessary packages)

### Dockerfile Best Practices

```dockerfile
# Use specific base image versions
FROM debian:12-slim

# Set maintainer label
LABEL maintainer="opensource@broadsage.com"

# Use non-root user
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser appuser

# Install packages in single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER appuser
```

### Testing Requirements

All containers must pass:

- **Unit Tests** - Container build and basic functionality
- **Integration Tests** - Multi-container scenarios
- **Security Tests** - Vulnerability scans and compliance
- **Performance Tests** - Resource usage and benchmarks

```bash
# Test your container
make test CONTAINER=nginx VERSION=1.29
```

## ⚡ Development Setup

```bash
# 1. Install prerequisites
brew install docker

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/containers.git
cd containers

# 3. Test the setup
make help
make build CONTAINER=nginx
```

### Repository Structure

```text
containers/
├── library/                   # Container definitions
│   └── nginx/                # Application containers
│       ├── README.md         # Application documentation
│       ├── docker-compose.yml # Testing configuration
│       └── 1.29/             # Version directory
│           └── debian-12/    # OS variant
├── docs/                     # Project documentation
├── scripts/                  # Automation scripts
└── tests/                    # Test suites
```

### Local Testing

Each container can be tested locally using the included Docker Compose files:

```bash
cd library/nginx/1.29/debian-12
docker compose up --build
```

## 📝 Commit Requirements

**Keep it simple:** Your commits must follow this format:

```text
type: description

Examples:
feat: add nginx 1.29 support
fix: resolve docker build issue
docs: update README
```

**Full details:** See our [Commit Guide](docs/conventional-commits.md)

## 🔍 Pull Request Checklist

- [ ] **Title follows format**: `type: description` (e.g., `feat: add nginx 1.29`)
- [ ] **Signed commits**: Use `git commit -s -m "your message"`
- [ ] **Tests pass**: Run `make test CONTAINER=your-container`
- [ ] **PR template filled**: Use appropriate template from `.github/PULL_REQUEST_TEMPLATE/`

## 🏷️ Auto-Labeling

Our bot automatically adds labels based on your PR title:

- `feat: ...` → `type: feature`
- `fix: ...` → `type: fix`
- `docs: ...` → `type: docs`
- `feat(nginx): ...` → `type: feature` + `scope: nginx`

## 🔒 Security

**Found a vulnerability?** 🚨 **Don't create a public issue!**

See our [Communication Guide](docs/communication.md#-email-contacts) for secure reporting channels.

## ❓ Getting Help

**Need assistance?** See our [Communication Guide](docs/communication.md) for all support channels and contact information.

## 🎉 Recognition

We value all contributions! Contributors are recognized through:

- **Contributor acknowledgments** in release notes
- **Community highlights** in project communications  
- **Professional networking** within the container security community
- **Skill development** through mentorship and guidance

## 📋 FAQ

**Q: How long does the review process take?**  
A: Simple changes are typically reviewed within 2-3 business days. Complex changes may take up to a week.

**Q: How do I add a new container?**  
A: Create an issue proposing the new container, get maintainer approval, then follow our container development standards.

**Q: How do I become a maintainer?**  
A: See our [MAINTAINERS.md](MAINTAINERS.md) file for the maintainer nomination process and requirements.

## 📚 Detailed Guides

**Need more detail?** We have comprehensive guides for advanced contributors:

- **[Detailed Development Workflow](docs/contributing-detailed.md)** - In-depth development process
- **[Conventional Commits Guide](docs/conventional-commits.md)** - Complete commit format rules
- **[Branch Naming Convention](docs/branch-naming.md)** - Branch naming standards  
- **[Auto-Label System](docs/auto-label-system.md)** - How our labeling works
- **[Image Standards](docs/image-standards.md)** - Container requirements
- **[Security Policy](SECURITY.md)** - Vulnerability process

## 📄 License

By contributing, you agree your code will be licensed under [Apache 2.0](LICENSE).

---

**Ready to contribute?** 🚀 Start with an [issue](../../issues) or join the [discussion](../../discussions)!
