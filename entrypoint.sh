#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Clean, focused banner
echo ""
echo "�� Docker Template Generator"
echo ""

# Set working directory
WORKSPACE_DIR="/workspace"
cd "$WORKSPACE_DIR"

echo "📁 Workspace: $(pwd)"

# Check if project.yml exists
if [ ! -f "project.yml" ]; then
  echo ""
  echo "❌ Missing project.yml"
  echo ""
  echo "📝 Create project.yml:"
  echo ""
  cat <<'EXAMPLE'
---
organization: "my-company"
project:
  name: "my-app"
  description: "My awesome app"
maintainer:
  name: "Your Name"
  email: "you@example.com"
EXAMPLE
  echo ""
  echo "🚀 Then run:"
  echo "   podman run --rm -v \$(pwd):/workspace docker-template"
  echo ""
  exit 1
fi

echo "✅ Found project.yml"
echo ""
echo "🚀 Generating project..."
echo ""

# Run the Ansible playbook
cd /opt/docker-template
ansible-playbook ansible/generate-project.yml

echo ""
echo "🎉 Done! Your project is ready."
echo ""
