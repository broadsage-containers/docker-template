<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Auto-Label System Documentation

This document provides comprehensive information about the simplified auto-labeling system for issues and pull requests based on Conventional Commits.

## 📋 **Table of Contents**

- [Overview](#overview)
- [Configuration Structure](#configuration-structure)
- [How It Works](#how-it-works)
- [Supported Commit Types](#supported-commit-types)
- [Scope Detection](#scope-detection)
- [Breaking Changes](#breaking-changes)
- [Examples](#examples)
- [Validation and Testing](#validation-and-testing)
- [Troubleshooting](#troubleshooting)

---

## Overview

The auto-labeling system has been **simplified and streamlined** to focus exclusively on Conventional Commits. This approach provides:

✅ **Predictable Labeling**: Based on standardized commit message format  
✅ **Reduced Complexity**: Clean configuration with clear patterns  
✅ **Better Maintainability**: Fewer rules, easier to understand and modify  
✅ **Standards Compliance**: Follows conventional commits specification exactly  

### **Key Changes (v3.0):**

- **Simplified Structure**: Removed complex keyword-based rules
- **Pattern-Based Matching**: Uses regex patterns for precise conventional commit detection
- **Focused Scope**: Only relevant scopes for the containers project
- **Reduced Labels**: Maximum 3 labels to avoid spam

---

## Configuration Structure

The configuration in `.github/auto-label-config.json` has three main sections:

### **1. Conventional Commits**

Maps commit types to labels using regex patterns:

```json
"conventional_commits": {
  "feat": {
    "label": "type: feature",
    "pattern": "^feat(\\(.+\\))?(!)?:",
    "priority": 1
  },
  "fix": {
    "label": "type: fix", 
    "pattern": "^fix(\\(.+\\))?(!)?:",
    "priority": 1
  }
  // ... more types
}
```

### **2. Breaking Changes**

Detects breaking changes from conventional commit indicators:

```json
"breaking_changes": {
  "label": "breaking-change",
  "patterns": ["!:", "BREAKING CHANGE:", "BREAKING-CHANGE:"],
  "priority": 1
}
```

### **3. Scopes**

Maps conventional commit scopes to project-specific labels:

```json
"scopes": {
  "docker": {
    "label": "scope: docker",
    "priority": 2
  },
  "nginx": {
    "label": "scope: nginx", 
    "priority": 2
  }
  // ... more scopes
}
```

---

## How It Works

### **Trigger Conditions:**

- **When**: PRs and issues are opened
- **Excludes**: `dependabot[bot]` and `github-actions[bot]`
- **Manual**: Can be triggered via `workflow_dispatch`

### **Label Application Process:**

1. **Parse Commit Message**: Extract type, scope, and breaking change indicators
2. **Apply Type Label**: Match conventional commit type to label
3. **Apply Scope Label**: If scope is present and recognized, add scope label
4. **Apply Breaking Change**: If breaking change indicators found, add breaking-change label
5. **Respect Limits**: Maximum 3 labels applied based on priority

---

## Supported Commit Types

| Commit Type | Label Applied | Description | Example |
|-------------|---------------|-------------|---------|
| `feat` | `type: feature` | New features | `feat: add nginx container support` |
| `fix` | `type: fix` | Bug fixes | `fix: resolve container startup issue` |
| `docs` | `type: docs` | Documentation | `docs: update README with examples` |
| `style` | `type: style` | Code style changes | `style: format Dockerfile` |
| `refactor` | `type: refactor` | Code refactoring | `refactor: simplify build script` |
| `perf` | `type: performance` | Performance improvements | `perf: optimize image build time` |
| `test` | `type: test` | Adding/updating tests | `test: add nginx configuration tests` |
| `chore` | `type: chore` | Maintenance tasks | `chore: update dependencies` |
| `ci` | `type: ci` | CI/CD changes | `ci: improve build workflow` |
| `build` | `type: build` | Build system changes | `build: update Docker configuration` |
| `revert` | `type: revert` | Reverting changes | `revert: undo nginx configuration` |

---

## Scope Detection

Scopes are automatically detected from conventional commit format: `type(scope): description`

### Core Infrastructure Scopes

| Scope | Label Applied | Priority | Example |
|-------|---------------|----------|---------|
| `api` | `scope: api` | High | `feat(api): add container registry endpoint` |
| `auth` | `scope: auth` | Critical | `fix(auth): resolve authentication bypass` |
| `build` | `scope: build` | High | `ci(build): optimize compilation process` |
| `ci` | `scope: ci` | High | `fix(ci): improve workflow performance` |
| `config` | `scope: config` | High | `feat(config): add SSL configuration support` |
| `security` | `scope: security` | Critical | `fix(security): patch CVE-2024-1234` |
| `workflow` | `scope: workflow` | High | `ci(workflow): add automated testing` |

### Container-Specific Scopes

| Scope | Label Applied | Priority | Example |
|-------|---------------|----------|---------|
| `container` | `scope: container` | High | `fix(container): resolve volume mounting` |
| `docker` | `scope: docker` | High | `feat(docker): add multi-stage build` |
| `nginx` | `scope: nginx` | High | `feat(nginx): add SSL configuration` |
| `scripts` | `scope: scripts` | High | `fix(scripts): resolve build script permissions` |

### Supporting Scopes

| Scope | Label Applied | Priority | Example |
|-------|---------------|----------|---------|
| `deps` | `scope: deps` | Standard | `chore(deps): bump nginx to 1.29.1` |
| `docs` | `scope: docs` | Standard | `docs(docs): restructure README` |
| `test` | `scope: test` | Standard | `test(docker): add integration tests` |

---

## Breaking Changes

Breaking changes are detected through conventional commit indicators:

### Detection Patterns

- `feat!: description` (exclamation mark after type)
- `feat(scope)!: description` (exclamation mark after scope)
- Commit body containing `BREAKING CHANGE:` or `BREAKING-CHANGE:`

### Label Applied

`breaking-change`

### Examples

- `feat!: remove deprecated API` → `type: feature` + `breaking-change`
- `fix(docker)!: change base image` → `type: fix` + `scope: docker` + `breaking-change`

---

## Real-World Examples

### Common Scenarios

| Commit Message | Labels Applied |
|----------------|----------------|
| `feat(api): add container registry endpoint` | `type: feature`, `scope: api` |
| `fix(auth): resolve authentication bypass` | `type: fix`, `scope: auth` |
| `feat(docker): add multi-stage build support` | `type: feature`, `scope: docker` |
| `chore(deps): bump nginx to 1.29.1` | `type: chore`, `scope: deps` |
| `ci(workflow): optimize build pipeline` | `type: ci`, `scope: workflow` |
| `fix(security): patch CVE-2024-1234` | `type: fix`, `scope: security` |
| `feat(config): add SSL configuration support` | `type: feature`, `scope: config` |
| `test(docker): add container integration tests` | `type: test`, `scope: docker` |
| `fix(scripts): resolve build script permissions` | `type: fix`, `scope: scripts` |
| `docs(nginx): update configuration examples` | `type: docs`, `scope: nginx` |
| `perf(build): optimize image compilation` | `type: performance`, `scope: build` |
| `feat(container)!: breaking volume changes` | `type: feature`, `scope: container`, `breaking-change` |

### Edge Cases

| Input | Labels Applied | Reason |
|-------|----------------|--------|
| `update nginx container` | None | Not conventional commit format |
| `feat add new feature` | None | Missing colon |
| `feat(unknown): add feature` | `type: feature` | Unknown scope ignored |
| `fix: urgent security issue` | `type: fix` | No scope detection from description |

---

## Validation and Testing

### **Configuration Validation:**

Run the validation script to test your configuration:

```bash
node scripts/validate-auto-label-config.js
```

### **Manual Testing:**

You can test the labeling system by:

1. Creating a PR with conventional commit title
2. Using `workflow_dispatch` to trigger manual labeling
3. Checking GitHub Actions logs for applied labels

---

## Troubleshooting

### **Labels Not Applied:**

1. **Check Commit Format**: Ensure proper conventional commit syntax
   - ✅ `feat: add feature`
   - ❌ `feat add feature` (missing colon)
   - ❌ `add new feature` (missing type)

2. **Verify Workflow**: Check GitHub Actions workflow logs
3. **Check Exclusions**: Ensure not triggered by bot accounts
4. **Configuration**: Validate JSON syntax in auto-label-config.json

### **Unexpected Labels:**

1. **Pattern Matching**: Verify commit message matches expected pattern exactly
2. **Priority**: Higher priority labels may override lower priority ones
3. **Max Labels**: Only 3 labels maximum will be applied

### **Configuration Issues:**

1. **JSON Syntax**: Use JSON validator to check syntax
2. **Regex Patterns**: Test regex patterns with commit messages
3. **Workflow Logs**: Check GitHub Actions for configuration loading errors

---

## Project Summary

The simplified auto-labeling system provides **clean, predictable, and maintainable** label automation based on conventional commits. The new approach eliminates complexity while ensuring accurate labeling to our container project.

**✅ Current Status:**

- Configuration simplified to conventional commits only
- Pattern-based matching for precise detection
- Project-relevant scopes and types only
- Maximum 3 labels to avoid spam
- Easy to understand and modify
