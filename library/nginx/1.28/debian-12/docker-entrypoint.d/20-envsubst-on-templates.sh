#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Environment variable substitution in nginx templates

set -e

ME=$(basename "$0")

auto_envsubst() {
  local TEMPLATE_DIR="/etc/nginx/templates"
  local DEFINED_ENVS

  if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "$ME: No templates directory found at $TEMPLATE_DIR, skipping"
    return
  fi

  # Get list of defined environment variables
  DEFINED_ENVS=$(printf "\${%s} " "$(awk 'END { for (name in ENVIRON) { if (name ~ /^[_[:alpha:]][_[:alpha:][:digit:]]*$/) print name } }' </dev/null)")

  if [[ -z "$DEFINED_ENVS" ]]; then
    echo "$ME: No environment variables found for substitution"
    return
  fi

  # Process template files
  find "$TEMPLATE_DIR" -name "*.template" -type f | while read -r template; do
    # Determine output file (remove .template extension)
    local output_file="${template%.template}"

    # Replace /etc/nginx/templates with /etc/nginx in the output path
    output_file="${output_file/$TEMPLATE_DIR/\/etc\/nginx}"

    # Create output directory if it doesn't exist
    local output_dir
    output_dir=$(dirname "$output_file")
    if [[ ! -d "$output_dir" ]]; then
      mkdir -p "$output_dir"
    fi

    echo "$ME: Processing template $template -> $output_file"

    # Perform environment variable substitution
    envsubst "$DEFINED_ENVS" <"$template" >"$output_file"

    # Set appropriate permissions
    chmod 644 "$output_file"
  done
}

# Only run if nginx command is being executed
if [[ "${1:-}" = "nginx" ]] || [[ "${1:-}" = "/usr/sbin/nginx" ]]; then
  auto_envsubst
fi
