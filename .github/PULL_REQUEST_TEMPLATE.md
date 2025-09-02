<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Container Image Pull Request

## Description

<!-- 
Provide a brief description of the container changes in this PR.
Include the motivation behind these changes and what they accomplish.
-->

## Type of Container Changes

<!-- Mark all relevant options with an "x" -->

- [ ] 🆕 New container image
- [ ] 🔄 Container image update/upgrade
- [ ] � Bug fix in existing container
- [ ] 🔒 Security patch/vulnerability fix
- [ ] � Base image update
- [ ] 🔧 Configuration changes
- [ ] 📚 Documentation update
- [ ] 🏗️ Dockerfile optimization
- [ ] 🧪 Test improvements
- [ ] 🔧 Build/CI changes

## Container Details

<!-- Fill in details about the containers being modified -->

### Affected Images

- **Container Name(s):** <!-- e.g., nginx, redis, postgres -->
- **Version(s):** <!-- e.g., 1.28, latest, 8.0 -->
- **Base Image:** <!-- e.g., ubuntu:22.04, alpine:3.18 -->
- **Architecture(s):** <!-- e.g., linux/amd64, linux/arm64 -->

### Image Size Impact

- **Before:** <!-- e.g., 125MB -->
- **After:** <!-- e.g., 98MB -->
- **Change:** <!-- e.g., -27MB (-21.6%) -->

## Related Issues

<!-- 
Link any related issues. Use keywords like "Closes", "Fixes", "Resolves" to automatically close issues when PR is merged.
Example: Closes #123, Fixes #456
-->

- Closes #
- Related to #

## Changes Made

<!-- 
List the specific changes made in this PR.
Be as detailed as necessary for reviewers to understand the scope.
-->

- Change 1
- Change 2
- Change 3

## Testing

<!-- Describe how you tested your container changes -->

### Container Testing

- **Docker Version:** <!-- e.g., 24.0.6 -->
- **Platform(s) Tested:** <!-- e.g., linux/amd64, linux/arm64 -->
- **Test Environment:** <!-- e.g., local, staging, GitHub Actions -->

### Test Cases

<!-- Describe the container-specific tests you ran -->

- [ ] Container builds successfully
- [ ] Container starts without errors
- [ ] Service health checks pass
- [ ] Multi-architecture builds work
- [ ] Security scan passes (if applicable)
- [ ] Performance/load testing completed (if applicable)
- [ ] Smoke tests pass
- [ ] Integration tests with dependent services pass

### Manual Testing Commands

<!-- Provide example commands used for manual testing -->

```bash
# Build command
docker build -t test-image .

# Run command
docker run -d --name test-container test-image

# Test command
# Add specific test commands here
```

## Checklist

<!-- Check all boxes that apply to your PR -->

### Container Quality

- [ ] Dockerfile follows best practices
- [ ] Container uses non-root user when possible
- [ ] Health checks implemented (if applicable)
- [ ] Proper signal handling for graceful shutdown
- [ ] No unnecessary packages or files included
- [ ] Multi-stage builds used for optimization (if applicable)
- [ ] Container metadata labels added

### Security & Compliance

- [ ] Base image is from trusted source
- [ ] Security vulnerabilities scanned and addressed
- [ ] No secrets or sensitive data in container layers
- [ ] Container runs with minimal privileges
- [ ] Security context properly configured

### Documentation & Compatibility

- [ ] README updated with usage examples
- [ ] Docker Compose examples provided (if applicable)
- [ ] Environment variables documented
- [ ] Volume mounts and ports documented
- [ ] Backward compatibility maintained (or breaking changes documented)
- [ ] Multi-architecture support verified

### Build & CI

- [ ] Container builds successfully on all target platforms
- [ ] CI/CD pipeline passes
- [ ] Image size is optimized
- [ ] Build time is reasonable
- [ ] All tests pass in automated builds
- [ ] Container registry publish works (dry-run tested)

### Review Readiness

- [ ] PR is ready for review
- [ ] Reviewers have been assigned
- [ ] Container functionality verified
- [ ] Performance impact assessed
- [ ] Merge conflicts resolved

## Container Usage Examples

<!-- Provide examples of how to use the container -->

### Basic Usage

```bash
docker run -d --name my-container broadsage/container-name:tag
```

### With Custom Configuration

```bash
docker run -d \
  --name my-container \
  -e ENV_VAR=value \
  -p 8080:80 \
  -v /host/path:/container/path \
  broadsage/container-name:tag
```

### Docker Compose

```yaml
version: '3.8'
services:
  my-service:
    image: broadsage/container-name:tag
    ports:
      - "8080:80"
    environment:
      - ENV_VAR=value
    volumes:
      - ./data:/app/data
```

## Additional Notes

<!-- 
Add any additional notes for reviewers here.
This could include:
- Known issues or limitations with the container
- Future container improvements planned
- Alternative base images or approaches considered
- Performance characteristics or benchmarks
- Compatibility notes with orchestration platforms (K8s, Docker Swarm)
- Migration notes for existing users
-->

---

### For Maintainers

<!-- Internal checklist for maintainers -->

- [ ] PR title follows conventional commit format
- [ ] Labels applied appropriately (container name, type of change)
- [ ] Milestone assigned (if applicable)
- [ ] Security review completed (for security-related changes)
- [ ] Performance review completed (for optimization changes)
- [ ] Documentation review completed
- [ ] Container registry permissions verified
- [ ] Breaking changes communicated to users
- [ ] Container scanning results reviewed
