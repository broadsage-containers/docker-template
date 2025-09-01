#!/bin/bash
# Workflow Validation Script
# Validates GitHub Actions workflows for syntax and action availability

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

# Check if action-validator is available
check_action_validator() {
    if command -v action-validator &> /dev/null; then
        return 0
    elif command -v docker &> /dev/null; then
        log_info "Using docker-based action-validator"
        alias action-validator='docker run --rm -v "$(pwd):/workspace" rhymond/github-action-validator:latest'
        return 0
    else
        log_warning "action-validator not available, skipping advanced validation"
        return 1
    fi
}

# Validate YAML syntax
validate_yaml_syntax() {
    local file="$1"
    
    log_info "Validating YAML syntax for $file"
    
    if command -v yamllint &> /dev/null; then
        if yamllint "$file" &> /dev/null; then
            log_success "YAML syntax is valid"
            return 0
        else
            log_error "YAML syntax validation failed"
            yamllint "$file" || true
            return 1
        fi
    elif command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" &> /dev/null; then
            log_success "YAML syntax is valid (python check)"
            return 0
        else
            log_error "YAML syntax validation failed (python check)"
            return 1
        fi
    else
        log_warning "No YAML validator available, skipping syntax check"
        return 0
    fi
}

# Check for common action patterns
validate_action_references() {
    local file="$1"
    
    log_info "Checking action references in $file"
    
    # Extract action references
    local actions
    actions=$(grep -E "uses: " "$file" | sed 's/.*uses: //' | sed 's/[[:space:]]*#.*//' | sort -u)
    
    local issues=0
    
    while IFS= read -r action; do
        if [[ -z "$action" ]]; then
            continue
        fi
        
        # Check for basic action format
        if [[ ! "$action" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+$ ]]; then
            log_warning "Potentially invalid action format: $action"
            ((issues++))
        fi
        
        # Check for known problematic patterns
        case "$action" in
            *@master)
                log_warning "Action using 'master' branch: $action (consider using specific version)"
                ;;
            *@main)
                log_warning "Action using 'main' branch: $action (consider using specific version)"
                ;;
            *@v[0-9])
                log_success "Good versioning: $action"
                ;;
            *@v[0-9].[0-9])
                log_success "Good versioning: $action"
                ;;
            *@v[0-9].[0-9].[0-9])
                log_success "Good versioning: $action"
                ;;
        esac
        
    done <<< "$actions"
    
    if [[ $issues -eq 0 ]]; then
        log_success "All action references look good"
        return 0
    else
        log_warning "Found $issues potential issues with action references"
        return 1
    fi
}

# Check workflow triggers
validate_workflow_triggers() {
    local file="$1"
    
    log_info "Validating workflow triggers in $file"
    
    if grep -q "workflow_dispatch:" "$file"; then
        log_success "Manual dispatch trigger found"
    fi
    
    if grep -q "pull_request:" "$file"; then
        log_success "Pull request trigger found"
    fi
    
    if grep -q "push:" "$file"; then
        log_success "Push trigger found"
    fi
    
    if grep -q "schedule:" "$file"; then
        log_success "Schedule trigger found"
    fi
    
    return 0
}

# Check for required permissions
validate_permissions() {
    local file="$1"
    
    log_info "Checking permissions in $file"
    
    local required_perms=("contents" "packages" "security-events")
    local missing_perms=()
    
    for perm in "${required_perms[@]}"; do
        if ! grep -q "$perm:" "$file"; then
            missing_perms+=("$perm")
        fi
    done
    
    if [[ ${#missing_perms[@]} -eq 0 ]]; then
        log_success "All required permissions found"
        return 0
    else
        log_warning "Missing permissions: ${missing_perms[*]}"
        return 1
    fi
}

# Main validation function
validate_workflow() {
    local file="$1"
    
    echo "========================================"
    echo "Validating: $file"
    echo "========================================"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    local issues=0
    
    # YAML syntax
    if ! validate_yaml_syntax "$file"; then
        ((issues++))
    fi
    
    # Action references
    if ! validate_action_references "$file"; then
        ((issues++))
    fi
    
    # Workflow triggers
    validate_workflow_triggers "$file"
    
    # Permissions
    if ! validate_permissions "$file"; then
        ((issues++))
    fi
    
    # Advanced validation with action-validator if available
    if check_action_validator; then
        log_info "Running advanced action validation"
        if action-validator "$file" &> /dev/null; then
            log_success "Advanced validation passed"
        else
            log_warning "Advanced validation found issues"
            action-validator "$file" || true
            ((issues++))
        fi
    fi
    
    echo
    if [[ $issues -eq 0 ]]; then
        log_success "✅ Workflow validation passed: $file"
        return 0
    else
        log_error "❌ Workflow validation failed with $issues issue(s): $file"
        return 1
    fi
}

# Main execution
main() {
    echo "GitHub Actions Workflow Validator"
    echo "=================================="
    echo
    
    local workflows=(
        ".github/workflows/enterprise-ci-pipeline.yml"
        ".github/workflows/enterprise-ci-pipeline-compatible.yml"
    )
    
    local total_issues=0
    
    for workflow in "${workflows[@]}"; do
        if [[ -f "$workflow" ]]; then
            if ! validate_workflow "$workflow"; then
                ((total_issues++))
            fi
        else
            log_warning "Workflow not found: $workflow"
        fi
        echo
    done
    
    echo "========================================"
    echo "Validation Summary"
    echo "========================================"
    
    if [[ $total_issues -eq 0 ]]; then
        log_success "🎉 All workflows validated successfully!"
        echo
        echo "Next steps:"
        echo "1. Commit the workflows to your repository"
        echo "2. Test with a sample PR or manual trigger"
        echo "3. Monitor the first few runs for any issues"
    else
        log_error "❌ Found issues in $total_issues workflow(s)"
        echo
        echo "Please fix the issues before using the workflows."
    fi
    
    return $total_issues
}

# Run validation
main "$@"
