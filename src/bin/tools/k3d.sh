#!/usr/bin/env bash

function k3d_create() {
    std_log "K3d create"
    k3d_delete    
    temp_file=$(mktemp).yaml
    envsubst < "${HL_SCRIPT_SRC}/assets/resources/k3d.yaml" > "${temp_file}"
    std_log "k3d parsed config file ${temp_file}"
    # cat "${temp_file}"    
    mkdir -p "${HL_PATH}/volumes/${HL_CLUSTER_NAME}"  
    std_log "Creating cluster"  
    cluster=$(k3d cluster create --config "${temp_file}")
    rm -f "${temp_file}"
    config=$(k3d_kubectl)
    std_log "Kubeconfig ${config}"
    wait_for_pod "coredns" "kube-system"    
    network_range=$(k3d_network_range | tail -1)
    std_log "Load balancer network range $GREEN ${network_range}"   
    # std_log "${cluster}" 
}

function k3d_network_range(){
    cidr_block=$(docker network inspect "${HL_CLUSTER_NAME}"-net | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
    base_addr=${cidr_block%???}
    first_addr=$(echo "$base_addr" | awk -F'.' '{print $1,$2,$3,240}' OFS='.')
    local NETWORK_IP_RANGE
    NETWORK_IP_RANGE=$first_addr/29
    export HL_K3D_NETWORK_IP_RANGE=$NETWORK_IP_RANGE
    echo "${HL_K3D_NETWORK_IP_RANGE}"
}

function k3d_exists(){
    local hasCluster
    hasCluster=$(k3d cluster list | grep -w "${HL_CLUSTER_NAME}" | cut -d " " -f 1)
    if [ "$hasCluster" == "${HL_CLUSTER_NAME}" ]; then        
        echo 1
    else 
        echo 0
    fi
    
}

function k3d_kubectl(){
    KUBECONFIG=$(k3d kubeconfig write "${HL_CLUSTER_NAME}")
    export KUBECONFIG
    echo "${KUBECONFIG}"
}

function k3d_delete() {
    std_log "Deleting k3d cluster ${HL_CLUSTER_NAME}"
    if [ "$(k3d_exists)" == 1 ]; then        
        result=$(k3d cluster delete "${HL_CLUSTER_NAME}")
        std_log "Cluster deleted" # ${result}"
    fi
}

function k3d_start() {
    std_header "K3d start"
    k3d cluster start "${HL_CLUSTER_NAME}"
}

function k3d_stop() {
    std_header "K3d stop"
    k3d cluster stop "${HL_CLUSTER_NAME}"
}

# function k3d_cli() {
#     opt="$3"
#     action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
#     # std_header "K3d cli ${action}"
#     case $action in
#     up) k3d_up ;;
#     down) k3d_down ;;
#     start) k3d_start ;;
#     stop) k3d_stop ;;
#     *)
#         std_info "Usage"
#         ;;
#     esac
# }
