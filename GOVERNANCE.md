<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Broadsage Open Source Containers - Governance Model

This document outlines the governance structure and decision-making processes for the Broadsage Open Source Containers project. Our governance model is designed to foster open collaboration while ensuring technical excellence, security standards, and sustainable project growth.

## Mission Statement

The Broadsage Open Source Containers project provides enterprise-grade, security-hardened container images for popular applications through transparent, community-driven development. We aim to create production-ready alternatives to commercial hardened container solutions while maintaining full transparency and community control.

## Core Principles

### 🌐 Open & Transparent

- All architectural decisions documented via ADRs (Architecture Decision Records)
- Public development process with transparent roadmaps
- Open discussion of technical and governance issues
- Regular community updates and progress reports

### 🔒 Security-First

- Security considerations prioritized in all decisions
- Rapid response to vulnerabilities across all container images
- Comprehensive security hardening and testing
- Transparent security posture documentation

### 🤝 Community-Driven

- Inclusive decision-making process
- Merit-based contributions welcome from all backgrounds
- Diverse maintainer team representing different perspectives
- Community input actively sought for major decisions

### ⚡ Enterprise-Ready

- Production-quality standards for all releases
- Comprehensive testing and validation processes
- Professional documentation and support materials
- Compatibility with enterprise deployment patterns

## Governance Structure

### Project Leadership

#### Technical Steering Committee (TSC)

**Role**: Strategic technical direction, major architectural decisions, conflict resolution

**Current Members**:

- Jagadeep Krishna (Broadsage) - *Chair, Founding Member*
- [Additional members to be added as community grows]

**Responsibilities**:

- Approve major architectural changes and ADRs
- Resolve technical disagreements between maintainers
- Define and maintain technical standards across container images
- Approve new container image additions to the project
- Oversee security incident response coordination

**Meeting Schedule**: Monthly, with additional meetings as needed
**Decision Process**: Consensus-seeking with fallback to majority vote

#### Maintainers

**Role**: Day-to-day project maintenance, code review, community support

**Categories**:

- **Core Maintainers**: Oversight across all containers and project infrastructure
- **Container Maintainers**: Specialized expertise in specific container images
- **Area Maintainers**: Focus on specific aspects (security, documentation, testing)

**Current Core Maintainers**:

- Jagadeep Krishna (Broadsage) - *Project Lead*

**Responsibilities**:

- Review and merge pull requests
- Triage and respond to issues
- Maintain container image quality and security standards
- Support community contributors
- Participate in security vulnerability response

#### Contributors

**Role**: Community members who contribute code, documentation, testing, or other valuable work

**Recognition**: Contributors are recognized in release notes, documentation, and project communications

**Path to Maintainer**: Active contributors may be invited to become maintainers based on sustained contributions and community involvement

### Decision-Making Process

#### Categories of Decisions

**Level 1 - Day-to-Day Operations**
*Examples: Bug fixes, documentation updates, minor configuration changes*

- **Decision Maker**: Individual maintainers
- **Process**: Standard pull request review and merge
- **Approval Required**: 1-2 maintainer approvals depending on scope

**Level 2 - Significant Changes**
*Examples: New features, security updates, dependency changes*

- **Decision Maker**: Relevant maintainers for affected containers
- **Process**: Pull request with detailed description and testing
- **Approval Required**: 2+ maintainer approvals, including container-specific maintainer

**Level 3 - Architectural Decisions**
*Examples: New container additions, major security changes, infrastructure updates*

- **Decision Maker**: Technical Steering Committee
- **Process**: ADR (Architecture Decision Record) with public discussion period
- **Approval Required**: TSC consensus or majority vote
- **Public Input**: Minimum 7-day community comment period

**Level 4 - Governance Changes**
*Examples: Changes to this governance model, maintainer additions/removals*

- **Decision Maker**: Technical Steering Committee
- **Process**: Formal proposal with extended community discussion
- **Approval Required**: TSC unanimous consent for governance changes
- **Public Input**: Minimum 14-day community comment period

#### Decision-Making Timeline

1. **Proposal Submission**: Issues or pull requests submitted with clear description
2. **Community Discussion**: Open discussion period (varies by decision level)
3. **Technical Review**: Maintainer and/or TSC technical evaluation
4. **Decision**: Formal approval or rejection with documented rationale
5. **Implementation**: Approved changes implemented with appropriate testing
6. **Communication**: Decision and rationale communicated to community

### Conflict Resolution

#### Conflict Resolution Process

1. **Direct Discussion**: Parties attempt to resolve disagreement directly
2. **Maintainer Mediation**: If needed, maintainers help facilitate resolution
3. **TSC Review**: For significant conflicts, TSC provides binding decision
4. **Appeal Process**: Decisions can be appealed to TSC within 30 days

#### Code of Conduct Enforcement

- All community members must follow our [Code of Conduct](CODE_OF_CONDUCT.md)
- Violations handled by maintainers with TSC oversight for serious issues
- Progressive enforcement: warning → temporary suspension → permanent ban

## Maintainer Management

### Adding Maintainers

#### Eligibility Criteria

- Sustained high-quality contributions over minimum 3 months
- Demonstrated technical expertise in relevant areas
- Positive community interactions and mentorship of other contributors
- Commitment to project values and governance principles
- Available time to fulfill maintainer responsibilities

#### Nomination Process

1. **Self-nomination or community nomination** via GitHub issue
2. **TSC Review** of contributions and community standing  
3. **Community Input** period (minimum 7 days)
4. **TSC Decision** with documented rationale
5. **Onboarding** including access, documentation, and mentorship

#### Types of Maintainership

