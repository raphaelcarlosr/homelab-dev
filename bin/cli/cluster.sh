#!/usr/bin/env bash
function d2k_cluster() {
    local actions providers action target trigger
    actions=('create delete start stop bootstrap info kubectl')
    providers=('k3d multipass')
    action="${2}"
    provider="$3"
    target="cluster_${provider}"
    trigger="${action}"

    export HL_CLUSTER_NAME="${4:-$HL_CLUSTER_NAME}"
    update_env

    usage() {
        std_info "${WARN}cluster$NORMAL <action> <provider>"
        std_info "- <actions>  ${actions[*]}"
        std_info "- <provider>  ${providers[*]}"
    }
    delete() {
        etc_hosts delete "${HL_CLUSTER_INTERNAL_DOMAIN}"
        rm -rf "${HL_PATH}/${HL_CLUSTER_NAME}"
    }
    create() {
        std_info "Setuping local cluster ${WARN}${HL_CLUSTER_NAME}${NORMAL} environment"
        # etc_hosts check "${HL_CLUSTER_INTERNAL_DOMAIN}"
        etc_hosts add "${HL_CLUSTER_INTERNAL_DOMAIN}" "127.0.0.1"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/manifests/d2k"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/logs/"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/volumes/shared"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/volumes/data"
        cp -r "${HL_SCRIPT_ASSETS}/k3d"/* "${HL_PATH}/${HL_CLUSTER_NAME}/manifests/d2k"
    }
    validate() {
        if [[ ! ${actions[*]} =~ (^|[[:space:]])"${action}"($|[[:space:]]) ]]; then
            std_error "'${action}' is not valid action"
        fi
        if [[ ! ${providers[*]} =~ (^|[[:space:]])"${provider}"($|[[:space:]]) ]]; then
            std_error "'${provider}' is not valid provider"
        fi
    }

    is_valid=$(validate)
    if [ ! "$is_valid" = "" ]; then
        std_error "${is_valid}"
        usage
        return
    fi
    $trigger "$@"
    $target "$@"
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
    # local _pod, _namespace
    _pod=$1
    _namespace=${2:-default}
    std_log "Waiting for pod ($GREEN${_namespace}:${_pod}$BLUE) up"
    until [[ $(kubectl get pods -n "${_namespace}" -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep "${_pod}" | awk -F " " '{print $1}' | tail -1) = 'True' ]]; do
        spin
    done
    endspin
}
