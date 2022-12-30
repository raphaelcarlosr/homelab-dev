#!/usr/bin/env bash

cluster_cli(){
    load "modules/cluster"
    local engines actions action engine name args
    engines="${D2K_PKG_FILES[*]}"
    actions=('create delete start stop bootstrap info kubectl')
    action="${1}"
    engine="${2}"
    name="${3:-$D2K_CONFIG_CLUSTER_NAME}"
    export D2K_CONFIG_CLUSTER_NAME=$name
    args=( "${@:4}" )

    if [[ ! ${actions[*]} =~ (^|[[:space:]])"${action}"($|[[:space:]]) ]]; then
        std_error "'${action}' is not valid action, try use ${actions[*]}"
        return 0
    fi
    if [ "$(fn_exists "cluster_${engine}")" = 0 ]; then
        std_error "'$RED${engine}$NORMAL' is not valid engine, try use $GREEN${engines[*]}"
        return 0
    fi
    requirement_cli kubectl

    before_create(){ 
        network_cli etc_hosts add "${D2K_CONFIG_CLUSTER_NETWORK_INTERNAL_HOST}" "127.0.0.1"
        mkdir -p "${D2K_CONFIG_ENV_PATH}/${D2K_CONFIG_CLUSTER_NAME}/manifests/d2k"
        mkdir -p "${D2K_CONFIG_ENV_PATH}/${D2K_CONFIG_CLUSTER_NAME}/logs/"
        mkdir -p "${D2K_CONFIG_ENV_PATH}/${D2K_CONFIG_CLUSTER_NAME}/volumes/shared"
        mkdir -p "${D2K_CONFIG_ENV_PATH}/${D2K_CONFIG_CLUSTER_NAME}/volumes/data"
        # cp -r "${D2K_SCRIPT_ASSETS}/k3d"/* "${D2K_CONFIG_ENV_PATH}/${D2K_CONFIG_CLUSTER_NAME}/manifests/d2k"
    }

    before="before_${action}"
    fn="cluster_${engine}"
    after="after_${action}"
    std_debug "$GREEN${engine}$NORMAL engine" "std_info"
    if [ "$(fn_exists "${before}")" = 1 ]; then $before; fi    
    $fn "${action}" "${name}" "${args[@]}"
    if [ "$(fn_exists "${after}")" = 1 ]; then $after; fi

    

    # return 1
    # if [[ ${engines[*]} =~ (^|[[:space:]])"${engine}"($|[[:space:]]) ]]; then
    #     std_success "$GREEN${engine}$NORMAL engine"
    #     fn="cluster_${engine}"
    #     $fn "${action}" "${args[@]}"
    # elif [ "$(fn_exists "cluster_${engine}")" = 1 ]; then
    #     std_debug "$GREEN${engine}$NORMAL requirement" "std_info"
    #     fn="cluster_${engine}"
    #     $fn "${args[@]}"        
    # elif [ "$(fn_exists "${engine}")" = 1 ]; then
    #     std_success "$GREEN${engine}$NORMAL function"
    #     $engine "${args[@]}"
    # else        
    #     std_error "'$RED${engine}$NORMAL' is not valid program, try use $GREEN${engines[*]}"
    # fi
}

cluster_wait_for() {
    local name namespace
    name=$1
    namespace=${2:-default}
    kind=${3:-pods}
    std_info "Waiting for ${WARN}${kind}${NORMAL} ($GREEN${namespace}/${name}${NORMAL}) ${GREEN}up"
    until [[ $(kubectl get "${kind}" -n "${namespace}" -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep "${name}" | awk -F " " '{print $1}' | tail -1) = 'True' ]]; do
        spin
    done
    endspin
    # kubectl get "${kind}" -n "${namespace}" | std_buf
}