<!-- SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com> -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Enhanced nginx Container Environment Variables

This file documents all available environment variables for runtime configuration.

## NGINX Basic Configuration

### Server configuration

```bash
NGINX_PORT=80                          # Port to listen on (default: 80)
NGINX_SERVER_NAME=localhost            # Server name (default: localhost)
```

## Security Headers (Customizable via environment variables)

```bash
# X-Frame-Options header (default: DENY)
X_FRAME_OPTIONS=DENY

# X-Content-Type-Options header (default: nosniff)
X_CONTENT_TYPE_OPTIONS=nosniff

# X-XSS-Protection header (default: 1; mode=block)
X_XSS_PROTECTION="1; mode=block"

# Referrer-Policy header (default: strict-origin-when-cross-origin)
REFERRER_POLICY=strict-origin-when-cross-origin
```

## Advanced Configuration

```bash
# Custom upstream configuration (injected into server block)
NGINX_UPSTREAM_CONFIG="upstream backend { server backend1:8080; server backend2:8080; }"
```

## Runtime Features (Automatically configured by entrypoint scripts)

- **IPv6 Support**: Automatically enabled if not already configured
- **DNS Resolvers**: Automatically detected from `/etc/resolv.conf`
- **Worker Processes**: Automatically tuned based on available CPU cores
- **Template Processing**: All `.template` files in `/etc/nginx/templates/` are processed

## Usage Examples

### Basic usage

```bash
docker run -p 8080:80 broadsage/nginx:1.28.0
```

### With custom port and server name

```bash
docker run -p 8080:8080 \
  -e NGINX_PORT=8080 \
  -e NGINX_SERVER_NAME=example.com \
  broadsage/nginx:1.28.0
```

### With custom security headers

```bash
docker run -p 8080:80 \
  -e X_FRAME_OPTIONS="SAMEORIGIN" \
  -e X_XSS_PROTECTION="0" \
  broadsage/nginx:1.28.0
```

### With template-based configuration

```bash
docker run -p 8080:80 \
  -v /path/to/templates:/etc/nginx/templates:ro \
  broadsage/nginx:1.28.0
```
