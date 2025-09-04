<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Pull Request Templates Guide

Choose the appropriate template to ensure your contribution is reviewed efficiently.

## Available Templates

### Default Template (Automatic)

**Use for:** General contributions, bug fixes, new features, build improvements

**Features:**

- Comprehensive but streamlined
- Used automatically when creating a PR
- Includes impact assessment and security checks
- Documentation requirements included

### Container Template

**Use for:** Container images, version updates, Dockerfile changes, security patches

**Features:**

- Container-specific validation
- Security scanning requirements
- Comprehensive testing checklist
- Image metrics and performance tracking
- Multi-architecture considerations

**How to use:** Add `?template=container.md` to your PR URL

### Documentation Template

**Use for:** README updates, guides, API docs, examples, tutorials

**Features:**

- Content quality validation
- Link verification checklist
- Accessibility compliance
- Cross-platform rendering checks
- SEO considerations

**How to use:** Add `?template=documentation.md` to your PR URL

### Security Template

**Use for:** Security fixes, vulnerability patches, security improvements

**Features:**

- CVE tracking and CVSS scoring
- Vulnerability assessment
- Deployment urgency classification
- Security testing requirements
- Compliance impact assessment

**How to use:** Add `?template=security.md` to your PR URL

### Infrastructure Template

**Use for:** CI/CD changes, build system updates, automation improvements

**Features:**

- Infrastructure-specific validation
- Build and pipeline testing
- Performance impact assessment
- Deployment and rollback procedures
- Developer experience considerations

**How to use:** Add `?template=infrastructure.md` to your PR URL

## Template Selection Guide

| Change Type | Recommended Template |
|-------------|---------------------|
| New container image | Container |
| Version update | Container |
| Security patch | Security |
| Bug fix | Default |
| New feature | Default |
| Documentation | Documentation |
| Configuration | Container |
| CI/CD changes | Infrastructure |
| Build system | Infrastructure |

## How to Use Templates

### Method 1: URL Parameter

Add the template parameter to your PR URL:

```text
https://github.com/owner/repo/compare/main...your-branch?template=container.md
```

### Method 2: Manual Selection

1. Create PR normally
2. Replace the default template content
3. Copy from `.github/PULL_REQUEST_TEMPLATE/[template-name].md`

## Best Practices

### General Guidelines

1. **Be Comprehensive:** Fill out all relevant sections
2. **Test Thoroughly:** Complete all testing checklists
3. **Link Issues:** Reference related issues and dependencies
4. **Document Impact:** Clearly describe change impact
5. **Consider Security:** Always consider security implications

### Container-Specific

1. **Security First:** Always run security scans
2. **Multi-Architecture:** Consider multi-arch support when applicable
3. **Size Optimization:** Monitor and optimize image size
4. **Breaking Changes:** Clearly document any breaking changes
5. **Performance Testing:** Test performance impact

### Documentation-Specific

1. **Accuracy:** Ensure all information is current
2. **Testing:** Test all code examples and procedures
3. **Links:** Verify all internal and external links
4. **Accessibility:** Follow accessibility guidelines
5. **Target Audience:** Write for your intended readers

### Security-Specific

1. **Urgency Classification:** Classify security issues appropriately
2. **Comprehensive Details:** Provide complete vulnerability information
3. **Thorough Testing:** Test security fixes extensively
4. **Team Coordination:** Coordinate with security team
5. **Documentation Updates:** Update security documentation

## Template Customization

You can customize templates by:

- Removing sections that don't apply to your change
- Adding additional relevant information
- Referencing other templates for guidance
- Providing extra context in "Additional Notes" sections

## Need Help?

- Check our Contributing Guide
- Join community discussions
- Create an issue for template-related problems
- Contact maintainers for complex questions

---

*Templates ensure high-quality contributions while making the review process efficient for both contributors and maintainers.*
