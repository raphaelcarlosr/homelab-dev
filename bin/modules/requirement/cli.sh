#!/usr/bin/env bash

requirement_cli(){    
    load "modules/requirement"
    local programs program args
    programs="${HL_PKG_FILES[*]}"
    program="${1}"
    args=( "${@:2}" )    
    # if [[ ${programs[*]} =~ (^|[[:space:]])"${program}"($|[[:space:]]) ]]; then
    if [[ ${programs[*]} =~ (^|[[:space:]])"${program}"($|[[:space:]]) ]]; then
        std_debug "$GREEN${program}$NORMAL program" "std_info"
        $program "${args[@]}"
    elif [ "$(fn_exists "require_${program}")" = 1 ]; then
        std_debug "$GREEN${program}$NORMAL requirement" "std_info"
        fn="require_${program}"
        $fn "${args[@]}"
    elif [ "$(fn_exists "${program}")" = 1 ]; then
        std_debug "$GREEN${program}$NORMAL function" "std_info"
        $program "${args[@]}"    
    else        
        std_error "'$RED${program}$NORMAL' is not valid program, try use $GREEN${programs[*]}"
    fi    
}