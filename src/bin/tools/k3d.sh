#!/usr/bin/env bash

function k3d_network_range(){
    cidr_block=$(docker network inspect "${HL_NAME}"-net | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
    base_addr=${cidr_block%???}
    first_addr=$(echo "$base_addr" | awk -F'.' '{print $1,$2,$3,240}' OFS='.')
    local NETWORK_IP_RANGE
    NETWORK_IP_RANGE=$first_addr/29
    export HL_NETWORK_IP_RANGE=$NETWORK_IP_RANGE
    echo "${HL_NETWORK_IP_RANGE}"
}

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
    < "${SCRIPT_DIR}/assets/resources/k3d.yaml" envsubst > "${temp_file}"
    std_log "k3d parsed config file"
    # cat "${temp_file}"

    std_log "creating host volume"
    mkdir -p "${BASE_DIR}/volumes/${HL_NAME}"

    k3d cluster create --config "${temp_file}"
    k3d_set_config
    wait_for_pod "coredns" "kube-system"
    # k3d_network_range
    local network_range
    network_range=$(k3d_network_range | tail -1)
    std_log "Network range $GREEN ${network_range}"
}

function k3d_down() {
    std_header "K3d down"
    k3d_clear
}

function k3d_start() {
    std_header "K3d start"
    k3d cluster start "${HL_NAME}"
}

function k3d_stop() {
    std_header "K3d stop"
    k3d cluster stop "${HL_NAME}"
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
