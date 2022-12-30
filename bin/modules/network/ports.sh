#!/usr/bin/env bash

ports() {
    available() {
        target="${1}"
        if [[ ! "${target}" == *":"* ]]; then
            target="127.0.0.1:${target}"
        fi
        IFS=':' read -r host ports <<<"$target"
        IFS='-' read -r start end <<<"$ports"
        # IFS=':' read -r -a ip ports <<<"$target"
        # ip="$(extract_ip ${target})"
        for ((port=$start; port<=$end; port++))
        do
            # echo "Port scan ${ip} ${start}/${end} = ${port}" 
            (echo >/dev/tcp/$host/$start)> /dev/null 2>&1 && break || continue
            # (echo >/dev/tcp/$ip/$start)> /dev/null 2>&1 && echo "open" || echo "closed" 
        done        
        echo "${port}"
    }

    action="${1}"
    args=("${@:2}")
    $action "${args[@]}"
}