- **Container Maintainer**: Expertise in specific container images (nginx, postgresql, etc.)
- **Area Maintainer**: Focus on specific aspects (security, testing, documentation)
- **Core Maintainer**: Cross-cutting responsibilities and project leadership

### Maintainer Responsibilities

#### All Maintainers

- Review pull requests in areas of expertise promptly (within 5 business days)
- Respond to issues and community questions
- Maintain high standards for code quality, security, and documentation
- Follow established processes and contribute to their improvement
- Participate in community discussions and decision-making
- Mentor new contributors and help grow the community

#### Additional Core Maintainer Responsibilities

- Cross-container coordination and consistency
- Infrastructure and tooling maintenance
- Release management and coordination
- Community communication and outreach
- Strategic planning and roadmap development

### Maintainer Emeritus

Maintainers who step back from active participation become "Emeritus Maintainers":

- Retain honorary status and recognition for contributions
- May retain read access to private channels and repositories
- Can return to active status through simplified re-activation process
- Continue to be listed in project documentation with emeritus designation

### Removing Maintainers

#### Reasons for Removal

- Sustained inactivity (6+ months without participation)
- Repeated violations of Code of Conduct
- Actions that significantly harm project or community
- Request for removal by the maintainer themselves

#### Process

1. **Initial Contact**: TSC reaches out to address concerns or confirm inactivity
2. **Community Discussion**: If removal considered, private TSC discussion first
3. **Formal Process**: If warranted, formal process with documentation
4. **Decision**: TSC unanimous consent required for involuntary removal
5. **Communication**: Decision communicated appropriately to community

## Communication Channels

The project maintains multiple communication channels for different purposes. For a complete overview of all communication options, contact information, and usage guidelines, see our [Communication Guide](docs/communication.md).

### Public Forums

All public communication channels are detailed in the [Communication Guide](docs/communication.md), including:

- GitHub Issues for feature requests, bug reports, and technical discussions
- GitHub Discussions for community questions, announcements, and general discussion
- Pull Requests for code review and technical implementation discussion

### Maintainer Coordination

- **Monthly Maintainer Meetings**: Technical coordination and planning
- **TSC Meetings**: Strategic decisions and governance topics
- **Security Channel**: Private channel for security vulnerability coordination
- **Async Updates**: Regular status updates and coordination via GitHub

### Community Engagement

- **Release Notes**: Detailed updates on changes and improvements
- **Blog Posts**: Major announcements, technical deep-dives, community highlights
- **Conference Presentations**: Sharing project progress at relevant industry events
- **Documentation**: Comprehensive guides, tutorials, and reference materials

## Release Management

### Release Process

1. **Planning**: Feature and fix prioritization for upcoming release
2. **Development**: Implementation and testing of planned changes
3. **Security Review**: Comprehensive security assessment of changes
4. **Documentation**: Update all relevant documentation and guides
5. **Testing**: Automated and manual validation across all containers
6. **Release**: Tagged release with detailed release notes
7. **Announcement**: Community communication about release

### Versioning Strategy

- **Semantic Versioning**: Major.Minor.Patch for project-wide changes
- **Container Versioning**: Aligned with upstream application versions
- **Security Releases**: Immediate patches for critical vulnerabilities
- **LTS Releases**: Long-term support versions for enterprise deployments

### Support Policy

- **Current Release**: Full support for latest version
- **Previous Release**: Security updates for 6 months
- **LTS Releases**: Extended support as announced per release
- **EOL Communication**: Clear communication when support ends

## Security Governance

### Security Response Team

- **Lead**: Senior maintainer with security expertise
- **Members**: Cross-section of maintainers from different containers
- **External Advisors**: Security experts from the broader community

### Vulnerability Response Process

1. **Receipt**: Security reports via channels listed in [Communication Guide](docs/communication.md#-email-contacts)
2. **Assessment**: Impact and scope evaluation within 24 hours
3. **Coordination**: Private coordination with affected upstream projects
4. **Development**: Patch development and testing
5. **Disclosure**: Coordinated disclosure with timeline communication
6. **Release**: Security update release with advisory
7. **Post-Mortem**: Process improvement and lessons learned

### Security Standards

- All containers must pass automated security scanning
- Regular dependency updates and vulnerability assessment
- Security-hardened default configurations
- Clear security documentation for each container

## Amendments to Governance

### Process for Changes

1. **Proposal**: Formal proposal submitted via GitHub issue
2. **Discussion**: Community discussion period (minimum 14 days)
3. **Refinement**: Proposal updates based on feedback
4. **TSC Review**: Technical Steering Committee evaluation
5. **Final Decision**: TSC unanimous consent required
6. **Implementation**: Update governance documentation
7. **Communication**: Clear communication of changes to community

### Version Control

- This governance document is versioned alongside the project
- Changes tracked through standard Git history
- Major revisions noted in release communications

---

## Getting Involved

We welcome contributions from developers, security experts, enterprise users, and anyone interested in improving container security and quality.

### Ways to Contribute

- **Code**: Container improvements, bug fixes, new features
- **Documentation**: User guides, developer docs, tutorials
- **Testing**: Manual testing, automated test improvements
- **Security**: Vulnerability research, security improvements
- **Community**: Answering questions, mentoring newcomers

### First Steps

1. Read our [Contributing Guide](CONTRIBUTING.md)
2. Browse [Good First Issues](https://github.com/broadsage/containers/labels/good%20first%20issue)
3. Join the community discussion in GitHub Discussions
4. Introduce yourself and your interests to the community

---

*This governance model is inspired by successful open source projects including Kubernetes, Apache Foundation projects, and CNCF projects, adapted for our specific community-driven container initiative.*

**Document Version**: 1.0  
**Last Updated**: September 12, 2025  
**Next Review**: December 12, 2025
