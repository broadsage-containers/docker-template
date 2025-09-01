# Enterprise Container Template Structure

This directory contains templates for creating new container images following enterprise-grade best practices.

## Directory Structure

```text
templates/
├── base/                    # Base template for all containers
│   ├── Dockerfile.template
│   ├── docker-compose.yml.template
│   └── README.md.template
├── web-server/             # Web server specific template
│   ├── Dockerfile.template
│   └── nginx.conf.template
├── database/               # Database specific template
│   └── Dockerfile.template
└── application/            # Application specific template
    └── Dockerfile.template
```

## Usage

1. Copy the appropriate template directory
2. Rename files by removing `.template` extension
3. Customize the templates for your specific application
4. Update version numbers and metadata

## Template Variables

Templates use the following variables that should be replaced:

- `{{APP_NAME}}` - Application name (e.g., nginx, mysql)
- `{{APP_VERSION}}` - Application version (e.g., 1.29.1)
- `{{BASE_IMAGE}}` - Base image (e.g., bitnami/minideb:bookworm)
- `{{PLATFORM}}` - Platform identifier (e.g., debian-12)
- `{{DESCRIPTION}}` - Application description
- `{{PORTS}}` - Exposed ports
- `{{USER_ID}}` - Non-root user ID (default: 1001)

## Creating New Container

```bash
# Copy template
cp -r templates/base broadsage/myapp/1.0/debian-12

# Customize Dockerfile
sed -i 's/{{APP_NAME}}/myapp/g' broadsage/myapp/1.0/debian-12/Dockerfile
sed -i 's/{{APP_VERSION}}/1.0.0/g' broadsage/myapp/1.0/debian-12/Dockerfile
# ... continue with other variables

# Test the container
./scripts/test-containers.sh broadsage/myapp/1.0/debian-12
```
