#!/usr/bin/env bash

cluster_cli(){
    load "modules/cluster"
    local providers actions action provider name args
    providers="${HL_PKG_FILES[*]}"
    actions=('create delete start stop bootstrap info kubectl')
    action="${1}"
    provider="${2}"
    name="${3:-$HL_CLUSTER_NAME}"
    export HL_CLUSTER_NAME=$name
    args=( "${@:4}" )

    if [[ ! ${actions[*]} =~ (^|[[:space:]])"${action}"($|[[:space:]]) ]]; then
        std_error "'${action}' is not valid action, try use ${actions[*]}"
        return 0
    fi
    if [ "$(fn_exists "cluster_${provider}")" = 0 ]; then
        std_error "'$RED${provider}$NORMAL' is not valid provider, try use $GREEN${providers[*]}"        
    fi

    before_create(){ 
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/manifests/d2k"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/logs/"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/volumes/shared"
        mkdir -p "${HL_PATH}/${HL_CLUSTER_NAME}/volumes/data"
        # cp -r "${HL_SCRIPT_ASSETS}/k3d"/* "${HL_PATH}/${HL_CLUSTER_NAME}/manifests/d2k"
    }

    before="before_${action}"
    fn="cluster_${provider}"
    after="after_${action}"
    std_debug "$GREEN${provider}$NORMAL engine" "std_info"
    if [ "$(fn_exists "${before}")" = 1 ]; then $before; fi    
    $fn "${action}" "${name}" "${args[@]}"
    if [ "$(fn_exists "${after}")" = 1 ]; then $after; fi

    

    # return 1
    # if [[ ${providers[*]} =~ (^|[[:space:]])"${provider}"($|[[:space:]]) ]]; then
    #     std_success "$GREEN${provider}$NORMAL provider"
    #     fn="cluster_${provider}"
    #     $fn "${action}" "${args[@]}"
    # elif [ "$(fn_exists "cluster_${provider}")" = 1 ]; then
    #     std_debug "$GREEN${provider}$NORMAL requirement" "std_info"
    #     fn="cluster_${provider}"
    #     $fn "${args[@]}"        
    # elif [ "$(fn_exists "${provider}")" = 1 ]; then
    #     std_success "$GREEN${provider}$NORMAL function"
    #     $provider "${args[@]}"
    # else        
    #     std_error "'$RED${provider}$NORMAL' is not valid program, try use $GREEN${providers[*]}"
    # fi
}