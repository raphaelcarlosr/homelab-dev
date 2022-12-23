#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120

function traefik(){
    local action
    action="${1}"

    values(){
        # helm template traefik/traefik
        local values
        values=$(mktemp).yaml
        envsubst < "$HL_SCRIPT_ASSETS/apps/traefik.values.yaml" > "${values}"
        echo "${values}"
    }
    resources(){
        envsubst < "$HL_SCRIPT_ASSETS/apps/traefik.yaml"
    }
    deploy(){
        local values_manifest
        values_manifest=$(values | tail -1)        
        stdbuf -oL helm upgrade \
            -f "${values_manifest}" \
            --atomic \
            --cleanup-on-fail \
            --install \
            --reset-values \
            --create-namespace \
            --namespace=traefik \
            --repo=https://helm.traefik.io/traefik \
            --set installCRDs=true \
            traefik traefik | std_buf

        cluster_wait_for_pod "traefik" "traefik"
        resources | kubectl apply -f- | std_buf
        stdbuf -oL kubectl get all -n traefik | std_buf
        rm -f "${values_manifest}"
        std_success "Deploy done"
    }
    $action "$@"
}