# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

## Catch-all for unknown targets
.DEFAULT:
	@echo "Error: Target '$@' not found." >&2
	@$(MAKE) help

# Makefile to check Docker and Podman installation and provide help
.PHONY: help check-docker check-podman check-containers check-compliance update-contributors build

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Template Usage:"
	@echo "  build                	Build the template container image"
	@echo ""
	@echo "Quality Assurance Targets:"
	@echo "  check-compliance     	Run code quality & compliance checks using MegaLinter, FSFE REUSE Compliance, and Conform"
	@echo ""
	@echo "Infrastructure Targets:"
	@echo "  check-docker         	Check if Docker is installed and available in PATH"
	@echo "  check-podman         	Check if Podman is installed and available in PATH"
	@echo "  check-containers     	Check if both Docker and Podman are installed"
	@echo ""
	@echo "Troubleshooting (OS-specific):"
	@sh -c "\
if [ \"\$OS\" = \"Windows_NT\" ]; then \
	echo '  - Windows:'; \
	echo '      * Install Docker Desktop: https://www.docker.com/products/docker-desktop/'; \
	echo '      * Install Podman: https://podman.io/getting-started/installation'; \
	echo '      * Ensure Docker Desktop or Podman Machine is running.'; \
	echo '      * Restart Command Prompt or PowerShell after installation.'; \
elif uname | grep -qi darwin; then \
	echo '  - macOS:'; \
	echo '      * Install Docker Desktop: https://www.docker.com/products/docker-desktop/'; \
	echo '      * Install Podman: brew install podman'; \
	echo '      * After installation, restart your terminal.'; \
elif uname | grep -qi linux; then \
	echo '  - Linux:'; \
	echo '      * Install Docker: https://docs.docker.com/engine/install/'; \
	echo '      * Install Podman: https://podman.io/getting-started/installation'; \
	echo '      * Ensure your user is in the '"'docker'"' group: sudo usermod -aG docker $USER && newgrp docker'; \
	echo '      * Restart your terminal or log out/in after installation.'; \
else \
	echo '  - Unknown OS: Please refer to your OS documentation for Docker/Podman installation.'; \
fi"
	@echo "  - PATH issues: If the command is still not found, check your PATH environment variable."

check-docker:
	@if command -v docker >/dev/null 2>&1; then \
		echo "Docker is installed."; \
	else \
		echo "Docker is NOT installed."; \
	fi

check-podman:
	@if command -v podman >/dev/null 2>&1; then \
		echo "Podman is installed."; \
	else \
		echo "Podman is NOT installed."; \
	fi

check-containers:
	$(MAKE) check-docker
	$(MAKE) check-podman

check-compliance:
	@bash scripts/compliance.sh
	@echo "All checks completed. Review output for any warnings or failures."

update-contributors:
	@echo "🔄 Updating contributor statistics..."
	@python3 scripts/update-contributors.py

# Template targets
build:
	@echo "🏗️ Building template container..."
	@if command -v podman >/dev/null 2>&1; then \
		podman build -t docker-template .; \
	elif command -v docker >/dev/null 2>&1; then \
		docker build -t docker-template .; \
	else \
		echo "❌ Error: Neither podman nor docker found"; \
		exit 1; \
	fi
	@echo "✅ Template built successfully"
