<!-- 
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Broadsage.GitHub

A comprehensive Ansible role for configuring GitHub repositories with best practices, workflows, templates, and community health files.

## Features

🚀 **GitHub Workflows**: Automated CI/CD pipelines with comprehensive testing and security scanning  
📋 **Issue Templates**: Structured bug reports, feature requests, and question forms  
🔄 **Pull Request Templates**: Standardized PR descriptions and checklists  
🤖 **Dependabot**: Automated dependency updates with security scanning  
🏷️ **Auto-Labeling**: Intelligent issue and PR labeling based on content  
📚 **Community Health**: CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, and other community files  
🔒 **Security**: Secret scanning, dependency analysis, and security scorecards  
⚡ **Branch Protection**: Configurable branch protection rules and required checks  

## Requirements

- Ansible >= 2.12
- GitHub repository (public or private)
- Optional: GitHub API token for advanced repository configuration

## Role Variables

### Project Configuration

```yaml
# Basic project information
github_project_name: "my-awesome-project"
github_project_description: "A containerized application built with best practices"
github_organization: "broadsage-containers"
github_default_branch: "main"
github_license: "Apache-2.0"
github_copyright_holder: "Broadsage Corporation <containers@broadsage.com>"
github_copyright_year: "2025"
```

### Repository Settings

```yaml
# Repository configuration
github_visibility: public  # public, private, internal
github_enable_issues: true
github_enable_projects: true
github_enable_wiki: false
github_allow_squash_merge: true
github_allow_merge_commit: false
github_allow_rebase_merge: true
github_delete_branch_on_merge: true
github_enable_auto_merge: true
```

### Workflows Configuration

```yaml
# GitHub Actions workflows
github_workflows:
  commit:
    enabled: true
    name: "Commit Validation"
  dependency_review:
    enabled: true
    name: "Dependency Review"
  mega_linter:
    enabled: true
    name: "Code Quality & Security"
  pr_validate:
    enabled: true
    name: "Pull Request Validation"
  # ... additional workflows
```

### Branch Protection

```yaml
github_branch_protection:
  enabled: true
  enforce_admins: true
  required_status_checks:
    strict: true
    contexts:
      - "mega-linter"
      - "dependency-review"
      - "scorecard-analysis"
  required_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
```

### Issue Templates

```yaml
github_issue_templates:
  - name: bug
    enabled: true
  - name: feature
    enabled: true
  - name: question
    enabled: true
  - name: config
    enabled: true
```

### Dependabot Configuration

```yaml
github_dependabot:
  enabled: true
  package_ecosystems:
    - package-ecosystem: "docker"
      directory: "/"
      schedule:
        interval: "weekly"
      open-pull-requests-limit: 10
    - package-ecosystem: "github-actions"
      directory: "/"
      schedule:
        interval: "weekly"
      open-pull-requests-limit: 10
```

### Labels

```yaml
github_labels:
  - name: "bug"
    color: "d73a4a"
    description: "Something isn't working"
  - name: "enhancement"
    color: "a2eeef"
    description: "New feature or request"
  - name: "priority:high"
    color: "ff0000"
    description: "High priority issue"
  # ... additional labels
```

## Dependencies

This role has no external dependencies, but it works well with:

- `broadsage.repository` - Base repository setup
- `broadsage.containers` - Container-specific configurations

## Example Playbooks

### Basic Usage

```yaml
---
- hosts: localhost
  roles:
    - role: broadsage.github
      vars:
        github_project_name: "my-container-app"
        github_project_description: "A containerized microservice"
        github_organization: "my-org"
        github_project_path: "/path/to/project"
```

### Advanced Configuration

```yaml
---
- hosts: localhost
  roles:
    - role: broadsage.github
      vars:
        github_project_name: "enterprise-app"
        github_project_description: "Enterprise containerized application"
        github_organization: "enterprise-org"
        github_project_path: "{{ playbook_dir }}"
        github_visibility: private
        
        # Custom workflows
        github_workflows:
          commit:
            enabled: true
          security_scan:
            enabled: true
          deploy_staging:
            enabled: true
            
        # Enhanced security
        github_branch_protection:
          enabled: true
          enforce_admins: false
          required_pull_request_reviews:
            required_approving_review_count: 2
            
        # Custom labels
        github_labels:
          - name: "team:backend"
            color: "0052cc"
            description: "Backend team responsibility"
          - name: "env:staging"
            color: "fbca04"
            description: "Staging environment"
```

### Integration with Other Roles

```yaml
---
- hosts: localhost
  roles:
    - role: broadsage.repository
      vars:
        repository_name: "microservice-platform"
        
    - role: broadsage.github
      vars:
        github_project_name: "{{ repository_name }}"
        github_project_path: "{{ repository_path }}"
        
    - role: broadsage.containers
      vars:
        container_registry: "ghcr.io"
        container_namespace: "{{ github_organization }}"
```

## File Structure

After running this role, your repository will have:

```text
.github/
├── workflows/
│   ├── commit.yml                 # Commit validation
│   ├── dependency-review.yml      # Dependency analysis
│   ├── mega-linter.yml           # Code quality & security
│   ├── pr-validate.yml           # PR validation
│   └── scorecard-analysis.yml     # Security scorecard
├── ISSUE_TEMPLATE/
│   ├── bug.yml                   # Bug report template
│   ├── feature.yml               # Feature request template
│   ├── question.yml              # Question template
│   └── config.yml                # Template configuration
├── dependabot.yml                # Dependabot configuration
├── CODEOWNERS                    # Code ownership
├── PULL_REQUEST_TEMPLATE.md      # PR template
└── auto-label-config.json        # Auto-labeling rules

# Community health files
CODE_OF_CONDUCT.md               # Community guidelines
CONTRIBUTING.md                  # Contribution guidelines
SECURITY.md                      # Security policy
SUPPORT.md                       # Support information
GOVERNANCE.md                    # Project governance
MAINTAINERS.md                   # Maintainer information
```

## Tags

Use tags to run specific parts of the role:

```bash
# Deploy only workflows
ansible-playbook playbook.yml --tags "workflows"

# Deploy only issue templates
ansible-playbook playbook.yml --tags "issue-templates"

# Deploy community health files
ansible-playbook playbook.yml --tags "community"

# Skip workflows
ansible-playbook playbook.yml --skip-tags "workflows"
```

## Security Considerations

- **Secret Management**: Never commit API tokens or secrets
- **Branch Protection**: Always enable branch protection for main branches  
- **Code Scanning**: Enable GitHub's security features (secret scanning, dependency graph)
- **Review Requirements**: Require code reviews for all changes
- **Signed Commits**: Consider requiring signed commits (DCO compliance)

## Troubleshooting

### Common Issues

**Issue**: Templates not being generated  
**Solution**: Ensure `github_project_path` is correctly set and writable

**Issue**: Workflows not running  
**Solution**: Check that workflows are enabled in repository settings

**Issue**: Branch protection not working  
**Solution**: Requires admin privileges and GitHub API token

### Debug Mode

Enable debug output:

```yaml
- role: broadsage.github
  vars:
    ansible_verbosity: 2
    github_debug: true
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

Apache-2.0

## Author Information

This role was created by [Broadsage Corporation](https://broadsage.com) as part of the container platform initiative.

For support and questions:

- 📧 Email: <containers@broadsage.com>
- 🐛 Issues: [GitHub Issues](https://github.com/broadsage-containers/docker-template/issues)
- 📖 Docs: [Project Documentation](https://github.com/broadsage-containers/docker-template)

---

## Built with ❤️ by the Broadsage Containers Team
