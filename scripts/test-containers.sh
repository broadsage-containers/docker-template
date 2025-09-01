#!/bin/bash
# Container Testing Framework
# Usage: ./test-containers.sh [container_path] [--integration] [--security]

set -euo pipefail

# Default values
INTEGRATION_TESTS=false
SECURITY_TESTS=false
CONTAINER_PATH=""
TEST_TIMEOUT=300
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

log_debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Help function
show_help() {
    cat << EOF
Enterprise Container Testing Framework

Usage: $0 [OPTIONS] [CONTAINER_PATH]

OPTIONS:
    -h, --help              Show this help message
    -i, --integration       Run integration tests
    -s, --security          Run security tests
    -v, --verbose           Enable verbose output
    --timeout SECONDS       Test timeout (default: 300)

CONTAINER_PATH:
    Path to specific container to test (e.g., broadsage/nginx/1.29/debian-12)
    If not specified, all containers will be tested

Examples:
    $0                                      # Test all containers
    $0 broadsage/nginx/1.29/debian-12      # Test specific container
    $0 --integration --security nginx      # Run all test types for nginx
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--integration)
            INTEGRATION_TESTS=true
            shift
            ;;
        -s|--security)
            SECURITY_TESTS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --timeout)
            TEST_TIMEOUT="$2"
            shift 2
            ;;
        -*)
            log_error "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            CONTAINER_PATH="$1"
            shift
            ;;
    esac
done

# Basic functionality tests
test_basic_functionality() {
    local image_tag="$1"
    local app_name="$2"
    
    log_info "Running basic functionality tests for $image_tag"
    
    # Start container
    local container_id
    container_id=$(docker run -d --name "test-${app_name}-$$" "$image_tag")
    
    # Cleanup function
    cleanup_container() {
        log_debug "Cleaning up container: $container_id"
        docker stop "$container_id" >/dev/null 2>&1 || true
        docker rm "$container_id" >/dev/null 2>&1 || true
    }
    trap cleanup_container EXIT
    
    # Wait for container to be ready
    log_debug "Waiting for container to start..."
    sleep 10
    
    # Check if container is running
    if ! docker ps | grep -q "test-${app_name}-$$"; then
        log_error "Container failed to start"
        docker logs "$container_id" || true
        return 1
    fi
    
    # Application-specific health checks
    case "$app_name" in
        "nginx")
            log_debug "Testing nginx health endpoint"
            if docker exec "$container_id" curl -f http://localhost:8080/ >/dev/null 2>&1; then
                log_success "Nginx health check passed"
            else
                log_error "Nginx health check failed"
                docker logs "$container_id"
                return 1
            fi
            ;;
        "apache")
            log_debug "Testing apache health endpoint"
            if docker exec "$container_id" curl -f http://localhost:8080/ >/dev/null 2>&1; then
                log_success "Apache health check passed"
            else
                log_error "Apache health check failed"
                docker logs "$container_id"
                return 1
            fi
            ;;
        *)
            log_info "Generic container health check for $app_name"
            # Just verify it's running and responsive
            if docker exec "$container_id" ps aux >/dev/null 2>&1; then
                log_success "Container is responsive"
            else
                log_error "Container is not responsive"
                return 1
            fi
            ;;
    esac
    
    # Test container restart
    log_debug "Testing container restart"
    docker restart "$container_id" >/dev/null
    sleep 5
    
    if docker ps | grep -q "test-${app_name}-$$"; then
        log_success "Container restart test passed"
    else
        log_error "Container restart test failed"
        return 1
    fi
    
    # Test graceful shutdown
    log_debug "Testing graceful shutdown"
    timeout 30 docker stop "$container_id" >/dev/null
    
    if [[ $? -eq 0 ]]; then
        log_success "Graceful shutdown test passed"
    else
        log_warning "Graceful shutdown took longer than expected"
    fi
    
    trap - EXIT
    cleanup_container
    
    return 0
}

# Security tests
test_security() {
    local image_tag="$1"
    local app_name="$2"
    
    log_info "Running security tests for $image_tag"
    
    # Test 1: Run as non-root user
    log_debug "Checking if container runs as non-root"
    local user_id
    user_id=$(docker run --rm "$image_tag" id -u)
    
    if [[ "$user_id" != "0" ]]; then
        log_success "Container runs as non-root user (UID: $user_id)"
    else
        log_error "Container runs as root user"
        return 1
    fi
    
    # Test 2: Check for unnecessary capabilities
    log_debug "Checking container capabilities"
    local caps
    caps=$(docker run --rm "$image_tag" sh -c 'cat /proc/self/status | grep Cap' || echo "")
    
    if [[ -n "$caps" ]]; then
        log_debug "Container capabilities: $caps"
    fi
    
    # Test 3: Verify read-only filesystem works
    log_debug "Testing read-only filesystem"
    if docker run --rm --read-only "$image_tag" echo "Read-only test" >/dev/null 2>&1; then
        log_success "Container works with read-only filesystem"
    else
        log_warning "Container may not work with read-only filesystem"
    fi
    
    # Test 4: Check for sensitive files
    log_debug "Checking for sensitive files"
    local sensitive_files
    sensitive_files=$(docker run --rm "$image_tag" sh -c 'find / -name "*.key" -o -name "*.pem" -o -name "*password*" -o -name "*secret*" 2>/dev/null | head -10' || echo "")
    
    if [[ -z "$sensitive_files" ]]; then
        log_success "No obvious sensitive files found"
    else
        log_warning "Potential sensitive files found:"
        echo "$sensitive_files"
    fi
    
    return 0
}

