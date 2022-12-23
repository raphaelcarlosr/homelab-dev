#!/usr/bin/env bash

network_cli(){
    std_header "Cluster module"
    std_info "$*"
    load "modules/network"
    export HL_PKG_COMMON=("${HL_PKG_FILES[@]}")

    local program args
    program="${1}"
    args=( "${@:2}" )
    # $program "${args[@]}"
}