#!/usr/bin/env bash

function cert_manager_deploy(){
    std_log "Deploying$GREEN Cert Manager"    
    # -f apps/traefik.values.yaml \
    R=$(helm upgrade \
        --atomic \
        --cleanup-on-fail \
        --install \
        --create-namespace \
        --namespace cert-manager \
        --reset-values \
        --wait \
        --repo=https://charts.jetstack.io \
        --version v1.10.1 \
        --set installCRDs=true \
        --set prometheus.enabled=true \
        --set webhook.timeoutSeconds=4 \
        cert-manager cert-manager | tr '\n' '|')
    std_debug_array "${R}" "|"
    wait_for_pod "controller" "cert-manager"
    std_success "Deploy done"
}