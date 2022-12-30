#!/usr/bin/env bash
export D2K_ENV_FILE=${D2K_SCRIPT_DIR}/.env
export D2K_SSH_PRIVATE_KEY=${D2K_CONFIG_ENV_PATH}/.ssh
export D2K_SSH_PUBLIC_KEY=${D2K_SSH_PRIVATE_KEY}.pub
export D2K_SSH_PUBLIC_KEY_CONTENT=

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
# parse_flags() {

# }

get_secrets
# parse_flags "$@"

POSITIONAL_ARGS=()
D2K_FLAGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
    --set)
        IFS='=' read -r name value <<<"${2}"
        name="${name//-/_}"
        name="D2K_CONFIG_${name^^}"
        # value="$(echo "${value}" | sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g")"
        # echo "${name} ${value}"
        set -o allexport
        # shellcheck source=/dev/null
        source <(echo "${name}=${value}")
        set +o allexport
        shift # past argument
        shift # past value
        ;;
    # --debug)
    #     D2K_DEBUG=${2:-${D2K_DEBUG}} # "$2"
    #     export D2K_DEBUG
    #     D2K_FLAGS+=("$GREEN${1:-nil}(D2K_DEBUG) = ${2:-nil}")
    #     shift # past argument
    #     shift # past value
    #     ;;
    # -p | --path)
    #     D2K_CONFIG_ENV_PATH=${2:-${D2K_CONFIG_ENV_PATH}} # "$2"
    #     export D2K_CONFIG_ENV_PATH
    #     D2K_FLAGS+=("$GREEN${1:-nil}(D2K_CONFIG_ENV_PATH) = ${2:-nil}")
    #     shift # past argument
    #     shift # past value
    #     ;;
    # -d | --domain)
    #     D2K_DOMAIN=${2:-${D2K_DOMAIN}} # "$2"
    #     export D2K_DOMAIN
    #     D2K_FLAGS+=("$GREEN${1:-nil}(D2K_DOMAIN) = ${2:-nil}")
    #     shift # past argument
    #     shift # past value
    #     ;;
    # --cluster-name)
    #     D2K_CLUSTER_NAME=${2:-${D2K_CLUSTER_NAME}} # "$2"
    #     export D2K_CLUSTER_NAME
    #     D2K_FLAGS+=("$GREEN${1:-nil}(D2K_CLUSTER_NAME) = ${2:-nil}")
    #     shift # past argument
    #     shift # past value
    #     ;;
    -* | --*)
        D2K_FLAGS+=("$RED${1:-nil}(Unexpected) = ${2:-nil}")
        shift # past argument
        shift # past value
        continue
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift                   # past argument
        ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}"
export D2K_FLAGS

parse_config
