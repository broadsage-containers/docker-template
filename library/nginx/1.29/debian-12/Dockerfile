# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

FROM debian:bookworm-slim

ARG NGINX_VERSION=1.29.1
ARG TARGETARCH
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

# Install dependencies and create nginx user
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
    gpg --quiet --with-fingerprint --verify-files /tmp/nginx_signing.key || \
    apt-key add /tmp/nginx_signing.key; \
    echo "deb https://nginx.org/packages/debian bookworm nginx" > /etc/apt/sources.list.d/nginx.list; \
    \
    # Install nginx
    apt-get update; \
    apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}*; \
    \
    # Create nginx user and directories
    groupadd --system --gid ${NGINX_GID} ${NGINX_USER}; \
    useradd --system --gid ${NGINX_USER} --no-create-home \
            --home /nonexistent --comment "nginx user" \
            --shell /bin/false --uid ${NGINX_UID} ${NGINX_USER}; \
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

# Create web root and set permissions
RUN mkdir -p /usr/share/nginx/html; \
    chown -R ${NGINX_USER}:${NGINX_USER} /usr/share/nginx/html; \
    chmod 755 /usr/share/nginx/html

# Copy default index page
COPY html/ /usr/share/nginx/html/

# Create entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Security: Remove setuid/setgid binaries
RUN find / -perm /6000 -type f -exec chmod a-s {} \; 2>/dev/null || true

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Expose standard HTTP and HTTPS ports
EXPOSE 80 443

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD nginx -t || exit 1

STOPSIGNAL SIGQUIT

USER ${NGINX_USER}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]