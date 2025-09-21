<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Development Guide

This guide contains everything you need to know about contributing to the Broadsage Container project.

## 🚀 Quick Start for Contributors

1. **Fork the repository** and clone your fork
2. **Create a feature branch** following our naming conventions
3. **Make your changes** following our coding standards
4. **Test your changes** locally
5. **Submit a pull request** with a conventional commit title

## 📋 Branch Naming Convention

All feature branches MUST follow this format:

```text
<type>/<description>
```

### Valid Types

| Type | Description | Use When |
|------|-------------|----------|
| `feat` | New features | Adding new functionality |
| `fix` | Bug fixes | Fixing issues or bugs |
| `docs` | Documentation changes | Updating documentation |
| `style` | Code style changes | Formatting, whitespace, etc. |
| `refactor` | Code refactoring | Restructuring without changing behavior |
| `perf` | Performance improvements | Optimizing performance |
| `test` | Test changes | Adding or modifying tests |
| `chore` | Maintenance tasks | Dependency updates, tooling |
| `ci` | CI/CD changes | Workflow modifications |
| `build` | Build system changes | Build configuration updates |

### Examples

✅ **Good branch names:**

```text
feat/nginx-1.29-support
fix/docker-build-memory-leak
docs/update-contributing-guide
refactor/simplify-ansible-roles
```

❌ **Bad branch names:**

```text
patch-1
my-changes
update
john-feature
```

## 🏷️ Pull Request Titles

All PR titles MUST follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```text
<type>[optional scope]: <description>
```

### Valid Types & Auto-Labels

| Type | Description | Auto-Applied Labels |
|------|-------------|-------------------|
| `feat` | New features | `type: feature` |
| `fix` | Bug fixes | `type: bug` |
| `docs` | Documentation changes | `type: docs` |
| `style` | Code style changes | `type: maintenance` |
| `refactor` | Code refactoring | `type: maintenance` |
| `perf` | Performance improvements | `performance` |
| `test` | Test changes | `type: maintenance` |
| `chore` | Maintenance tasks | `type: maintenance` |
| `ci` | CI/CD changes | `area/build` |
| `build` | Build system changes | `area/build` |

### Optional Scopes

Scopes help categorize changes and automatically apply additional labels:

| Scope | Auto-Applied Labels |
|-------|-------------------|
| `docker`, `container` | `area/containers` |
| `workflow`, `ci` | `area/build` |
| `docs` | `type: docs` |
| `security` | `security` |

### PR Title Examples

✅ **Good PR titles:**

```text
feat: add nginx 1.29 support
fix(docker): resolve memory leak in build process
docs: update installation instructions
perf(build): optimize multi-platform builds
feat(security)!: implement mandatory image signing
```

## 🤖 Auto-Label System

Our auto-labeling system applies labels based on PR titles using Conventional Commits:

### How It Works

1. **PR Title Analysis**: System parses your PR title for conventional commit format
2. **Type Detection**: Identifies the commit type (feat, fix, docs, etc.)
3. **Scope Detection**: Looks for optional scope in parentheses
4. **Label Application**: Automatically applies relevant labels
5. **Breaking Changes**: Detects `!` for breaking change labels

### Label Categories

- **Type Labels**: `type: feature`, `type: bug`, `type: docs`
- **Area Labels**: `area/containers`, `area/build`, `area/security`
- **Special Labels**: `breaking-change`, `performance`, `security`

### Configuration

The system is configured in `.github/auto-label-config.json` with:

- **Conventional Commits**: Maps commit types to labels
- **Scope Detection**: Maps scopes to area labels  
- **Breaking Changes**: Detects `!` indicator
- **Validation**: Ensures PR titles follow conventions

## 🔧 Development Workflow

### 1. Setting Up Your Environment

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/docker-template.git
cd docker-template

# Install dependencies
make check-containers  # Verify Docker/Podman

# Run compliance checks
make check-compliance
```

### 2. Making Changes

- Follow existing code patterns and conventions
- Update documentation for any new features
- Add tests for new functionality
- Run local validation before committing

### 3. Testing Your Changes

```bash
# Test template generation
./entrypoint.sh

# Run compliance checks
make check-compliance

# Validate configurations
node scripts/validate-auto-label-config.js
```

### 4. Submitting Changes

1. **Create feature branch** with proper naming
2. **Write conventional commit messages**
3. **Test your changes locally**
4. **Push to your fork**
5. **Create PR with conventional title**
6. **Address review feedback**

## 📞 Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions, ideas, and community discussion
- **Pull Requests**: Code contributions and reviews

## 🛠️ Build System

We use **Make** for build automation:

- ✅ **Cross-platform**: Works on macOS, Linux, Windows
- ✅ **Simple syntax**: Easy to understand and maintain  
- ✅ **Standard tooling**: No additional dependencies required
- ✅ **IDE integration**: Built-in support in most editors

### Common Make Targets

```bash
make help                # Show all available targets
make check-compliance   # Run quality and compliance checks
make check-docker       # Verify Docker installation
make check-podman       # Verify Podman installation
```

## 🔍 Code Review Process

### For Contributors

1. **Self-review** your changes before submitting
2. **Respond promptly** to review feedback
3. **Make requested changes** in additional commits
4. **Squash commits** if requested by maintainers

### For Reviewers

1. **Focus on code quality** and consistency
2. **Provide constructive feedback** with examples
3. **Approve when ready** or request specific changes
4. **Help newcomers** understand project conventions

## 🏗️ Project Structure

```text
docker-template/
├── ansible/                    # Template generation system
│   ├── roles/repository/      # Main repository generation role
│   └── generate-project.yml   # Template generation playbook
├── docs/                      # Documentation (you are here!)
├── .github/                   # GitHub workflows and templates
│   ├── workflows/             # CI/CD pipelines
│   └── ISSUE_TEMPLATE/        # Issue templates
├── config/                    # Configuration files
└── scripts/                   # Utility scripts
```

## 📚 Additional Resources

- [Security Policy](SECURITY.md) - Security guidelines and verification
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community guidelines
- [Support](SUPPORT.md) - Getting help and support
- [Contributing](CONTRIBUTING.md) - Detailed contribution guidelines
