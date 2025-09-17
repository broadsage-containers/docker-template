#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Automatically tune nginx worker processes based on available CPU cores

set -e

ME=$(basename "$0")

auto_tune_workers() {
  local NGINX_CONF="/etc/nginx/nginx.conf"
  local CPU_CORES

  # Detect number of CPU cores
  if command -v nproc >/dev/null 2>&1; then
    CPU_CORES=$(nproc)
  elif [[ -r /proc/cpuinfo ]]; then
    CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
  else
    CPU_CORES=1
    echo "$ME: Could not detect CPU cores, defaulting to 1"
  fi

  echo "$ME: Detected $CPU_CORES CPU cores"

  # Check if worker_processes is set to auto or needs tuning
  if [[ -f "$NGINX_CONF" ]] && [[ -w "$NGINX_CONF" ]]; then
    if grep -q "worker_processes.*auto" "$NGINX_CONF"; then
      echo "$ME: worker_processes already set to auto"
      return
    fi

    if grep -q "worker_processes" "$NGINX_CONF"; then
      # Update existing worker_processes directive
      sed -i "s/worker_processes.*/worker_processes auto;/" "$NGINX_CONF"
      echo "$ME: Updated worker_processes to auto (will use $CPU_CORES workers)"
    else
      # Add worker_processes directive after user directive or at the beginning of main context
      if grep -q "user " "$NGINX_CONF"; then
        sed -i "/user /a worker_processes auto;" "$NGINX_CONF"
      else
        # Add at the top of the file after any comments
        sed -i "1a worker_processes auto;" "$NGINX_CONF"
      fi
      echo "$ME: Added worker_processes auto directive"
    fi
  else
    echo "$ME: Cannot write to $NGINX_CONF - worker process tuning skipped"
  fi

  # Set environment variable for other scripts
  export NGINX_WORKER_PROCESSES="$CPU_CORES"
}

# Only run if nginx command is being executed
if [[ "${1:-}" = "nginx" ]] || [[ "${1:-}" = "/usr/sbin/nginx" ]]; then
  auto_tune_workers
fi
