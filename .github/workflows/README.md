# Workflow Security Refactoring

This document explains the security improvements made to the CI/CD workflows by replacing `pull_request_target` with a safer approach.

## Problem

The original workflow used `pull_request_target` which:
- Runs with write permissions in the context of the base repository
- Can be dangerous for external PRs as it runs untrusted code with elevated permissions
- Requires complex security checks to prevent malicious actions

## Solution

The workflows have been refactored into three separate, secure workflows:

### 1. PR Check Workflow (`pr-check.yml`)

**Trigger**: `pull_request` events (unprivileged)
**Purpose**: Basic testing and validation of PRs without publishing
**Permissions**: Read-only

**Features**:
- Discovers changed containers
- Lints Dockerfiles with Hadolint
- Builds container images (linux/amd64 only for speed)
- Runs basic startup tests
- Performs security scans with Trivy
- **Does NOT push images** - this is intentional for security

### 2. Publish Approved PR Workflow (`publish-approved-pr.yml`)

**Trigger**: `workflow_run` completion of PR Check workflow
**Purpose**: Publishes approved PRs after manual review
**Permissions**: Write access to packages and pull requests

**Security Features**:
- Only runs after successful PR check workflow
- Requires manual approval via "safe to test" label for external PRs
- Automatically approves PRs from repository collaborators
- Uses the head SHA from the original PR (not base branch)
- Full multi-platform builds and publishing
- Signs images with Cosign
- Generates SBOMs

### 3. Enterprise CI Pipeline (`enterprise-ci-pipeline.yml`)

**Trigger**: `push` to main, `workflow_dispatch`, `schedule`
**Purpose**: Production builds and releases
**Permissions**: Full write access

**Features**:
- Removed all `pull_request_target` logic
- Only handles trusted events (push to main, manual dispatch, scheduled)
- Full production pipeline with signing and security scanning

### 4. Dependabot Auto-merge (`dependabot-auto-merge.yml`)

**Trigger**: `pull_request` from dependabot
**Purpose**: Automatically merge dependabot PRs after tests pass
**Permissions**: Write access for auto-merge

**Security Features**:
- Only runs for dependabot PRs with "dependencies" label
- Waits for PR check workflow to complete successfully
- Uses unprivileged `pull_request` trigger

## Security Benefits

1. **Separation of Concerns**: Test and publish phases are separated
2. **Manual Approval Gate**: External PRs require explicit approval via labels
3. **Unprivileged Testing**: Initial tests run without write permissions
4. **Audit Trail**: Clear distinction between test and publish phases
5. **No Code Injection**: Untrusted code never runs with elevated permissions

## Usage Instructions

### For Repository Maintainers

1. **Internal PRs**: Will automatically build and publish if from repository collaborators
2. **External PRs**: 
   - First run will only test (via `pr-check.yml`)
   - Add "safe to test" label to trigger publishing workflow
   - Review the PR thoroughly before adding the label

### For Contributors

1. **Internal Contributors**: PRs will be automatically tested and published
2. **External Contributors**: 
   - PRs will be tested automatically
   - Publishing requires maintainer approval via "safe to test" label
   - Be patient - this is for security

## Labels Used

- `safe to test`: Manually added by maintainers to approve external PRs for publishing
- `dependencies`: Automatically added by dependabot, used for auto-merge logic

## Workflow Dependencies

```
External PR Flow:
pull_request → pr-check.yml → (manual review) → add "safe to test" label → publish-approved-pr.yml

Internal PR Flow:
pull_request → pr-check.yml → publish-approved-pr.yml (auto-approved)

Dependabot Flow:
pull_request → pr-check.yml → dependabot-auto-merge.yml

Production Flow:
push to main → enterprise-ci-pipeline.yml
```

This approach follows GitHub's security best practices and provides a robust, secure CI/CD pipeline.
