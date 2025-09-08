<!--
SPDX-FileCopyri4. **✍️ Make** your changes
5. **✅ Test**: `make dev CONTAINER=nginx`
6. **📝 Submit** a pull requestText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Contributing

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?style=flat&logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![DCO - developer certificate of origin](https://img.shields.io/badge/DCO-Developer%20Certificate%20of%20Origin-lightyellow?style=flat)](https://developercertificate.org/)

Welcome! 👋 We're excited you want to contribute to Broadsage Containers!

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
Email: [security@broadsage.com](mailto:security@broadsage.com)

## ❓ Getting Help

**Quick Questions:** [GitHub Discussions](../../discussions) | **Bugs:** [Create Issue](../../issues/new) | **Security:** [security@broadsage.com](mailto:security@broadsage.com)

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
