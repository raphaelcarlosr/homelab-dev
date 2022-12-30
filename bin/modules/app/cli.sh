#!/usr/bin/env bash
app_cli(){
    local apps app args fn
    load "modules/app"    
    apps="${D2K_PKG_FILES[*]}"
    app="${1}"
    fn="${app}_app"
    args=( "${@:2}" )
    if [[ ${apps[*]} =~ (^|[[:space:]])"${app}"($|[[:space:]]) ]]; then
        std_info "$GREEN${args[0]^} ${WARN}${app} "
        $fn "${args[@]}"
    else        
        std_error "'$RED${app:-null}$NORMAL' is not valid app, try use $GREEN${apps[*]}"
    fi
}