#!/usr/bin/env bash

metallb_app(){
    local action version
    action="${1}"
    version="${2:-v0.13.7}"
    deploy(){
        std_log "Version. ${version}"
        spinner "kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${version}/config/manifests/metallb-native.yaml""
        cluster_wait_for "controller" "metallb-system" &  cluster_wait_for "speaker" "metallb-system"
        kubectl get all -n metallb-system | std_buf
    }

    delete(){
        spinner "kubectl delete -f "https://raw.githubusercontent.com/metallb/metallb/${version}/config/manifests/metallb-native.yaml""
        kubectl get all -n metallb-system | std_buf
    }

    if [ "$(fn_exists "${action}")" = 1 ]; then
        $action
    else 
        std_error "'${action}' is not valid action"
    fi
}

# function metallb_mafinest(){
#     local manifest
#     manifest=$(mktemp).yaml
#     HL_NETWORK_IP_RANGE="${HL_K3D_NETWORK_IP_RANGE:-$(k3d_network_range | tail -1)}"
#     export HL_NETWORK_IP_RANGE
#     std_log "MetalLB Network Range: ${HL_NETWORK_IP_RANGE}"
#     envsubst < "$HL_SCRIPT_DIR/apps/metallb.k8s.yaml" > "${manifest}"
#     echo "${manifest}"
# }

# function metallb_install(){
#     metallbVersion="v0.13.7"   
#     std_log "Deploying$GREEN MetalLB. ${metallbVersion}"
#     R=$(kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${metallbVersion}/config/manifests/metallb-native.yaml" | tr '\n' '|')
#     std_debug_array "${R}" "|"
#     wait_for_pod "controller" "metallb-system"
#     R=$(kubectl apply -f "$(metallb_mafinest | tail -1)")
#     std_debug "${R}"
#     R=$(kubectl get all -n metallb-system | tr '\n' '|')
#     std_array "${R}" "|"
#     std_success "Deploy done"
# }
# function metallb_uninstall(){
#     std_header "Unistalling MetalLB. ${metallbVersion}"
# }
# function metallb_cli(){
#     opt="$3"
#     action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
#     std_header "Metallb ${action}"
#     case $action in
#     install) metallb_install "$@" ;;
#     uninstall) metallb_uninstall "$@" ;;
#     *)
#         std_info "Usage"
#         ;;
#     esac
# }