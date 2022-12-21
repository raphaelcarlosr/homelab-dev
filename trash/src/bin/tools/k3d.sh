#!/usr/bin/env bash

function k3d_create() {
    std_log "K3d create"
    k3d_delete    
    config_file="${HL_SCRIPT_SRC}/assets/resources/k3d.yaml" # $(mktemp).yaml
    # envsubst < "${HL_SCRIPT_SRC}/assets/resources/k3d.yaml" > "${temp_file}"
    # std_log "k3d parsed config file ${temp_file}"
    #cat "${temp_file}"
    std_log "Creating cluster"  
    spinner "k3d cluster create --config ${config_file} --agents-memory 2048MiB --servers-memory 2048MiB" "Creating cluster"     
    # cluster=$(k3d cluster create --config "${temp_file}" --agents-memory 2048MiB --servers-memory 2048MiB | tr '\n' '|')
    # std_debug "${cluster}"
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

# https://k3d.io/v5.4.6/usage/commands/k3d_cluster_create/
#   -a, --agents int                                                     Specify how many agents you want to create
#       --agents-memory string                                           Memory limit imposed on the agents nodes [From docker]
#       --api-port [HOST:]HOSTPORT                                       Specify the Kubernetes API server port exposed on the LoadBalancer (Format: [HOST:]HOSTPORT)
#                                                                         - Example: `k3d cluster create --servers 3 --api-port 0.0.0.0:6550`
#   -c, --config string                                                  Path of a config file to use
#   -e, --env KEY[=VALUE][@NODEFILTER[;NODEFILTER...]]                   Add environment variables to nodes (Format: KEY[=VALUE][@NODEFILTER[;NODEFILTER...]]
#                                                                         - Example: `k3d cluster create --agents 2 -e "HTTP_PROXY=my.proxy.com@server:0" -e "SOME_KEY=SOME_VAL@server:0"`
#       --gpus string                                                    GPU devices to add to the cluster node containers ('all' to pass all GPUs) [From docker]
#   -h, --help                                                           help for create
#       --host-alias ip:host[,host,...]                                  Add ip:host[,host,...] mappings
#       --host-pid-mode                                                  Enable host pid mode of server(s) and agent(s)
#   -i, --image string                                                   Specify k3s image that you want to use for the nodes
#       --k3s-arg ARG@NODEFILTER[;@NODEFILTER]                           Additional args passed to k3s command (Format: ARG@NODEFILTER[;@NODEFILTER])
#                                                                         - Example: `k3d cluster create --k3s-arg "--disable=traefik@server:0"
#       --k3s-node-label KEY[=VALUE][@NODEFILTER[;NODEFILTER...]]        Add label to k3s node (Format: KEY[=VALUE][@NODEFILTER[;NODEFILTER...]]
#                                                                         - Example: `k3d cluster create --agents 2 --k3s-node-label "my.label@agent:0,1" --k3s-node-label "other.label=somevalue@server:0"`
#       --kubeconfig-switch-context                                      Directly switch the default kubeconfig's current-context to the new cluster's context (requires --kubeconfig-update-default) (default true)
#       --kubeconfig-update-default                                      Directly update the default kubeconfig with the new cluster's context (default true)
#       --lb-config-override strings                                     Use dotted YAML path syntax to override nginx loadbalancer settings
#       --network string                                                 Join an existing network
#       --no-image-volume                                                Disable the creation of a volume for importing images
#       --no-lb                                                          Disable the creation of a LoadBalancer in front of the server nodes
#       --no-rollback                                                    Disable the automatic rollback actions, if anything goes wrong
#   -p, --port [HOST:][HOSTPORT:]CONTAINERPORT[/PROTOCOL][@NODEFILTER]   Map ports from the node containers (via the serverlb) to the host (Format: [HOST:][HOSTPORT:]CONTAINERPORT[/PROTOCOL][@NODEFILTER])
#                                                                         - Example: `k3d cluster create --agents 2 -p 8080:80@agent:0 -p 8081@agent:1`
#       --registry-config string                                         Specify path to an extra registries.yaml file
#       --registry-create NAME[:HOST][:HOSTPORT]                         Create a k3d-managed registry and connect it to the cluster (Format: NAME[:HOST][:HOSTPORT]
#                                                                         - Example: `k3d cluster create --registry-create mycluster-registry:0.0.0.0:5432`
#       --registry-use stringArray                                       Connect to one or more k3d-managed registries running locally
#       --runtime-label KEY[=VALUE][@NODEFILTER[;NODEFILTER...]]         Add label to container runtime (Format: KEY[=VALUE][@NODEFILTER[;NODEFILTER...]]
#                                                                         - Example: `k3d cluster create --agents 2 --runtime-label "my.label@agent:0,1" --runtime-label "other.label=somevalue@server:0"`
#   -s, --servers int                                                    Specify how many servers you want to create
#       --servers-memory string                                          Memory limit imposed on the server nodes [From docker]
#       --subnet 172.28.0.0/16                                           [Experimental: IPAM] Define a subnet for the newly created container network (Example: 172.28.0.0/16)
#       --timeout duration                                               Rollback changes if cluster couldn't be created in specified duration.
#       --token string                                                   Specify a cluster token. By default, we generate one.
#   -v, --volume [SOURCE:]DEST[@NODEFILTER[;NODEFILTER...]]              Mount volumes into the nodes (Format: [SOURCE:]DEST[@NODEFILTER[;NODEFILTER...]]
#                                                                         - Example: `k3d cluster create --agents 2 -v /my/path@agent:0,1 -v /tmp/test:/tmp/other@server:0`
#       --wait                                                           Wait for the server(s) to be ready before returning. Use '--timeout DURATION' to not wait forever. (default true)

