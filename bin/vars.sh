#!/usr/bin/env bash
export HL_ENV_FILE=${HL_SCRIPT_DIR}/.env
export HL_SSH_PRIVATE_KEY=${HL_PATH}/.ssh
export HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
export HL_SSH_PUBLIC_KEY_CONTENT=

update_env(){
    if [ -f "${HL_ENV_FILE}" ]; then
        # sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${HL_ENV_FILE}"
        set -o allexport
        # shellcheck source=/dev/null
        source <(sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${HL_ENV_FILE}")
        set +o allexport
    fi
}
update_env



POSITIONAL_ARGS=()
HL_FLAGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
    --debug)
        HL_DEBUG=${2:-${HL_DEBUG}} # "$2"
        export HL_DEBUG
        HL_FLAGS+=("$GREEN${1:-nil}(HL_DEBUG) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -p | --path)
        HL_PATH=${2:-${HL_PATH}} # "$2"
        export HL_PATH
        HL_FLAGS+=("$GREEN${1:-nil}(HL_PATH) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -d | --domain)
        HL_DOMAIN=${2:-${HL_DOMAIN}} # "$2"
        export HL_DOMAIN
        HL_FLAGS+=("$GREEN${1:-nil}(HL_DOMAIN) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    --cluster-name)
        HL_CLUSTER_NAME=${2:-${HL_CLUSTER_NAME}} # "$2"
        export HL_CLUSTER_NAME
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_NAME) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;    
    -* | --*)
        HL_FLAGS+=("$RED${1:-nil}(Unexpected) = ${2:-nil}")
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
export HL_FLAGS
