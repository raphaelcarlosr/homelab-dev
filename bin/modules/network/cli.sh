#!/usr/bin/env bash

network_cli(){    
    load "modules/network"
    local programs program args
    programs="${HL_PKG_FILES[*]}"
    program="${1}"
    args=( "${@:2}" )
    if [[ ${programs[*]} =~ (^|[[:space:]])"${program}"($|[[:space:]]) ]]; then
        std_success "$GREEN${program}$NORMAL program"
        $program "${args[@]}"
    elif [ "$(fn_exists "${program}")" = 1 ]; then
        std_success "$GREEN${program}$NORMAL function"
        $program "${args[@]}"
    else        
        std_error "'$RED${program}$NORMAL' is not valid program, try use $GREEN${programs[*]}"
    fi
    
}