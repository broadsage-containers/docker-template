<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Contributing to Broadsage Open Source Containers

Thank you for your interest in contributing to the Broadsage Open Source Containers project! We welcome contributions from the community and value every contribution, from bug reports to new container implementations.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Contributing Process](#contributing-process)
- [Container Development Guidelines](#container-development-guidelines)
- [Testing Requirements](#testing-requirements)
- [Documentation Guidelines](#documentation-guidelines)
- [Security Guidelines](#security-guidelines)
- [Community Support](#community-support)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](./CODE_OF_CONDUCT.md). Please read it before contributing to ensure a positive and respectful experience for everyone.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Docker**: Version 20.10 or later
- **Git**: For version control
- **Text Editor/IDE**: VS Code recommended with Docker extension
- **Operating System**: Linux, macOS, or Windows with WSL2

### Initial Setup

1. **Fork the Repository**

   Fork the repository on GitHub and clone your fork:

   ```bash
   git clone https://github.com/YOUR_USERNAME/containers.git
   cd containers
   ```

2. **Configure Git**

   ```bash
   git config user.name "Your Name"
   git config user.email "your.email@example.com"
   ```

3. **Add Upstream Remote**

   ```bash
   git remote add upstream https://github.com/broadsage/containers.git
   ```

4. **Verify Docker Installation**

   ```bash
   docker --version
   docker compose --version
   ```

## Development Environment Setup

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

## Contributing Process

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

### 3. Development Workflow

1. **Make Changes**
   - Follow coding standards
   - Include appropriate tests
   - Update documentation

2. **Test Locally**

   ```bash
   # Build and test your container
   make test-container CONTAINER=nginx VERSION=1.29 VARIANT=debian-12

   # Run security scans
   make security-scan CONTAINER=nginx VERSION=1.29 VARIANT=debian-12
   ```

3. **Commit Changes**

   ```bash
   # Use conventional commit format
   git add .
   git commit -m "feat(nginx): add custom configuration support"
   ```

### 4. Pull Request Process

1. **Push Changes**

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

## Container Development Guidelines

### Container Standards

All containers must follow these standards:

#### 1. Base Image Requirements

- **Official base images** preferred (debian, ubuntu, alpine)
- **Specific versions** (no `latest` tags)
- **Security updates** applied
- **Minimal attack surface** (remove unnecessary packages)

#### 2. Dockerfile Best Practices

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

# Use non-root user
USER appuser

# Expose only necessary ports
EXPOSE 8080

# Use exec form for CMD
CMD ["nginx", "-g", "daemon off;"]
```

#### 3. Security Requirements

- **Non-root execution** (required)
- **Read-only root filesystem** (when possible)
- **Minimal privileges** (no unnecessary capabilities)
- **Secret management** (no hardcoded credentials)
- **CVE scanning** (must pass security scans)

#### 4. Configuration Management

- **Environment variables** for configuration
- **Configuration files** in `/opt/bitnami/app/conf/`
- **Data persistence** in `/bitnami/app/data/`
- **Log output** to stdout/stderr

### Version Management

Each container supports multiple versions:

```text
library/nginx/
├── 1.28/           # Older stable version
└── 1.29/           # Current stable version
    ├── debian-12/  # Default variant
    └── alpine-3.18/  # Alternative variant
```

### Documentation Requirements

Each container must include:

1. **README.md** - Usage instructions and examples
2. **CHANGELOG.md** - Version history and changes
3. **docker-compose.yml** - Example configuration
4. **Security documentation** - Known issues and mitigations

## Testing Requirements

### Test Categories

1. **Unit Tests** - Container build and basic functionality
2. **Integration Tests** - Multi-container scenarios
3. **Security Tests** - Vulnerability scans and compliance
4. **Performance Tests** - Resource usage and benchmarks

### Running Tests

```bash
# All tests for a container
make test CONTAINER=nginx VERSION=1.29

# Specific test categories
make test-unit CONTAINER=nginx VERSION=1.29
make test-integration CONTAINER=nginx VERSION=1.29
make test-security CONTAINER=nginx VERSION=1.29
make test-performance CONTAINER=nginx VERSION=1.29
```

### Test Requirements

- **All tests must pass** before merge
- **New features require tests**
- **Security tests are mandatory**
- **Performance regression tests** for critical containers

## Documentation Guidelines

### Writing Standards

- **Clear and concise** language
- **Step-by-step instructions** for complex procedures
- **Code examples** with expected outputs
- **Security considerations** highlighted
- **Regular updates** to maintain accuracy

### Documentation Types

1. **User Documentation** - How to use containers
2. **Developer Documentation** - How to contribute
3. **API Documentation** - Environment variables and endpoints
4. **Security Documentation** - Hardening and compliance

## Security Guidelines

### Security First Approach

Security is our top priority. All contributions must:

1. **Follow security best practices**
2. **Pass security scans**
3. **Include threat model considerations**
4. **Document security implications**

### Reporting Security Issues

**DO NOT** create public issues for security vulnerabilities.

See our [Communication Guide](docs/communication.md) for security reporting procedures.

### Security Review Process

All security-related changes undergo additional review:

1. **Security team review** (required)
2. **Penetration testing** (for major changes)
3. **Compliance verification** (regulatory requirements)
4. **Documentation updates** (security implications)

## Community Support

For all communication and support options, see our comprehensive [Communication Guide](docs/communication.md).

### Quick Reference

The guide covers:

- **GitHub channels** (Issues, Discussions) with usage guidelines
- **Email contacts** for specific needs (security, business, governance)  
- **Response times** and expectations
- **Community guidelines** and best practices

### Recognition

We recognize contributors through:

- **Contributor acknowledgments** in release notes
- **Community highlights** in project communications
- **Speaking opportunities** at conferences and meetups
- **Professional networking** within the container security community
- **Skill development** through mentorship and guidance

## FAQ

### Q: How do I add a new container?

A: Create an issue proposing the new container, get maintainer approval, then follow the container development guidelines to implement it.

### Q: How long does the review process take?

A: Simple changes are typically reviewed within 2-3 business days. Complex changes may take up to a week.

### Q: Can I contribute documentation improvements?

A: Absolutely! Documentation improvements are highly valued and follow the same contribution process.

### Q: What if my PR fails CI/CD checks?

A: Review the failure logs, fix the issues, and push updates. Maintainers can help if you're stuck.

### Q: How do I become a maintainer?

A: See our [MAINTAINERS.md](./MAINTAINERS.md) file for the maintainer nomination process and requirements.

---

*Thank you for contributing to making container security accessible and reliable for everyone!*
