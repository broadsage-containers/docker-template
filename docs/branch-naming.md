<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Branch Naming Convention Guide

This repository enforces conventional branch naming to maintain consistency, enable automated workflows, and improve collaboration.

## 📋 Format Requirements

### Standard Branch Names

All feature branches MUST follow this format:

```text
<type>/<description>
```

Where:

- `<type>` is one of the conventional commit types
- `<description>` is lowercase, hyphen-separated description

### 🎯 Valid Types

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
| `revert` | Revert changes | Reverting previous changes |

### 🚨 Special Branch Types

| Pattern | Description | Example |
|---------|-------------|---------|
| `hotfix/<description>` | Emergency fixes | `hotfix/security-vulnerability` |
| `release/v<version>` | Release preparation | `release/v1.2.3` |
| `<username>/<type>/<description>` | User feature branches | `john/feat/user-auth` |

### ✅ Valid Examples

```text
feat/user-authentication
fix/docker-build-issue
docs/update-readme
refactor/api-endpoints
chore/update-dependencies
test/integration-tests
ci/github-actions
build/webpack-config
perf/optimize-queries
style/format-code
hotfix/critical-security-fix
release/v2.1.0
jane/feat/new-dashboard
```

### ❌ Invalid Examples

```text
FEAT/user-auth          # ❌ Uppercase type
feature/user_auth       # ❌ Wrong type, underscore
fix-bug                 # ❌ Missing slash separator
fix/User Authentication # ❌ Spaces, mixed case
user-auth               # ❌ Missing type
fix/                    # ❌ Empty description
fix/user@auth           # ❌ Special characters
```

## 🛠️ Branch Management

### Creating New Branches

```bash
# From main branch
git checkout main
git pull origin main

# Create new feature branch
git checkout -b feat/your-description
```

### Renaming Existing Branches

If your branch doesn't follow the convention:

```bash
# Rename local branch
git branch -m old-branch-name feat/new-description

# Push renamed branch and set upstream
git push origin -u feat/new-description

# Delete old branch from remote
git push origin --delete old-branch-name
```

### Branch Lifecycle

1. **Create** branch with conventional name
2. **Work** on your changes
3. **Push** regularly to keep remote updated
4. **Create PR** when ready (PR title must also follow conventional commits)
5. **Merge** after review and all checks pass
6. **Delete** branch after merge

## 🔒 Enforcement

Branch naming is enforced through:

- **Automated validation** on PR creation and push events
- **Required status checks** that must pass before merging
- **Branch protection rules** preventing direct pushes to protected branches
- **Bot comments** providing helpful guidance on invalid names

### Validation Rules

The system validates branches using these patterns:

1. **Standard**: `<type>/<description>` (lowercase, hyphens only)
2. **Hotfix**: `hotfix/<description>`
3. **Release**: `release/v<version>`
4. **User branches**: `<username>/<type>/<description>`
5. **Protected branches**: `main`, `master`, `develop` (always allowed)
6. **Bot branches**: `dependabot/*`, `github-actions/*` (always allowed)

## 🤖 Automation Integration

Branch names are used to:

- **Auto-label PRs** based on type
- **Route to appropriate reviewers**
- **Trigger specific workflows**
- **Generate release notes**
- **Determine semantic version bumps**

### Auto-Applied Labels

| Branch Pattern | Applied Labels |
|----------------|----------------|
| `feat/*` | `type: feature` |
| `fix/*` | `type: bug` |
| `docs/*` | `type: docs` |
| `hotfix/*` | `type: bug`, `priority: high` |
| `chore/*` | `type: maintenance` |
| `ci/*`, `build/*` | `area/build` |

## 💡 Best Practices

### Naming Guidelines

1. **Be descriptive but concise**
   - ✅ `feat/oauth-integration`
   - ❌ `feat/new-feature`

2. **Use present tense verbs**
   - ✅ `fix/resolve-login-timeout`
   - ❌ `fix/resolved-login-timeout`

3. **Avoid redundancy**
   - ✅ `docs/api-reference`
   - ❌ `docs/update-api-docs`

4. **Use domain-specific terms**
   - ✅ `refactor/user-repository`
   - ❌ `refactor/cleanup-stuff`

### Branch Organization

- Keep branches **short-lived** (days, not weeks)
- **Merge frequently** to avoid conflicts
- **Delete merged branches** to keep repository clean
- Use **draft PRs** for work-in-progress

## 🔍 Troubleshooting

### Common Issues

**Branch name validation failed?**

- Check for uppercase letters, spaces, or special characters
- Ensure you have a valid type prefix
- Verify description uses hyphens, not underscores

**Can't push to branch?**

- Ensure branch name follows conventions
- Check if branch protection rules are active
- Verify you have proper permissions

**Automation not triggering?**

- Branch name must match exact patterns
- Some workflows only trigger on conventional branch names
- Check if branch is in the ignored list

### Getting Help

If you're unsure about branch naming:

1. Check the validation error message (it includes suggestions)
2. Review this documentation
3. Look at existing branches for examples
4. Ask in team chat or create an issue

---

📚 **Related Documentation:**

- [Conventional Commits Guide](./conventional_commits.md)
- [Pull Request Guidelines](../README.md#pull-requests)
- [Workflow Documentation](../.github/workflows/README.md)
