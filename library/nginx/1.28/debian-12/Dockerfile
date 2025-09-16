# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

ARG TARGETPLATFORM
ARG BUILDPLATFORM
FROM debian:bookworm-slim

ARG NGINX_VERSION=1.28.0
ARG TARGETARCH
ARG NGINX_USER=nginx
ARG NGINX_UID=101
ARG NGINX_GID=101
ARG NGINX_MODULES=""

LABEL org.opencontainers.image.title="nginx" \
      org.opencontainers.image.description="High performance web server and reverse proxy" \
      org.opencontainers.image.source="https://github.com/broadsage/containers" \
      org.opencontainers.image.documentation="https://github.com/broadsage/containers/tree/main/library/nginx/README.md" \
      org.opencontainers.image.vendor="Broadsage, Inc." \
      org.opencontainers.image.version="${NGINX_VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0"

# Install dependencies and create nginx user
RUN set -eux; \
    echo "Building for architecture: $(dpkg --print-architecture)"; \
    echo "Target architecture: ${TARGETARCH}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg2 \
        lsb-release \
        gettext-base \
    ; \
    # Add nginx signing key and repository with better error handling
    wget -qO /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key; \
    gpg --quiet --with-fingerprint --verify-files /tmp/nginx_signing.key || \
    apt-key add /tmp/nginx_signing.key; \
    echo "deb https://nginx.org/packages/debian bookworm nginx" > /etc/apt/sources.list.d/nginx.list; \
    # Add repository preference to prefer nginx.org packages
    echo 'Package: nginx*' > /etc/apt/preferences.d/nginx; \
    echo 'Pin: origin nginx.org' >> /etc/apt/preferences.d/nginx; \
    echo 'Pin-Priority: 700' >> /etc/apt/preferences.d/nginx; \
    \
    # Install nginx with more robust version handling
    apt-get update; \
    # First try exact version, then fallback to latest available
    if ! apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}* 2>/dev/null; then \
        echo "Exact version ${NGINX_VERSION} not available, checking available versions..."; \
        apt-cache policy nginx; \
        # Try with -1~ suffix which is common for nginx packages
        if ! apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}-1~bookworm 2>/dev/null; then \
            # Fallback to latest 1.28.x version
            apt-get install -y --no-install-recommends nginx=1.28.*; \
        fi; \
    fi; \
    \
    # Install optional nginx modules if specified
    if [[ -n "$NGINX_MODULES" ]]; then \
        echo "Installing nginx modules: $NGINX_MODULES"; \
        for module in $NGINX_MODULES; do \
            # Try to install the module with version matching
            if apt-cache show "nginx-module-$module" >/dev/null 2>&1; then \
                apt-get install -y --no-install-recommends "nginx-module-$module=${NGINX_VERSION}*" || \
                apt-get install -y --no-install-recommends "nginx-module-$module"; \
            else \
                echo "Module nginx-module-$module not found, skipping..."; \
            fi; \
        done; \
    fi; \
    # Verify nginx installation and version
    nginx -v; \
    nginx -t; \
    echo "Successfully installed nginx version: $(nginx -v 2>&1 | cut -d/ -f2)"; \
    \
    # Create nginx user and directories (if they don't already exist)
    if ! getent group ${NGINX_USER} >/dev/null 2>&1; then \
        groupadd --system --gid ${NGINX_GID} ${NGINX_USER}; \
    fi; \
    if ! getent passwd ${NGINX_USER} >/dev/null 2>&1; then \
        useradd --system --gid ${NGINX_USER} --no-create-home \
                --home /nonexistent --comment "nginx user" \
                --shell /bin/false --uid ${NGINX_UID} ${NGINX_USER}; \
    fi; \
    \
    # Create required directories
    mkdir -p /var/cache/nginx /var/log/nginx /var/run/nginx; \
    chown -R ${NGINX_USER}:${NGINX_USER} /var/cache/nginx /var/log/nginx /var/run/nginx; \
    chmod 755 /var/cache/nginx /var/log/nginx /var/run/nginx; \
    \
    # Create temp directories for nginx
    mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp; \
    chown -R ${NGINX_USER}:${NGINX_USER} /var/cache/nginx; \
    \
    # Clean up
    apt-get remove -y wget gnupg2 lsb-release; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    rm -f /tmp/nginx_signing.key

# Copy custom nginx configuration
COPY config/ /etc/nginx/

# Copy templates for dynamic configuration
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

# Copy main entrypoint script
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.d/*.sh && \
    chmod +x /docker-entrypoint.d/*.envsh

# Security: Remove setuid/setgid binaries
RUN find / -perm /6000 -type f -exec chmod a-s {} \; 2>/dev/null || true

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Expose standard HTTP port for non-root user (8080) and HTTPS (8443)
EXPOSE 8080 8443

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD nginx -t || exit 1

STOPSIGNAL SIGQUIT

USER ${NGINX_USER}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]