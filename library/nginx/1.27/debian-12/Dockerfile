# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Multi-stage build for size optimization
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Build stage
FROM debian:bookworm-slim AS builder

ARG NGINX_VERSION=1.27.2
ARG TARGETARCH
ARG NGINX_MODULES=""

# Install build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg2 \
        lsb-release \
    ; \
    # Add nginx signing key and repository
    wget -qO /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key; \
    apt-key add /tmp/nginx_signing.key; \
    echo "deb https://nginx.org/packages/debian bookworm nginx" > /etc/apt/sources.list.d/nginx.list; \
    echo 'Package: nginx*' > /etc/apt/preferences.d/nginx; \
    echo 'Pin: origin nginx.org' >> /etc/apt/preferences.d/nginx; \
    echo 'Pin-Priority: 700' >> /etc/apt/preferences.d/nginx; \
    \
    # Update package list with new repository
    apt-get update; \
    \
    # Install nginx with robust version handling
    if ! apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}* 2>/dev/null; then \
        echo "Exact version ${NGINX_VERSION} not available, checking available versions..."; \
        apt-cache policy nginx; \
        if ! apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}-1~bookworm 2>/dev/null; then \
            apt-get install -y --no-install-recommends nginx=1.27.*; \
        fi; \
    fi; \
    \
    # Install optional nginx modules if specified
    if [[ -n "$NGINX_MODULES" ]]; then \
        echo "Installing nginx modules: $NGINX_MODULES"; \
        for module in $NGINX_MODULES; do \
            if apt-cache show "nginx-module-$module" >/dev/null 2>&1; then \
                apt-get install -y --no-install-recommends "nginx-module-$module=${NGINX_VERSION}*" || \
                apt-get install -y --no-install-recommends "nginx-module-$module"; \
            else \
                echo "Module nginx-module-$module not found, skipping..."; \
            fi; \
        done; \
    fi; \
    \
    # Verify nginx installation
    nginx -v; \
    nginx -t || echo "Config test will fail without proper config files"; \
    \
    # Clean up build dependencies - keep only runtime essentials
    apt-get remove -y wget gnupg2 lsb-release; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    rm -f /tmp/nginx_signing.key

# Runtime stage - minimal size
FROM debian:bookworm-slim

ARG NGINX_VERSION=1.27.2
ARG NGINX_USER=nginx
ARG NGINX_UID=101
ARG NGINX_GID=101

LABEL org.opencontainers.image.title="nginx" \
      org.opencontainers.image.description="High performance web server and reverse proxy" \
      org.opencontainers.image.source="https://github.com/broadsage/containers" \
      org.opencontainers.image.documentation="https://github.com/broadsage/containers/tree/main/library/nginx/README.md" \
      org.opencontainers.image.vendor="Broadsage, Inc." \
      org.opencontainers.image.version="${NGINX_VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0"

# Install only essential runtime dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gettext-base \
        curl \
    ; \
    # Create nginx user and group
    groupadd --system --gid ${NGINX_GID} ${NGINX_USER}; \
    useradd --system --gid ${NGINX_USER} --no-create-home \
            --home /nonexistent --comment "nginx user" \
            --shell /bin/false --uid ${NGINX_UID} ${NGINX_USER}; \
    \
    # Create required directories with proper permissions
    mkdir -p /var/cache/nginx /var/log/nginx /var/run/nginx; \
    mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/cache/nginx/proxy_cache; \
    chown -R ${NGINX_USER}:${NGINX_USER} /var/cache/nginx /var/log/nginx /var/run/nginx; \
    chmod 755 /var/cache/nginx /var/log/nginx /var/run/nginx; \
    \
    # Clean up to minimize image size
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy nginx from builder stage
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib/nginx /usr/lib/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/share/nginx /usr/share/nginx

# Copy custom configurations
COPY config/ /etc/nginx/
COPY templates/ /etc/nginx/templates/

# Create web root and set permissions
RUN mkdir -p /usr/share/nginx/html; \
    chown -R ${NGINX_USER}:${NGINX_USER} /usr/share/nginx/html; \
    chmod 755 /usr/share/nginx/html

# Copy default index page
COPY html/ /usr/share/nginx/html/

# Create docker-entrypoint.d directory and copy scripts
RUN mkdir -p /docker-entrypoint.d
COPY docker-entrypoint.d/ /docker-entrypoint.d/

# Copy main entrypoint script and healthcheck
COPY docker-entrypoint.sh /
COPY healthcheck.sh /usr/local/bin/

# Set permissions
RUN chmod +x /docker-entrypoint.sh /usr/local/bin/healthcheck.sh && \
    chmod +x /docker-entrypoint.d/*.sh && \
    chmod +x /docker-entrypoint.d/*.envsh

# Security optimizations
RUN set -eux; \
    # Remove setuid/setgid binaries for security
    find / -perm /6000 -type f -exec chmod a-s {} \; 2>/dev/null || true; \
    \
    # Remove unnecessary files to reduce image size
    rm -rf /usr/share/man/* \
           /usr/share/doc/* \
           /usr/share/info/* \
           /usr/share/locale/* \
           /var/cache/debconf/* \
           /var/lib/dpkg/info/* \
           /var/log/* \
           /tmp/* \
           /var/tmp/*; \
    \
    # Create log files as links to stdout/stderr
    mkdir -p /var/log/nginx; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Expose standard HTTP port for non-root user (8080) and HTTPS (8443)
EXPOSE 8080 8443

STOPSIGNAL SIGQUIT

USER ${NGINX_USER}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]