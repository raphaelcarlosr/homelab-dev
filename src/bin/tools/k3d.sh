#!/usr/bin/env bash

function k3d_exists(){
    local hasCluster
    hasCluster=$(k3d cluster list | grep -w "${HL_NAME}" | cut -d " " -f 1)
    if [ "$hasCluster" == "${HL_NAME}" ]; then        
        echo 1
    else 
        echo 0
    fi
    
}

function k3d_clear(){
    std_header "Clearing k3d cluster ${HL_NAME}"
    local hasCluster
    hasCluster=$(k3d cluster list | grep -w "${HL_NAME}" | cut -d " " -f 1)
    if [ "$(k3d_exists)" == 1 ]; then        
        k3d cluster delete "${HL_NAME}"
    fi
    
}
function k3d_set_config(){
    KUBECONFIG=$(k3d kubeconfig write "${HL_NAME}")
    export KUBECONFIG
    # k9s --kubeconfig "${KUBECONFIG}"
}
function k3d_up() {
    std_header "K3d up"
    k3d_clear
    
    local temp_file

    temp_file=$(mktemp).yaml
    cat "${SCRIPT_DIR}/assets/resources/k3d.yaml" | envsubst > "${temp_file}"
    std_log "k3d parsed config file"
    # cat "${temp_file}"

    std_log "creating host volume"
    mkdir -p "${BASE_DIR}/volumes/${HL_NAME}"

    k3d cluster create --config "${temp_file}"
    k3d_set_config
    
    kubectl cluster-info
    kubectl config get-contexts
    kubectl get nodes     

    wait_for_pod "coredns" "kube-system"
}
function k3d_down() {
    std_header "K3d down"
}
function k3d_start() {
    std_header "K3d start"
}
function k3d_stop() {
    std_header "K3d stop"
}

function k3d_cli() {
    opt="$3"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    # std_header "K3d cli ${action}"
    case $action in
    up) k3d_up ;;
    down) k3d_down ;;
    start) k3d_start ;;
    stop) k3d_stop ;;
    *)
        std_info "Usage"
        ;;
    esac
}
