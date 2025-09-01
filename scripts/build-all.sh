#!/bin/bash
# Build Script for Enterprise Container Images
# Usage: ./build-all.sh [container_name] [--push] [--platform linux/amd64,linux/arm64]

set -euo pipefail

# Default values
PUSH=false
PLATFORM="linux/amd64,linux/arm64"
REGISTRY="ghcr.io"
NAMESPACE="${GITHUB_REPOSITORY_OWNER:-broadsage}"
CONTAINER_FILTER=""
BUILD_CONTEXT="."

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

# Help function
show_help() {
    cat << EOF
Enterprise Container Build Script

Usage: $0 [OPTIONS] [CONTAINER_NAME]

OPTIONS:
    -h, --help              Show this help message
    -p, --push              Push images to registry after building
    --platform PLATFORMS   Target platforms (default: linux/amd64,linux/arm64)
    --registry REGISTRY     Container registry (default: ghcr.io)
    --namespace NAMESPACE   Registry namespace (default: \$GITHUB_REPOSITORY_OWNER)
    --dry-run              Show what would be built without building

CONTAINER_NAME:
    Specific container to build (e.g., nginx, apache)
    If not specified, all containers will be discovered and built

Examples:
    $0                          # Build all containers
    $0 nginx                    # Build only nginx containers
    $0 --push nginx             # Build and push nginx containers
    $0 --platform linux/amd64  # Build for specific platform
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            log_error "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            CONTAINER_FILTER="$1"
            shift
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install missing tools and try again"
        exit 1
    fi
}

# Discover containers to build
discover_containers() {
    local containers=()
    
    if [[ -n "$CONTAINER_FILTER" ]]; then
        log_info "Discovering containers matching: $CONTAINER_FILTER"
        containers=($(find broadsage -name "Dockerfile" -type f | grep -E "broadsage/$CONTAINER_FILTER/[^/]+/[^/]+/Dockerfile$" | sed 's|/Dockerfile||g' | sort))
    else
        log_info "Discovering all containers"
        containers=($(find broadsage -name "Dockerfile" -type f | grep -E "broadsage/[^/]+/[^/]+/[^/]+/Dockerfile$" | sed 's|/Dockerfile||g' | sort))
    fi
    
    if [[ ${#containers[@]} -eq 0 ]]; then
        log_warning "No containers found to build"
        exit 0
    fi
    
    log_info "Found ${#containers[@]} container(s) to build:"
    for container in "${containers[@]}"; do
        echo "  - $container"
    done
    
    echo "${containers[@]}"
}

# Build a single container
build_container() {
    local container_path="$1"
    local app_name=$(echo "$container_path" | cut -d'/' -f2)
    local version=$(echo "$container_path" | cut -d'/' -f3)
    local platform_dir=$(echo "$container_path" | cut -d'/' -f4)
    
    local image_name="${REGISTRY}/${NAMESPACE}/${app_name}"
    local tag="${version}-${platform_dir}"
    local full_image="${image_name}:${tag}"
    
    log_info "Building container: $container_path"
    log_info "Image: $full_image"
    log_info "Platforms: $PLATFORM"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "DRY RUN: Would build $full_image"
        return 0
    fi
    
    # Build arguments
    local build_args=(
        "build"
        "--file" "$container_path/Dockerfile"
        "--tag" "$full_image"
        "--platform" "$PLATFORM"
        "--label" "org.opencontainers.image.source=https://github.com/${GITHUB_REPOSITORY:-broadsage/containers}"
        "--label" "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
        "--label" "org.opencontainers.image.revision=${GITHUB_SHA:-$(git rev-parse HEAD)}"
    )
    
    if [[ "$PUSH" == "true" ]]; then
        build_args+=("--push")
    else
        build_args+=("--load")
    fi
    
    build_args+=("$container_path")
    
    # Execute build
    if docker buildx "${build_args[@]}"; then
        log_success "Successfully built: $full_image"
        
        # Add additional tags if on main branch
        if [[ "${GITHUB_REF:-}" == "refs/heads/main" && "$PUSH" == "true" ]]; then
            # Tag as latest for main branch
            docker buildx build \
                --file "$container_path/Dockerfile" \
                --tag "${image_name}:latest" \
                --platform "$PLATFORM" \
                --push \
                "$container_path"
            log_success "Tagged as latest: ${image_name}:latest"
        fi
        
        return 0
    else
        log_error "Failed to build: $full_image"
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting enterprise container build process"
    
    # Check prerequisites
    check_prerequisites
    
    # Setup Docker Buildx
    if ! docker buildx ls | grep -q "enterprise-builder"; then
        log_info "Creating Docker Buildx builder: enterprise-builder"
        docker buildx create --name enterprise-builder --driver docker-container --use
    else
        log_info "Using existing Docker Buildx builder: enterprise-builder"
        docker buildx use enterprise-builder
    fi
    
    # Discover containers
    local containers
    containers=($(discover_containers))
    
    # Build containers
    local failed_builds=()
    local successful_builds=()
    
    for container in "${containers[@]}"; do
        if build_container "$container"; then
            successful_builds+=("$container")
        else
            failed_builds+=("$container")
        fi
        echo # Add spacing between builds
    done
    
    # Report results
    echo
    log_info "Build Summary:"
    log_success "Successful builds: ${#successful_builds[@]}"
    for build in "${successful_builds[@]}"; do
        echo "  ✅ $build"
    done
    
    if [[ ${#failed_builds[@]} -gt 0 ]]; then
        log_error "Failed builds: ${#failed_builds[@]}"
        for build in "${failed_builds[@]}"; do
            echo "  ❌ $build"
        done
        exit 1
    fi
    
    log_success "All containers built successfully!"
}

# Run main function
main "$@"
