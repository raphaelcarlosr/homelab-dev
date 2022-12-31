#!/usr/bin/env bash
export D2K_ENV_FILE=${D2K_SCRIPT_DIR}/.env
export D2K_SSH_PRIVATE_KEY=${D2K_CONFIG_ENV_PATH}/.ssh
export D2K_SSH_PUBLIC_KEY=${D2K_SSH_PRIVATE_KEY}.pub
export D2K_SSH_PUBLIC_KEY_CONTENT=
export D2K_RUNTIME_ERRORS=()


get_secrets() {
    return 1
    # if [ -f "${D2K_ENV_FILE}" ]; then
    #     # sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${D2K_ENV_FILE}"
    #     set -o allexport
    #     # shellcheck source=/dev/null
    #     source <(sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${D2K_ENV_FILE}")
    #     set +o allexport
    # fi
}
parse_config() {
    local config _var name value vars
    vars=()
    config="$(niet -f eval "." "${D2K_SCRIPT_CONFIG}/d2k.yaml" | sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" | tr ';' $'\n')"
    readarray -t vars <<<"$config"
    for _var in "${vars[@]}"; do
        _var="${_var//__/_}"
        # _var="$(echo "${_var}" | sed -e "s/\_\_/\_/g")"
        IFS='=' read -r name value <<<"$_var"
        name="D2K_CONFIG_${name^^}"
        # echo "${name} ${value} ${D2K_CONFIG_LOG_LEVEL}"
        # [ -v "$name" ] && echo "$name is set"
        vars+=("${name}=${value}")
        # set -o allexport
        # # shellcheck source=/dev/null
        # source <(echo "${name}=${value}")
        # set +o allexport
    done
    # echo "${vars[*]}"
    set -o allexport
    # shellcheck source=/dev/null
    source <(echo "${vars[*]}")
    set +o allexport
    # set -o allexport
    # export D2K_CONFIG_NETWORK_EXTERNAL_IP="${D2K_CONFIG_NETWORK_EXTERNAL_IP//\"/}"
    # eval "$(niet -f eval "." "${D2K_SCRIPT_CONFIG}"/d2k.yaml)" &>/dev/null
    # set +o allexport
}
show_config() {
    section="${1}" 
    printenv | grep "D2K_${section}" | sort | std_buf
}


get_secrets
parse_config

export D2K_POSITIONAL_ARGS=()
export D2K_FLAGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
    --set)
        IFS='=' read -r key value <<<"${2}"
        name="${key//-/_}"
        name="D2K_CONFIG_${name^^}"
        is_set="$(variable_is_set "${name}")"
        if [ "${is_set}" -eq 0 ]; then
            D2K_RUNTIME_ERRORS+=("${RED}${key}${NORMAL} as ${BLUE}${name}${NORMAL} with value ${WARN}${value}${NORMAL} is not valid option")
        else
            # echo "${name} = ${value}"
            set -o allexport
            # shellcheck source=/dev/null
            source <(echo "${name}=${value}")
            set +o allexport            
        fi
        # value="$(echo "${value}" | sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g")"
        # echo "${name} ${value}"        
        shift # past argument
        shift # past value
        ;;
    -* | --*)
        D2K_FLAGS+=("$RED${1:-nil}(Unexpected) = ${2:-nil}")
        shift # past argument
        shift # past value
        continue
        ;;
    *)
        D2K_POSITIONAL_ARGS+=("$1") # save positional arg
        shift                   # past argument
        ;;
    esac
done
set -- "${D2K_POSITIONAL_ARGS[@]}"

parse_config