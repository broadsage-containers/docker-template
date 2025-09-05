<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Conventional Commits Guide

This repository enforces [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles to maintain consistency and enable automated workflows.

## 📋 Format Requirements

### Pull Request Titles

All PR titles MUST follow this format:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 🎯 Valid Types

| Type | Description | Auto-Applied Labels |
|------|-------------|-------------------|
| `feat` | New features | `type: feature` |
| `fix` | Bug fixes | `type: bug` |
| `docs` | Documentation changes | `type: docs` |
| `style` | Code style changes (formatting, etc.) | `type: maintenance` |
| `refactor` | Code refactoring | `type: maintenance` |
| `perf` | Performance improvements | `performance` |
| `test` | Test changes | `type: maintenance` |
| `chore` | Maintenance tasks | `type: maintenance` |
| `ci` | CI/CD changes | `area/build` |
| `build` | Build system changes | `area/build` |
| `revert` | Revert changes | `type: maintenance` |

### 🔧 Optional Scopes

Scopes help categorize the change area and automatically apply additional labels:

| Scope | Auto-Applied Labels |
|-------|-------------------|
| `docker`, `container`, `containers` | `area/containers` |
| `workflow`, `workflows`, `ci` | `area/build` |
| `docs` | `type: docs` |
| `security` | `security` |

### ⚠️ Breaking Changes

Add `!` after the type/scope to indicate breaking changes:

```text
feat!: remove deprecated API
fix(api)!: change response format
```text
This automatically applies the `breaking-change` label.

## 📝 Examples

### ✅ Good Examples
```text
feat: add nginx 1.29 support
fix(docker): resolve build issue in Dockerfile
docs: update README with installation steps
style: format code according to style guide
refactor(workflow): consolidate GitHub actions
perf: optimize image build process
test: add unit tests for nginx configuration
chore: update dependencies to latest versions
ci: add automated security scanning
build: update Docker base images
revert: revert "feat: add experimental feature"
feat(containers)!: change default nginx version
```

### ❌ Bad Examples

```text
Add new feature
Fixed bug
Update docs
WIP: working on new feature
Merge branch 'feature/xyz'
Update
Fix
```

## 🚦 Validation Process

When you create or edit a PR:

1. **Automatic Validation**: The `pr-title-validation` status check validates your PR title
2. **Success**: ✅ Green check allows merging
3. **Failure**: ❌ Red X blocks merging with helpful guidance
4. **Auto-Labeling**: Valid titles automatically get appropriate labels applied

## 🏷️ Auto-Labeling

PR titles that follow conventional commit format automatically receive appropriate labels based on the commit type. For comprehensive details on how the auto-labeling system works, configuration options, and customization instructions, see the [Auto-Label System Documentation](auto-label-system.md).

## 🔒 Branch Protection

The `main` branch is protected and requires:

- ✅ PR title validation passing
- ✅ All tests passing  
- ✅ At least 1 approving review
- ✅ Up-to-date branches

## 🤝 Need Help?

If you're unsure about the format or need assistance:

1. Check the examples above
2. Look at recent merged PRs for reference
3. The validation bot will provide specific guidance
4. Ask in the PR comments for clarification

Remember: Conventional commits help maintain a clean history, enable automated changelog generation, and make it easier to understand the impact of changes! 🎉
