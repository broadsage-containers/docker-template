#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Function to check if nginx configuration is valid
check_config() {
  log "Testing nginx configuration..."
  if nginx -t; then
    log "Nginx configuration test successful"
    return 0
  else
    log "ERROR: Nginx configuration test failed"
    return 1
  fi
}

# Function to create required directories
setup_directories() {
  log "Setting up nginx directories..."

  # Ensure required directories exist with correct permissions
  local dirs=(
    "/var/cache/nginx"
    "/var/cache/nginx/client_temp"
    "/var/cache/nginx/proxy_temp"
    "/var/cache/nginx/fastcgi_temp"
    "/var/cache/nginx/uwsgi_temp"
    "/var/cache/nginx/scgi_temp"
    "/var/log/nginx"
    "/var/run/nginx"
  )

  for dir in "${dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      log "Creating directory: $dir"
      mkdir -p "$dir"
    fi
  done
}

# Function to handle signals for graceful shutdown
handle_signal() {
  local signal=$1
  log "Received $signal signal, shutting down nginx gracefully..."
  nginx -s quit
  exit 0
}

# Function to wait for nginx to start
wait_for_nginx() {
  local timeout=30
  local count=0

  log "Waiting for nginx to start..."
  while ! nginx -t >/dev/null 2>&1; do
    if [ $count -ge $timeout ]; then
      log "ERROR: Timeout waiting for nginx to start"
      return 1
    fi
    sleep 1
    ((count++))
  done
  log "Nginx started successfully"
}

# Main entrypoint logic
main() {
  log "Starting nginx container..."
  log "Nginx version: $(nginx -v 2>&1)"

  # Setup signal handlers
  trap 'handle_signal SIGTERM' SIGTERM
  trap 'handle_signal SIGINT' SIGINT
  trap 'handle_signal SIGQUIT' SIGQUIT

  # Setup directories
  setup_directories

  # Check configuration before starting
  if ! check_config; then
    exit 1
  fi

  # If no arguments provided, start nginx
  if [ $# -eq 0 ]; then
    log "Starting nginx daemon..."
    exec nginx -g "daemon off;"
  fi

  # If first argument is nginx-related, check config first
  if [ "$1" = "nginx" ] || [ "$1" = "/usr/sbin/nginx" ]; then
    if ! check_config; then
      exit 1
    fi
  fi

  # Execute the command
  log "Executing: $*"
  exec "$@"
}

# Run main function
main "$@"
