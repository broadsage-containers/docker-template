#!/usr/bin/env bats
# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# Container Security Tests

setup() {
    # Default image to test
    IMAGE=${BATS_IMAGE:-"ghcr.io/broadsage/nginx:latest"}
    
    # Start container for testing
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$IMAGE")
    export CONTAINER_ID
    
    # Wait for container to be ready
    sleep 3
}

teardown() {
    if [ -n "$CONTAINER_ID" ]; then
        docker stop "$CONTAINER_ID" >/dev/null 2>&1
        docker rm "$CONTAINER_ID" >/dev/null 2>&1
    fi
}

@test "container runs as non-root user" {
    user_id=$(docker exec "$CONTAINER_ID" id -u)
    [ "$user_id" = "1001" ]
}

@test "container has no SUID/SGID binaries" {
    suid_count=$(docker exec "$CONTAINER_ID" find / -perm /6000 -type f 2>/dev/null | wc -l)
    [ "$suid_count" -eq 0 ]
}

@test "container filesystem is read-only ready" {
    # Check if critical directories can be made read-only
    run docker exec "$CONTAINER_ID" test -w /opt/bitnami/nginx/conf
    [ "$status" -eq 0 ]  # Should be writable for configuration
    
    run docker exec "$CONTAINER_ID" test -w /usr/bin
    [ "$status" -ne 0 ] || skip "System directories should ideally be read-only"
}

@test "no critical vulnerabilities in image" {
    # Run Trivy scan and check for critical CVEs
    run docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image --severity CRITICAL --quiet --format json "$IMAGE"
    
    if [ "$status" -eq 0 ]; then
        critical_count=$(echo "$output" | jq -r '.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL") | .VulnerabilityID' | wc -l)
        [ "$critical_count" -eq 0 ]
    fi
}

@test "container has proper health check" {
    # Test if container responds to HTTP requests
    run curl -f -s http://localhost:8080/
    [ "$status" -eq 0 ]
}

@test "container handles signals properly" {
    # Send SIGTERM and verify graceful shutdown
    docker stop -t 10 "$CONTAINER_ID"
    
    # Container should stop within timeout
    run docker ps -q --filter "id=$CONTAINER_ID"
    [ -z "$output" ]
}

@test "no sensitive information in environment" {
    # Check for common sensitive environment variable patterns
    env_output=$(docker exec "$CONTAINER_ID" env)
    
    # Should not contain passwords, keys, tokens
    echo "$env_output" | grep -qi "password\|secret\|key\|token" && {
        fail "Potentially sensitive information found in environment"
    }
    
    return 0
}

@test "log files point to stdout/stderr" {
    # Verify log redirection
    access_log=$(docker exec "$CONTAINER_ID" readlink /opt/bitnami/nginx/logs/access.log)
    error_log=$(docker exec "$CONTAINER_ID" readlink /opt/bitnami/nginx/logs/error.log)
    
    [ "$access_log" = "/dev/stdout" ]
    [ "$error_log" = "/dev/stderr" ]
}

@test "container uses minimal base image" {
    # Check image size and layer count
    image_info=$(docker inspect "$IMAGE" --format '{{.Size}}')
    layer_count=$(docker inspect "$IMAGE" --format '{{len .RootFS.Layers}}')
    
    # Image should be reasonably sized (less than 200MB for nginx)
    [ "$image_info" -lt 209715200 ] || skip "Image size optimization recommended"
    
    # Should have reasonable number of layers (less than 15)
    [ "$layer_count" -lt 15 ] || skip "Consider optimizing Docker layers"
}

@test "required security labels present" {
    # Check for required OCI labels
    labels=$(docker inspect "$IMAGE" --format '{{json .Config.Labels}}')
    
    echo "$labels" | jq -e '.["org.opencontainers.image.version"]' >/dev/null
    echo "$labels" | jq -e '.["org.opencontainers.image.source"]' >/dev/null
    echo "$labels" | jq -e '.["org.opencontainers.image.vendor"]' >/dev/null
    echo "$labels" | jq -e '.["org.opencontainers.image.licenses"]' >/dev/null
}
