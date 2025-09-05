<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# containers

Primary source of truth for the Broadsage Container Images

## 🚀 Quick Start

This project uses **Task** for all build, test, and deployment operations.

### Prerequisites

```bash
# Install Task
brew install go-task/tap/go-task

# Verify installation
task --version
```

### Common Commands

```bash
# Show all available commands
task --list

# Build a container
task build CONTAINER=nginx

# Build all containers  
task build

# Test containers
task test CONTAINER=nginx

# Development workflow (build + test)
task dev CONTAINER=nginx

# Full CI pipeline
task ci

# Clean up
task clean
```

## 📁 Project Structure

```bash
containers/
├── .github/workflows/     # CI/CD pipelines
├── broadsage/            # Container definitions
│   └── nginx/           # NGINX container
├── templates/           # Container templates
├── Taskfile.yml        # 🎯 Build automation (Task)
├── MIGRATION_FROM_BASH.md  # Migration guide
└── README.md           # This file
```

## 🛠️ Development

### Build Single Container

```bash
task build CONTAINER=nginx
```

### Test Single Container

```bash
task test CONTAINER=nginx
```

### Security Scan

```bash
task security CONTAINER=nginx
```

### Lint Dockerfiles

```bash
task lint
```

## 🚀 Why Task?

We migrated from bash scripts to Task for:

- ✅ **Modern syntax** - YAML instead of complex bash
- ✅ **Cross-platform** - Works on macOS, Linux, Windows
- ✅ **Better performance** - Built-in parallelization
- ✅ **Superior DX** - IDE integration and auto-completion
- ✅ **Maintainability** - Self-documenting with clear structure

See `MIGRATION_FROM_BASH.md` for detailed migration information.

## 📚 Documentation

- [Task Documentation](https://taskfile.dev/)
- [Container Templates](./templates/README.md)
- [Migration Guide](./MIGRATION_FROM_BASH.md)
- **[🎯 Conventional Commits Guide](./docs/CONVENTIONAL_COMMITS.md)** - PR title requirements

## 🤝 Contributing

### Pull Request Requirements

All PRs must follow our [Conventional Commits](./docs/CONVENTIONAL_COMMITS.md) format:

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
