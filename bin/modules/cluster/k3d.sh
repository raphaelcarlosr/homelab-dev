#!/usr/bin/env bash
cluster_k3d(){
    local action name
    action="${1}"
    name="${2:-$HL_CLUSTER_NAME}"
    export HL_CLUSTER_NAME=$name
    std_info "K3D - ${action} ${name}"

    delete() {
        local hasCluster
        hasCluster=$(k3d cluster list | grep -w "${name}" | cut -d " " -f 1)
        if [ "$hasCluster" == "${name}" ]; then     
            spinner "k3d cluster delete ${name}"
            std_info "Cluster ${name} deleted" # ${result}"
        fi
    }

    case "${action}" in
    create)
        delete
        std_info "Creating k3d cluster ${name}"
        config_file="${HL_SCRIPT_CONFIG}/k3d.yaml"
        # cat < "${config_file}" | envsubst
        spinner "k3d cluster create --config ${config_file} --agents-memory 2048MiB --servers-memory 2048MiB" "Creating Cluster"
        # k3d cluster create --config "${config_file}" --agents-memory 2048MiB --servers-memory 2048MiB | std_buf
        ;;
    *)
        std_error "cluster k3d Incorrect usage: -h for help"
        usage
        return
        ;;
    esac

}
function cluster_k3d1() {
    local action
    action="${2}"
    export HL_CLUSTER_NAME="${4:-$HL_CLUSTER_NAME}" 
    update_env
    usage() {
        std_info "Commands:"
        std_info "- add      <host> <ip>"
        std_info "- remove   <host>"
        std_info "- update   <host> <ip>"
        std_info "- check    <host>"
        std_info "- rollback"
        std_info "- import   <file or url> [--append]"
        std_info "- export   <file>"
    }
    delete() {
        local hasCluster
        hasCluster=$(k3d cluster list | grep -w "${HL_CLUSTER_NAME}" | cut -d " " -f 1)
        if [ "$hasCluster" == "${HL_CLUSTER_NAME}" ]; then     
            result=$(k3d cluster delete "${HL_CLUSTER_NAME}")
            std_info "Cluster ${HL_CLUSTER_NAME} deleted" # ${result}"
        fi
    }
    set_context(){
        KUBECONFIG=$(k3d kubeconfig write "${HL_CLUSTER_NAME}")
        export KUBECONFIG
        echo "${KUBECONFIG}"
    }
    create() {
        std_info "Creating K3D cluster $WARN${HL_CLUSTER_NAME}"
        delete
        config_file="${HL_SCRIPT_ASSETS}/resources/k3d.yaml"
        spinner "k3d cluster create --config ${config_file} --agents-memory 2048MiB --servers-memory 2048MiB" "Creating cluster"
        echo
        config=$(set_context)
        std_log "Kubeconfig ${config}"
        cluster_wait_for_pod "coredns" "kube-system"
        # cluster_wait_for_pod "traefik" "kube-system"
        network_range=$(network_range | tail -1)
        std_log "Load balancer network range $GREEN ${network_range}"   
    }
    network_range(){
        cidr_block=$(docker network inspect "${HL_CLUSTER_NAME}"-net | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
        base_addr=${cidr_block%???}
        first_addr=$(echo "$base_addr" | awk -F'.' '{print $1,$2,$3,240}' OFS='.')
        local NETWORK_IP_RANGE
        NETWORK_IP_RANGE=$first_addr/29
        export HL_NETWORK_IP_RANGE=$NETWORK_IP_RANGE
        echo "${HL_NETWORK_IP_RANGE}"
    }
    $action "$@"

    # case $action in
    # create)
    #     std_info "Creating K3D cluster $WARN${name}"
    #     ;;
    # -h)
    #     usage
    #     return
    #     ;;
    # *)
    #     std_error "Incorrect usage: -h for help. $RED${action}$NORMAL is inválid action"
    #     usage
    #     return
    #     ;;
    # esac
}
