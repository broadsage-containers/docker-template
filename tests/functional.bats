#!/usr/bin/env bats
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# Container Functional Tests

setup() {
    IMAGE=${BATS_IMAGE:-"ghcr.io/broadsage/nginx:latest"}
    export IMAGE
}

teardown() {
    # Cleanup any running containers
    if [ -n "$CONTAINER_ID" ]; then
        docker stop "$CONTAINER_ID" >/dev/null 2>&1
        docker rm "$CONTAINER_ID" >/dev/null 2>&1
    fi
}

@test "container starts successfully" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$IMAGE")
    export CONTAINER_ID
    
    # Wait for container to start
    sleep 3
    
    # Check if container is running
    run docker ps --filter "id=$CONTAINER_ID" --format "{{.Status}}"
    [[ "$output" =~ "Up" ]]
}

@test "nginx serves default page" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$IMAGE")
    export CONTAINER_ID
    
    # Wait for nginx to start
    sleep 5
    
    # Test HTTP response
    run curl -f -s http://localhost:8080/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "nginx" ]] || [[ "$output" =~ "Welcome" ]]
}

@test "nginx configuration is valid" {
    CONTAINER_ID=$(docker run -d "$IMAGE")
    export CONTAINER_ID
    
    # Test nginx configuration
    run docker exec "$CONTAINER_ID" /opt/bitnami/nginx/sbin/nginx -t
    [ "$status" -eq 0 ]
    [[ "$output" =~ "syntax is ok" ]]
    [[ "$output" =~ "test is successful" ]]
}

@test "container exposes correct ports" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 -p 8443:8443 "$IMAGE")
    export CONTAINER_ID
    
    # Check if ports are exposed
    port_info=$(docker port "$CONTAINER_ID")
    [[ "$port_info" =~ "8080" ]]
    [[ "$port_info" =~ "8443" ]]
}

@test "container supports custom configuration" {
    # Create temporary nginx config
    temp_config=$(mktemp)
    cat > "$temp_config" << 'EOF'
server {
    listen 8080;
    location / {
        return 200 "Custom config test\n";
        add_header Content-Type text/plain;
    }
}
EOF

    CONTAINER_ID=$(docker run -d -p 8080:8080 \
        -v "$temp_config:/opt/bitnami/nginx/conf/server_blocks/custom.conf" \
        "$IMAGE")
    export CONTAINER_ID
    
    # Wait for nginx to restart with new config
    sleep 5
    
    # Test custom response
    run curl -f -s http://localhost:8080/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Custom config test" ]]
    
    # Cleanup
    rm -f "$temp_config"
}

@test "container handles reload gracefully" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$IMAGE")
    export CONTAINER_ID
    
    # Wait for container to start
    sleep 3
    
    # Send reload signal
    docker exec "$CONTAINER_ID" /opt/bitnami/scripts/nginx/reload.sh
    
    # Wait for reload
    sleep 2
    
    # Test if nginx still serves requests
    run curl -f -s http://localhost:8080/
    [ "$status" -eq 0 ]
}

@test "container environment variables work" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 \
        -e NGINX_HTTP_PORT_NUMBER=8080 \
        "$IMAGE")
    export CONTAINER_ID
    
    # Wait for container to start
    sleep 5
    
    # Test if nginx responds on configured port
    run curl -f -s http://localhost:8080/
    [ "$status" -eq 0 ]
}

@test "container logs are accessible" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$IMAGE")
    export CONTAINER_ID
    
    # Wait for container to generate some logs
    sleep 3
    curl -s http://localhost:8080/ >/dev/null || true
    
    # Check if logs are available
    run docker logs "$CONTAINER_ID"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "container supports multi-architecture" {
    # Check image manifest for multiple architectures
    if command -v docker >/dev/null 2>&1 && docker buildx version >/dev/null 2>&1; then
        # This would typically be run in CI with proper multi-arch images
        skip "Multi-arch test requires specific CI setup"
    else
        skip "Docker buildx not available for multi-arch testing"
    fi
}

@test "performance characteristics are acceptable" {
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$IMAGE")
    export CONTAINER_ID
    
    # Wait for container to start
    sleep 5
    
    # Simple performance test - should respond within reasonable time
    start_time=$(date +%s%3N)
    curl -f -s http://localhost:8080/ >/dev/null
    end_time=$(date +%s%3N)
    
    response_time=$((end_time - start_time))
    
    # Should respond within 1000ms (1 second) for basic request
    [ "$response_time" -lt 1000 ]
}