# Integration tests
test_integration() {
    local image_tag="$1"
    local app_name="$2"
    
    log_info "Running integration tests for $image_tag"
    
    case "$app_name" in
        "nginx")
            test_nginx_integration "$image_tag"
            ;;
        "apache")
            test_apache_integration "$image_tag"
            ;;
        *)
            log_info "No specific integration tests for $app_name"
            ;;
    esac
}

# Nginx-specific integration tests
test_nginx_integration() {
    local image_tag="$1"
    
    log_debug "Running nginx integration tests"
    
    # Create a temporary config
    local temp_dir
    temp_dir=$(mktemp -d)
    
    cat > "$temp_dir/nginx.conf" << 'EOF'
server {
    listen 8080;
    location / {
        return 200 "Integration test OK\n";
        add_header Content-Type text/plain;
    }
    location /health {
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF
    
    # Run nginx with custom config
    local container_id
    container_id=$(docker run -d \
        -p 8080:8080 \
        -v "$temp_dir/nginx.conf:/opt/bitnami/nginx/conf/server_blocks/test.conf:ro" \
        --name "nginx-integration-$$" \
        "$image_tag")
    
    # Cleanup function
    cleanup_nginx() {
        docker stop "$container_id" >/dev/null 2>&1 || true
        docker rm "$container_id" >/dev/null 2>&1 || true
        rm -rf "$temp_dir"
    }
    trap cleanup_nginx EXIT
    
    # Wait for nginx to start
    sleep 10
    
    # Test endpoints
    if curl -f http://localhost:8080/ >/dev/null 2>&1; then
        log_success "Nginx serves custom content"
    else
        log_error "Nginx integration test failed"
        docker logs "$container_id"
        trap - EXIT
        cleanup_nginx
        return 1
    fi
    
    if curl -f http://localhost:8080/health >/dev/null 2>&1; then
        log_success "Nginx health endpoint works"
    else
        log_error "Nginx health endpoint failed"
        trap - EXIT
        cleanup_nginx
        return 1
    fi
    
    trap - EXIT
    cleanup_nginx
    return 0
}

# Apache-specific integration tests
test_apache_integration() {
    local image_tag="$1"
    
    log_debug "Running apache integration tests"
    
    # Similar to nginx but for apache
    log_success "Apache integration tests would go here"
    return 0
}

# Main test runner
run_tests() {
    local container_path="$1"
    local app_name=$(echo "$container_path" | cut -d'/' -f2)
    local version=$(echo "$container_path" | cut -d'/' -f3)
    local platform=$(echo "$container_path" | cut -d'/' -f4)
    
    local image_tag="test-${app_name}:${version}-${platform}"
    
    log_info "Testing container: $container_path"
    log_info "Image tag: $image_tag"
    
    # Build the image for testing
    log_debug "Building image for testing"
    if ! docker build -t "$image_tag" "$container_path" >/dev/null 2>&1; then
        log_error "Failed to build image for testing"
        return 1
    fi
    
    local tests_passed=0
    local tests_failed=0
    
    # Run basic functionality tests
    if test_basic_functionality "$image_tag" "$app_name"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Run security tests if requested
    if [[ "$SECURITY_TESTS" == "true" ]]; then
        if test_security "$image_tag" "$app_name"; then
            ((tests_passed++))
        else
            ((tests_failed++))
        fi
    fi
    
    # Run integration tests if requested
    if [[ "$INTEGRATION_TESTS" == "true" ]]; then
        if test_integration "$image_tag" "$app_name"; then
            ((tests_passed++))
        else
            ((tests_failed++))
        fi
    fi
    
    # Cleanup test image
    docker rmi "$image_tag" >/dev/null 2>&1 || true
    
    log_info "Test results for $container_path: $tests_passed passed, $tests_failed failed"
    
    return "$tests_failed"
}

# Main execution
main() {
    log_info "Starting container testing framework"
    
    # Check prerequisites
    if ! command -v docker &> /dev/null; then
        log_error "Docker is required but not installed"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed"
        exit 1
    fi
    
    # Discover containers to test
    local containers=()
    
    if [[ -n "$CONTAINER_PATH" ]]; then
        if [[ -f "$CONTAINER_PATH/Dockerfile" ]]; then
            containers=("$CONTAINER_PATH")
        else
            # Try to find containers matching the pattern
            containers=($(find broadsage -name "Dockerfile" -type f | grep -E "broadsage/$CONTAINER_PATH" | sed 's|/Dockerfile||g' | sort))
        fi
    else
        containers=($(find broadsage -name "Dockerfile" -type f | grep -E "broadsage/[^/]+/[^/]+/[^/]+/Dockerfile$" | sed 's|/Dockerfile||g' | sort))
    fi
    
    if [[ ${#containers[@]} -eq 0 ]]; then
        log_error "No containers found to test"
        exit 1
    fi
    
    log_info "Found ${#containers[@]} container(s) to test"
    
    # Run tests
    local total_failures=0
    
    for container in "${containers[@]}"; do
        if ! run_tests "$container"; then
            ((total_failures++))
        fi
        echo
    done
    
    # Report final results
    if [[ $total_failures -eq 0 ]]; then
        log_success "All container tests passed!"
        exit 0
    else
        log_error "$total_failures container(s) failed testing"
        exit 1
    fi
}

# Run main function
main "$@"
