#!/usr/bin/env bash

function metallb_values(){
    local values
    values=$(mktemp).yaml
    < "$BASE_DIR/apps/traefik.yaml" envsubst  > "${values}"
    echo "${values}"
}

function traefik_install(){
    std_header "Deploying Traefik"
    helm upgrade \
        -f apps/traefik.values.yaml \
        --atomic \
        --cleanup-on-fail \
        --create-namespace \
        --install \
        --namespace=traefik \
        --repo=https://helm.traefik.io/traefik \
        --reset-values \
        --wait \
        traefik traefik
    
    wait_for_pod "traefik" "traefik"
    local manifest
    manifest=$(metallb_values | tail -1)
    # cat "${manifest}"
    kubectl apply -f "${manifest}" -n traefik
    wait_for_pod "traefik" "traefik"
    kubectl get all -n traefik
    std_success "Deploy done"
}

function traefik_cli(){
    opt="$3"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Traefik ${action}"
    case $action in
    install) traefik_install "$@" ;;
    *)
        std_info "Usage"
        ;;
    esac
}