# Container Build Scripts

## Enterprise Container Build Utilities

This directory contains build utilities and scripts for enterprise-grade container management.

### Build Scripts

- `build-all.sh` - Build all containers or specific ones
- `test-containers.sh` - Run comprehensive container tests
- `security-scan.sh` - Perform security scans
- `release.sh` - Handle container releases

### Testing Framework

- `tests/` - Container test suites
- `integration/` - Integration tests
- `security/` - Security test cases

### Usage

```bash
# Build all containers
./scripts/build-all.sh

# Build specific container
./scripts/build-all.sh nginx

# Run tests
./scripts/test-containers.sh nginx/1.29/debian-12

# Security scan
./scripts/security-scan.sh nginx:1.29-debian-12
```
