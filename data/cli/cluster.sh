#!/usr/bin/env bash

# shellcheck disable=SC2119,SC2317,SC2317,SC2120
function d2k_cluster() {
    local actions providers action target before after
    actions=('create delete start stop bootstrap info kubectl network_range')
    providers=('k3d multipass')
    action="${2}"
    provider="$3"
    target="cluster_${provider}"
    before="before_${action}"
    after="after_${action}"

    export HL_CLUSTER_NAME="${4:-$HL_CLUSTER_NAME}"
    update_env

    usage() {
        std_info "${WARN}cluster$NORMAL <action> <provider>"
        std_info "- <actions>  ${actions[*]}"
        std_info "- <provider>  ${providers[*]}"
    }
    info() {
        std_line
        std_line
        std_log "Cluster name: $GREEN${HL_CLUSTER_NAME}"
        std_log "K8s server:$GREEN https://0.0.0.0:$BLUE${HL_CLUSTER_API_PORT}"
        std_log "Ingress Load Balancer: $GREEN$NGINX_LB_EXTERNAL_IP"
        std_log "Open sample app in browser:$GREEN http://$NGINX_LB_EXTERNAL_IP/sampleapp"
        std_log "To switch to this cluster use$GREEN export KUBECONFIG=\$(k3d kubeconfig write ${HL_CLUSTER_NAME})"
        std_log "Then kubectl$GREEN cluster-info"
        std_log "To stop this cluster (If running), run:$GREEN k3d cluster stop $HL_CLUSTER_NAME"
        std_log "To start this cluster (If stopped), run:$GREEN k3d cluster start $HL_CLUSTER_NAME"
        std_log "To delete this cluster, run:$GREEN k3d cluster delete $HL_CLUSTER_NAME"
        std_log "To list all clusters, run:$GREEN k3d cluster list"
        std_log "To switch to another cluster (In case of multiple clusters), run:$GREEN kubectl config use-context k3d-<CLUSTERNAME>"
        std_line
        std_log "- Traefik$GREEN kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000"
        std_line

        R=$(kubectl config get-contexts | tr '\n' '|')
        std_array "${R}" "|"
        R=$(kubectl get nodes | tr '\n' '|')
        std_array "${R}" "|"
        R=$(kubectl get all -A | tr '\n' '|')
        std_array "${R}" "|"
    }
    boostrap() {
        std_info "Cluster boostrap"
        # cluster_dns_managed_setup
        local apps app deloy
        apps="${HL_CLUSTER_APPS}"
        IFS=',' read -r -a HL_CLUSTER_APPS <<<"$apps"
        if [ "${#HL_CLUSTER_APPS[@]}" -gt 0 ]; then
            for index in "${!HL_CLUSTER_APPS[@]}"; do
                app="${HL_CLUSTER_APPS[index]}"
                # deloy="${HL_CLUSTER_APPS[index]}_deploy"
                std_info "Deploying $index ${app}"
                $app "deploy"
            done
        fi
    }
    validate() {
        if [[ ! ${actions[*]} =~ (^|[[:space:]])"${action}"($|[[:space:]]) ]]; then
            std_error "'${action}' is not valid action"
        fi
        if [[ ! ${providers[*]} =~ (^|[[:space:]])"${provider}"($|[[:space:]]) ]]; then
            std_error "'${provider}' is not valid provider"
        fi
    }
    before_delete() {
        return
    }
    after_delete() {
        etc_hosts remove "${HL_CLUSTER_INTERNAL_DOMAIN}"
        rm -rf "${HL_PATH}/${HL_CLUSTER_NAME}"
    }
    before_create() {
        std_info "Setuping local cluster ${WARN}${HL_CLUSTER_NAME}${NORMAL} environment"
        # etc_hosts check "${HL_CLUSTER_INTERNAL_DOMAIN}"
        etc_hosts add "${HL_CLUSTER_INTERNAL_DOMAIN}" "127.0.0.1"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/manifests/d2k"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/logs/"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/volumes/shared"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/volumes/data"
        cp -r "${HL_SCRIPT_ASSETS}/k3d"/* "${HL_PATH}/${HL_CLUSTER_NAME}/manifests/d2k"
    }
    after_create() {
        std_array "$(kubectl cluster-info | tr '\n' '|')" "|"
        boostrap
        info
    }

    is_valid=$(validate)
    if [ ! "$is_valid" = "" ]; then
        std_error "${is_valid}"
        usage
        return
    fi
    if [ "$action" = "create" ] || [ "$action" = "delete" ]; then
        $before "$@"
        $target "$@"
        $after "$@"
    else
        $target "$@"
    fi

    # case $action in
    # help)
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

cluster_wait_for_pod() {
    local name namespace
    name=$1
    namespace=${2:-default}
    kind=${3:-pods}
    std_log "Waiting for ${WARN}${kind}${NORMAL} ($GREEN${namespace}:${name}${NORMAL}) ${GREEN}up"
    until [[ $(kubectl get "${kind}" -n "${namespace}" -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep "${name}" | awk -F " " '{print $1}' | tail -1) = 'True' ]]; do
        spin
    done
    endspin
}