#!/usr/bin/env bash
cluster_kind(){
    local action name
    action="${1}"
    name="${2:-$D2K_CONFIG_CLUSTER_NAME}"
    export D2K_CONFIG_CLUSTER_NAME=$name
    std_info "Kind - ${action} ${name}"

    install() {
        if [[ "$(which kind)" == "" ]]; then
            std_log "kind not found. Installing."
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
        fi
        std_log "$GREEN$(kind --version)"
    }
    delete() {
        local hasCluster
        hasCluster=$(kind get clusters | grep -w "${name}" | cut -d " " -f 1)
        if [ "$hasCluster" == "${name}" ]; then     
            spinner "kind delete cluster -n ${name}"
            std_info "Cluster ${name} deleted" # ${result}"
        fi
    }


    install
    case "${action}" in
    create)
        delete
        config_file="${D2K_SCRIPT_CONFIG}/kind.yaml"
        # manifest=$(mktemp).yaml
        manifest=$(temp_file yaml)
        envsubst < "$config_file" > "${manifest}"
        yq_set_port_by_range ".networking.apiServerPort" "${manifest}" "n"
        # cat "${manifest}"        
        std_info "Creating kind cluster ${name} using config ${BLUE}${manifest}"  
        # cat < "${manifest}" # | envsubst
        stdbuf -oL kind create cluster --name "${name}" --config "${manifest}"  | std_buf               
        kubectl cluster-info --context "kind-${name}" | std_buf        
        ;;
    *)
        std_error "cluster kind Incorrect usage: -h for help"
        usage
        return
        ;;
    esac
}