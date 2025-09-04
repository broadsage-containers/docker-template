# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# Build stage for dependency management
FROM docker.io/bitnami/minideb:bookworm@sha256:c08bf1955a4051f9d44245f049c06c24282de8ff5a6db22df63b054967e33e0c AS base

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH
ARG BUILDDATE
ARG VERSION="1.29.1"
ARG REVISION

# OCI Labels following OpenContainer standards
LABEL org.opencontainers.image.title="nginx" \
      org.opencontainers.image.description="NGINX Open Source web server - Secure, minimal, production-ready container" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILDDATE}" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.source="https://github.com/broadsage/containers" \
      org.opencontainers.image.url="https://github.com/broadsage/containers/tree/main/broadsage/nginx" \
      org.opencontainers.image.documentation="https://github.com/broadsage/containers/tree/main/broadsage/nginx/README.md" \
      org.opencontainers.image.vendor="Broadsage, Inc." \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      io.broadsage.image.security.scan-date="${BUILDDATE}" \
      io.broadsage.image.security.policy="https://github.com/broadsage/containers/blob/main/SECURITY.md"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux" \
    DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION="${VERSION}"

# Install security-focused prebuild filesystem
COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

# Install minimal required system packages with security hardening
RUN install_packages \
    ca-certificates \
    curl \
    gettext \
    libcrypt1 \
    libgeoip1 \
    libpcre3 \
    libssl3 \
    openssl \
    procps \
    zlib1g && \
    # Remove curl after package installation for security
    apt-get autoremove -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build stage for component installation
FROM base AS installer

# Re-install curl only for download phase
RUN install_packages curl

# Download and verify components with integrity checks
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} && \
    mkdir -p /tmp/bitnami/pkg/cache/ && \
    cd /tmp/bitnami/pkg/cache/ && \
    COMPONENTS=( \
      "render-template-1.0.9-8-linux-${OS_ARCH}-debian-12" \
      "nginx-${NGINX_VERSION}-0-linux-${OS_ARCH}-debian-12" \
    ) && \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      echo "Downloading ${COMPONENT}..." && \
      curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz" -o "${COMPONENT}.tar.gz" && \
      curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz.sha256" -o "${COMPONENT}.tar.gz.sha256" && \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" && \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner && \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done && \
    # Remove curl after downloads
    apt-get autoremove -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Final production image
FROM base AS final

# Copy installed components from installer stage
COPY --from=installer /opt/bitnami /opt/bitnami

# Copy application-specific configurations
COPY rootfs /

# Security hardening and system optimization
RUN /opt/bitnami/scripts/nginx/postunpack.sh && \
    # Update all packages for security
    apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Set proper permissions
    chmod g+rwX /opt/bitnami && \
    # Remove SUID/SGID binaries for security
    find /usr/bin /usr/sbin -perm /6000 -type f -exec ls -la {} \; && \
    find /usr/bin /usr/sbin -perm /6000 -type f -exec chmod a-s {} \; && \
    # Configure logging to stdout/stderr
    mkdir -p /opt/bitnami/nginx/logs && \
    ln -sf /dev/stdout /opt/bitnami/nginx/logs/access.log && \
    ln -sf /dev/stderr /opt/bitnami/nginx/logs/error.log && \
    # Create non-root user if it doesn't exist
    if ! id -u 1001 > /dev/null 2>&1; then \
      groupadd -g 1001 bitnami && \
      useradd -u 1001 -g bitnami -s /bin/false -M bitnami; \
    fi && \
    # Set ownership for bitnami user
    chown -R 1001:1001 /opt/bitnami && \
    # Create app directory with proper permissions  
    mkdir -p /app && \
    chown -R 1001:1001 /app && \
    # Verify nginx installation
    /opt/bitnami/nginx/sbin/nginx -t

# Runtime environment configuration
ENV APP_VERSION="${VERSION}" \
    BITNAMI_APP_NAME="nginx" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/nginx/sbin:$PATH"

# Health check for container monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Expose ports (non-privileged)
EXPOSE 8080 8443

# Use proper signal handling
STOPSIGNAL SIGQUIT

# Set working directory
WORKDIR /app

# Switch to non-root user for security
USER 1001

# Use exec form for better signal handling
ENTRYPOINT ["/opt/bitnami/scripts/nginx/entrypoint.sh"]
CMD ["/opt/bitnami/scripts/nginx/run.sh"]
