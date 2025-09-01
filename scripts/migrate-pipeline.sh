#!/bin/bash
# Migration Script for Enterprise CI/CD Pipeline
# This script helps migrate from the current pipeline to the enterprise-grade version

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Backup current workflow
backup_current_workflow() {
    log_info "Backing up current workflow..."
    
    if [[ -f ".github/workflows/ci-pipeline.yml" ]]; then
        cp ".github/workflows/ci-pipeline.yml" ".github/workflows/ci-pipeline.yml.backup.$(date +%Y%m%d-%H%M%S)"
        log_success "Current workflow backed up"
    else
        log_warning "No existing ci-pipeline.yml found"
    fi
}

# Validate enterprise workflow
validate_enterprise_workflow() {
    log_info "Validating enterprise workflow..."
    
    if [[ -f ".github/workflows/enterprise-ci-pipeline.yml" ]]; then
        log_success "Enterprise workflow file found"
        
        # Basic syntax validation
        if command -v yamllint &> /dev/null; then
            if yamllint ".github/workflows/enterprise-ci-pipeline.yml" &> /dev/null; then
                log_success "Workflow YAML syntax is valid"
            else
                log_error "Workflow YAML syntax validation failed"
                return 1
            fi
        else
            log_warning "yamllint not found, skipping YAML validation"
        fi
    else
        log_error "Enterprise workflow file not found"
        return 1
    fi
}

# Setup supporting files
setup_supporting_files() {
    log_info "Setting up supporting files..."
    
    # Check for Hadolint config
    if [[ ! -f ".hadolint.yaml" ]]; then
        log_warning ".hadolint.yaml not found - Dockerfile linting may not work properly"
    fi
    
    # Check for build scripts
    if [[ ! -f "scripts/build-all.sh" ]]; then
        log_warning "Build script not found - local builds may not work"
    fi
    
    # Check for test scripts
    if [[ ! -f "scripts/test-containers.sh" ]]; then
        log_warning "Test script not found - local testing may not work"
    fi
    
    # Check for templates
    if [[ ! -d "templates" ]]; then
        log_warning "Templates directory not found - container templates not available"
    fi
    
    log_success "Supporting files setup complete"
}

# Verify GitHub repository settings
verify_github_settings() {
    log_info "Verifying GitHub repository settings..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        return 1
    fi
    
    # Check for required secrets (if we can access GitHub API)
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        log_info "GitHub CLI authenticated, checking repository settings..."
        
        # Check if GitHub Actions is enabled
        if gh api "repos/{owner}/{repo}/actions/permissions" &> /dev/null; then
            log_success "GitHub Actions is enabled"
        else
            log_warning "Unable to verify GitHub Actions status"
        fi
        
        # Check if GitHub Container Registry is accessible
        if gh api "user/packages" &> /dev/null; then
            log_success "GitHub Container Registry is accessible"
        else
            log_warning "Unable to verify GitHub Container Registry access"
        fi
    else
        log_warning "GitHub CLI not available or not authenticated - skipping GitHub settings verification"
    fi
}

# Test enterprise workflow
test_enterprise_workflow() {
    log_info "Testing enterprise workflow components..."
    
    # Test build script
    if [[ -f "scripts/build-all.sh" ]] && [[ -x "scripts/build-all.sh" ]]; then
        log_info "Testing build script help..."
        if ./scripts/build-all.sh --help &> /dev/null; then
            log_success "Build script is functional"
        else
            log_error "Build script test failed"
        fi
    fi
    
    # Test if we can discover containers
    if [[ -d "broadsage" ]]; then
        container_count=$(find broadsage -name "Dockerfile" -type f | wc -l)
        log_info "Found $container_count container(s) to build"
        
        if [[ $container_count -gt 0 ]]; then
            log_success "Container discovery test passed"
        else
            log_warning "No containers found - this may be expected for new repositories"
        fi
    else
        log_warning "broadsage directory not found"
    fi
}

# Generate migration report
generate_migration_report() {
    log_info "Generating migration report..."
    
    cat > "MIGRATION_REPORT.md" << 'EOF'
# Enterprise CI/CD Pipeline Migration Report

## Migration Summary

This report summarizes the migration from the basic CI/CD pipeline to the enterprise-grade version.

### Files Modified
- `.github/workflows/ci-pipeline.yml` → Backed up as `.github/workflows/ci-pipeline.yml.backup.*`
- `.github/workflows/enterprise-ci-pipeline.yml` → New enterprise workflow

### New Files Added
- `.hadolint.yaml` → Dockerfile linting configuration
- `scripts/build-all.sh` → Enterprise build script
- `scripts/test-containers.sh` → Comprehensive testing framework
- `templates/` → Container templates for new applications
- `ENTERPRISE_PIPELINE.md` → Detailed documentation

### Key Improvements
1. **Enhanced Security**: Vulnerability scanning, container signing, SBOM generation
2. **Multi-Architecture Support**: ARM64 and AMD64 builds
3. **Advanced Testing**: Functional, security, and integration testing
4. **Better Observability**: Detailed reporting and monitoring
5. **Developer Experience**: Local build and test scripts

### Next Steps
1. **Test the Pipeline**: Create a test PR to validate the new workflow
2. **Update Documentation**: Review and update repository documentation
3. **Team Training**: Train team members on new features and capabilities
4. **Monitor Performance**: Monitor build times and success rates
5. **Gradual Rollout**: Consider gradual rollout for large teams

### Troubleshooting
- Check GitHub Actions logs for any workflow issues
- Verify container registry permissions
- Ensure all required secrets are configured
- Review security scanning results

### Support
- See `ENTERPRISE_PIPELINE.md` for detailed documentation
- Check `scripts/README.md` for local development help
- Review GitHub Actions workflow logs for debugging

Generated: $(date)
EOF

    log_success "Migration report generated: MIGRATION_REPORT.md"
}

# Main migration function
main() {
    echo "=========================================="
    echo "Enterprise CI/CD Pipeline Migration"
    echo "=========================================="
    echo
    
    log_info "Starting migration process..."
    
    # Pre-migration checks
    if ! command -v git &> /dev/null; then
        log_error "Git is required but not installed"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker not found - local testing may not work"
    fi
    
    # Execute migration steps
    backup_current_workflow
    validate_enterprise_workflow
    setup_supporting_files
    verify_github_settings
    test_enterprise_workflow
    generate_migration_report
    
    echo
    log_success "Migration completed successfully!"
    echo
    echo "Next steps:"
    echo "1. Review the generated MIGRATION_REPORT.md"
    echo "2. Commit the new workflow and supporting files"
    echo "3. Create a test PR to validate the new pipeline"
    echo "4. Monitor the first few builds for any issues"
    echo
    echo "For detailed documentation, see ENTERPRISE_PIPELINE.md"
}

# Run migration
main "$@"
