#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Enable IPv6 listening by default

set -e

ME=$(basename "$0")

auto_enable_ipv6() {
  local DEFAULT_CONF_FILE="/etc/nginx/conf.d/default.conf"

  if [[ -f "$DEFAULT_CONF_FILE" ]]; then
    # Check if IPv6 is already configured
    if grep -q "listen.*\[::\]" "$DEFAULT_CONF_FILE"; then
      echo "$ME: IPv6 listen already configured in $DEFAULT_CONF_FILE"
      return
    fi

    # Add IPv6 listen directive after IPv4 listen
    if grep -q "listen.*80" "$DEFAULT_CONF_FILE"; then
      # Create temporary file for modifications
      local TEMP_CONF
      TEMP_CONF=$(mktemp)

      # Add IPv6 listen after each IPv4 listen directive
      sed '/listen[[:space:]]*80/a\    listen [::]:80;' "$DEFAULT_CONF_FILE" >"$TEMP_CONF"

      # Replace original file if running as non-root (need write permissions)
      if [[ -w "$DEFAULT_CONF_FILE" ]]; then
        mv "$TEMP_CONF" "$DEFAULT_CONF_FILE"
        echo "$ME: Enabled IPv6 in $DEFAULT_CONF_FILE"
      else
        echo "$ME: Cannot write to $DEFAULT_CONF_FILE - IPv6 configuration skipped"
        rm -f "$TEMP_CONF"
      fi
    else
      echo "$ME: No standard HTTP listen directive found in $DEFAULT_CONF_FILE"
    fi
  else
    echo "$ME: $DEFAULT_CONF_FILE not found, skipping IPv6 configuration"
  fi
}

# Only run if nginx command is being executed
if [[ "${1:-}" = "nginx" ]] || [[ "${1:-}" = "/usr/sbin/nginx" ]]; then
  auto_enable_ipv6
fi
