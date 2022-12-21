#!/usr/bin/env bash

function racher_deploy(){
    std_log "Deploying$GREEN Rancher Dashboard"    
    # -f apps/traefik.values.yaml \
    R=$(helm upgrade \
        --atomic \
        --cleanup-on-fail \
        --install \
        --create-namespace \
        --namespace cattle-system \
        --reset-values \
        --wait \
        --repo=https://releases.rancher.com/server-charts/latest \
        --set bootstrapPassword=admin \
        --set hostname=rancher."${HL_CLUSTER_DOMAIN}" \
        --set replicas=2 \
        --set ingress.tls.source=rancher \
        rancher rancher | tr '\n' '|')
    std_debug_array "${R}" "|"
    wait_for_pod "rancher" "cattle-system"
    R=$(kubectl get all -n cattle-system | tr '\n' '|')
    std_array "${R}" "|"
    std_success "Deploy done"
}