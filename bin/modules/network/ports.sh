#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120
ports() {
    available() {
        target="${1}"
        if [[ ! "${target}" == *":"* ]]; then
            target="127.0.0.1:${target}"
        fi
        IFS=':' read -r host ports <<<"$target"
        IFS='-' read -r start end <<<"$ports"
        port=start
        # IFS=':' read -r -a ip ports <<<"$target"
        # ip="$(extract_ip ${target})"
        for ((port = start; port <= end; port++)); do
            # state="$(cat < /dev/tcp/"$host"/$port > /dev/null 2>&1 && echo "open" || echo "closed")"
            if [[ $(timeout 3 nc -zv "${host}" $port 2>&1) = *succeeded* ]]; then
            # if [ "$state" = "closed" ]; then
                # echo "Port opened ${host} ${start}/${end} = ${port}"
                continue
            else
                # echo "Port closed ${host} ${start}/${end} = ${port}"
                break
            fi
            # open="$((echo >/dev/tcp/$host/$port)> /dev/null 2>&1 && echo y || echo n)"
            # echo "${host}:${port} -> ${open}"
            # echo "Port scan ${host} ${start}/${end} = ${port}"

            # (echo >/dev/tcp/$host/$port)> /dev/null 2>&1 && break || continue
            # (echo >/dev/tcp/$host/$start)> /dev/null 2>&1 && echo "open" || echo "closed"
        done 2>/dev/null
        echo "${port}"
    }
    action="${1}"
    args=("${@:2}")
    $action "${args[@]}"
}
