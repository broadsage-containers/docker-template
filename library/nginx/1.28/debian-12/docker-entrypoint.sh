#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Enhanced entrypoint script with modular support (inspired by official nginx)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[nginx-entrypoint]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[nginx-entrypoint]${NC} $1"
}

log_error() {
    echo -e "${RED}[nginx-entrypoint]${NC} $1"
}

# Function to run scripts in /docker-entrypoint.d/
run_entrypoint_scripts() {
    if [[ -d "/docker-entrypoint.d" ]]; then
        log_info "Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r script; do
            case "$script" in
                *.envsh)
                    if [[ -x "$script" ]]; then
                        log_info "Sourcing $script"
                        # Source the script to modify environment
                        # shellcheck source=/dev/null
                        source "$script"
                    else
                        log_warn "$script is not executable, skipping"
                    fi
                    ;;
                *.sh)
                    if [[ -x "$script" ]]; then
                        log_info "Launching $script"
                        "$script"
                    else
                        log_warn "$script is not executable, skipping"
                    fi
                    ;;
                *)
                    log_warn "Ignoring $script (not a .sh or .envsh file)"
                    ;;
            esac
        done
        log_info "Configuration complete; ready for start up"
    else
        log_info "No /docker-entrypoint.d/ directory found, skipping configuration"
    fi
}

# Security check - ensure we're running as nginx user
if [[ "$(id -u)" = "0" ]]; then
    log_error "Container must not run as root user!"
    log_error "Use: docker run --user nginx ... or add USER nginx to Dockerfile"
    exit 1
fi

# Validate nginx configuration
log_info "Testing nginx configuration..."
if nginx -t; then
    log_info "nginx configuration test passed"
else
    log_error "nginx configuration test failed"
    exit 1
fi

# Run modular entrypoint scripts
run_entrypoint_scripts

# Execute the main command
if [[ "${1#-}" != "${1}" ]] || [[ -z "$(command -v "${1}")" ]]; then
    set -- nginx "$@"
fi

log_info "Starting: $*"
exec "$@"