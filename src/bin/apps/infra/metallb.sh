#!/usr/bin/env bash

function metallb_mafinest(){
    local manifest
    manifest=$(mktemp).yaml
    HL_NETWORK_IP_RANGE="${HL_NETWORK_IP_RANGE:-$(k3d_network_range | tail -1)}"
    std_log "${HL_NETWORK_IP_RANGE}"
    < "$BASE_DIR/apps/metallb.k8s.yaml" envsubst  > "${manifest}"
    echo "${manifest}"
}

function metallb_install(){
    metallbVersion="v0.13.7"   
    std_header "Deploying MetalLB. ${metallbVersion}"
    kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${metallbVersion}/config/manifests/metallb-native.yaml" 
    wait_for_pod "controller" "metallb-system"
    cat "$(metallb_mafinest | tail -1)" | envsubst | kubectl apply -f -
    kubectl get all -n metallb-system
    std_success "Instalation done"
}
function metallb_uninstall(){
    std_header "Unistalling MetalLB. ${metallbVersion}"
}
function metallb_cli(){
    opt="$3"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Metallb ${action}"
    case $action in
    install) metallb_install "$@" ;;
    uninstall) metallb_uninstall "$@" ;;
    *)
        std_info "Usage"
        ;;
    esac
}