#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# Health check script for NGINX container

set -euo pipefail

# Configuration
HEALTH_CHECK_URL="http://localhost:8080/health"
TIMEOUT=3
MAX_ATTEMPTS=3

# Check if nginx process is running
check_process() {
    if ! pgrep nginx >/dev/null 2>&1; then
        echo "FAIL: nginx process not running"
        return 1
    fi
    return 0
}

# Check if nginx is responding to HTTP requests
check_http() {
    local attempt=1
    
    while [[ $attempt -le $MAX_ATTEMPTS ]]; do
        if curl -f -s --connect-timeout "$TIMEOUT" "$HEALTH_CHECK_URL" >/dev/null 2>&1; then
            return 0
        fi
        
        ((attempt++))
        sleep 1
    done
    
    echo "FAIL: nginx not responding to HTTP requests"
    return 1
}

# Check nginx configuration
check_config() {
    if ! nginx -t >/dev/null 2>&1; then
        echo "FAIL: nginx configuration invalid"
        return 1
    fi
    return 0
}

# Main health check
main() {
    local checks=(
        "check_process"
        "check_config"
        "check_http"
    )
    
    for check in "${checks[@]}"; do
        if ! $check; then
            exit 1
        fi
    done
    
    echo "OK: nginx healthy"
    exit 0
}

# Run health check
main "$@"