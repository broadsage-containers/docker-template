<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for the Broadsage Open Source Containers project. ADRs document the significant architectural decisions made during the development of our multi-container platform, providing context and rationale for future maintainers and contributors.

## ADR Process

We use ADRs to record important architectural decisions that affect the project's structure, technology choices, and development practices across all supported container images. Each ADR follows a standard format and captures the context, decision, and consequences of significant choices that impact multiple applications.

## Current ADRs

| ADR | Status | Title | Date |
|-----|--------|-------|------|
| [ADR-001](001-adopt-architecture-decision-records.md) | Accepted | Adopt Architecture Decision Records | 2025-09-12 |
| [ADR-002](002-establish-project-foundation.md) | Accepted | Establish Community-Driven Container Foundation | 2025-09-12 |
| [ADR-003](003-use-upstream-application-sources.md) | Accepted | Use Upstream Application Sources | 2025-09-12 |
| [ADR-004](004-container-architecture-decisions.md) | Accepted | Enterprise-Grade Container Architecture and Security Hardening | 2025-09-12 |

## ADR Status Types

- **Proposed**: The ADR is under consideration and review
- **Accepted**: The ADR has been approved and should be implemented
- **Deprecated**: The ADR is no longer relevant but kept for historical context
- **Superseded**: The ADR has been replaced by a newer ADR

## Creating New ADRs

1. Copy the [template.md](template.md) to create a new ADR
2. Number the ADR sequentially (e.g., `005-new-decision.md`)
3. Fill in the template with relevant information
4. Submit as part of a pull request for review
5. Update this index when the ADR is accepted

## Guidelines

- ADRs should focus on significant architectural decisions
- Include sufficient context for future readers to understand the decision
- Document both positive and negative consequences
- Keep ADRs concise but comprehensive
- Link to related issues, discussions, or documentation where appropriate
