#!/usr/bin/env bash

function registry() {
    reg_name="${0:-kind-registry}"
    reg_port="${1-5000}"
    log "Running registry ${reg_name} on port ${reg_port}"
    running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
    if [ "${running}" != 'true' ]; then
        docker run \
            -d --restart=always -p "127.0.0.1:${reg_port}:${reg_port}" --name "${reg_name}" \
            -v "$(pwd)"/auth:/auth \
            -e "REGISTRY_AUTH=htpasswd" \
            -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
            -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
            registry:2
    fi
}
