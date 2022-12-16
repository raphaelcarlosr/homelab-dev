#!/usr/bin/env bash
HL_ENV_FILE=${HL_SCRIPT_DIR}/.env
HL_SSH_PRIVATE_KEY=${HL_PATH}/.ssh
HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
HL_SSH_PUBLIC_KEY_CONTENT=

export HL_ENV_FILE \
    HL_SSH_PRIVATE_KEY \
    HL_SSH_PUBLIC_KEY \
    HL_SSH_PUBLIC_KEY_CONTENT

if [ -f "${HL_ENV_FILE}" ]; then
    # shellcheck source=/dev/null
    source <(sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${HL_ENV_FILE}")
fi

# # https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL_ARGS=()
HL_FLAGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
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
    --default)
        DEFAULT=YES
        shift # past argument
        ;;
    # cluster cli options
    -cn | --cluster-name)
        HL_CLUSTER_NAME=${2:-${HL_CLUSTER_NAME}} # "$2"
        export HL_CLUSTER_NAME
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_NAME) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -cd | --cluster-domain)
        HL_CLUSTER_DOMAIN=${2:-${HL_CLUSTER_DOMAIN}} # "$2"
        export HL_CLUSTER_DOMAIN
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_DOMAIN) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -cm | --cluster-masters)
        HL_CLUSTER_SERVERS=${2:-${HL_CLUSTER_SERVERS}} # "$2"
        export HL_CLUSTER_SERVERS
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_SERVERS) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -cw | --cluster-workers)
        HL_CLUSTER_AGENTS=${2:-${HL_CLUSTER_AGENTS}} # "$2"
        export HL_CLUSTER_AGENTS
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_AGENTS) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -cap | --cluster-api-port)
        HL_CLUSTER_API_PORT=${2:-${HL_CLUSTER_API_PORT}} # "$2"
        export HL_CLUSTER_API_PORT
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_API_PORT) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -cp | --cluster-http-port)
        HL_CLUSTER_HTTP_PORT=${2:-${HL_CLUSTER_HTTP_PORT}} # "$2"
        export HL_CLUSTER_HTTP_PORT
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_HTTP_PORT) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -csp | --cluster-https-port)
        HL_CLUSTER_HTTPS_PORT=${2:-${HL_CLUSTER_HTTPS_PORT}} # "$2"
        export HL_CLUSTER_HTTPS_PORT
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_HTTPS_PORT) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -cdp | --cluster-dns-provider)
        HL_CLUSTER_MANAGED_DNS_PROVIDER=${2:-${HL_CLUSTER_MANAGED_DNS_PROVIDER}} # "$2"
        export HL_CLUSTER_MANAGED_DNS_PROVIDER
        HL_FLAGS+=("$GREEN${1:-nil}(HL_CLUSTER_MANAGED_DNS_PROVIDER) = ${2:-nil}")
        shift # past argument
        shift # past value
        ;;
    -* | --*)
        # std_error "Unknown option $1"
        HL_FLAGS+=("$RED${1:-nil}(Unexpected) = ${2:-nil}")
        shift # past argument
        shift # past value
        continue
        # exit 1
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift                   # past argument
        ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}"
export HL_FLAGS;
# set HL_PATH if not setted
while [[ -z $HL_PATH ]]; do
    read_value "Homelab path" "${HL_PATH}"
    export HL_PATH=${READ_VALUE}
done

# set HL_DOMAIN if not setted
if [[ -z $HL_DOMAIN ]]; then
    read_value "Domain" "${HL_DOMAIN}"
    export HL_DOMAIN=${READ_VALUE}
fi

# std_info "Current configuraiton"
# printenv | grep "HL_" | sort


# HL_CURRENT_EXTERNAL_IP=$(get_external_ip)

# if [ -f "${BASE_DIR}/.env" ]; then
#     # std_header "$SCRIPT_DIR"
#     # std_header "$BASE_DIR"
#     std_info "Using env file: $GREEN${BASE_DIR}/.env"
#     # export $(echo $(cat ${BASE_DIR}/.env | sed 's/#.*//g' | xargs | envsubst))
#     # export $(grep -v '^#' ${BASE_DIR}/.env | xargs | envsubst)
#     # export $( grep -vE "^(#.*|\s*)$" "${BASE_DIR}/.env" | xargs | envsubst)
#     set -o allexport # enable all variable definitions to be exported
#     source <(sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${BASE_DIR}/.env")
#     set +o allexport
# fi
# HL_SSH_PUBLIC_KEY_CONTENT=
# export HL_SSH_PUBLIC_KEY_CONTENT HL_CURRENT_EXTERNAL_IP

# export HL_PATH=${HL_PATH:-~/.homelab}
# export HL_NAME=${NAME:-${HL_NAME}}
# export HL_FQDN_DOMAIN=${FQDN_DOMAIN:-${HL_FQDN_DOMAIN}}

# export HL_SSH_PRIVATE_KEY=${HL_PATH}/.ssh
# export HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub

# export HL_CLUSTER_API_PORT=${CLUSTER_API_PORT:-${HL_CLUSTER_API_PORT}}
# export HL_CLUSTER_API_EXTERNAL_IP=${CLUSTER_API_EXTERNAL_IP:-${HL_CLUSTER_API_EXTERNAL_IP}}
# export HL_CLUSTER_HTTP_PORT=${CLUSTER_HTTP_PORT:-${HL_CLUSTER_HTTP_PORT}}
# export HL_CLUSTER_HTTPS_PORT=${CLUSTER_HTTPS_PORT:-${HL_CLUSTER_HTTPS_PORT}}
# export HL_CLUSTER_SERVERS=${CLUSTER_SERVERS:-${HL_CLUSTER_SERVERS}}
# export HL_CLUSTER_AGENTS=${CLUSTER_AGENTS:-${HL_CLUSTER_AGENTS}}
# export HL_CLUSTER_PV_SIZE=${CLUSTER_PV_SIZE:-${HL_CLUSTER_PV_SIZE}}

# export HL_NETWORK_IP_RANGE=
# export HL_NGINX_LB_EXTERNAL_IP=
# # NGINX_LB_EXTERNAL_IP=${HL_CLUSTER_DOMAIN:-NGINX_LB_EXTERNAL_IP}

# function read_path() {
#     if [[ -z $HL_NAME ]]; then
#         read_value "Homelab path" "${HL_PATH}"
#         export HL_PATH=${READ_VALUE}
#     fi
# }
# function read_name() {
#     if [[ -z $HL_NAME ]]; then
#         read_value "Cluster Name" "${HL_NAME}"
#         export HL_NAME=${READ_VALUE}
#     fi
# }
# function read_domain() {
#     if [[ -z $HL_FQDN_DOMAIN ]]; then
#         read_value "Cluster Domain" "${HL_FQDN_DOMAIN}"
#         export HL_CLUSTER_DOMAIN=${HL_FQDN_DOMAIN}
#     fi
# }
# function read_cluster_api_port() {
#     if [[ $HL_CLUSTER_API_PORT != ?(-)+([0-9]) ]]; then
#         # exit_with_message 1 "$HL_CLUSTER_API_PORT is not a port. Port must be a number"
#         read_value "Cluster API Port (recommended: 5000-5500)" "${HL_CLUSTER_API_PORT}"
#         export HL_CLUSTER_API_PORT=${READ_VALUE}
#     fi
# }
# function read_cluster_external_ip() {
#     if [[ -z $HL_CLUSTER_API_EXTERNAL_IP ]]; then
#         read_value "Cluster API IP" "${HL_CLUSTER_API_EXTERNAL_IP}"
#         export HL_CLUSTER_API_EXTERNAL_IP=${READ_VALUE}
#     fi
# }
# function read_http_port() {
#     if [[ -z $HL_CLUSTER_HTTP_PORT ]]; then
#         read_value "Cluster HTTP Port" "${HL_CLUSTER_HTTP_PORT}"
#         export HL_CLUSTER_HTTP_PORT=${READ_VALUE}
#     fi
# }
# function read_https_port() {
#     if [[ -z $HL_CLUSTER_HTTPS_PORT ]]; then
#         read_value "Cluster HTTPS Port" "${HL_CLUSTER_HTTPS_PORT}"
#         export HL_CLUSTER_HTTPS_PORT=${READ_VALUE}
#     fi
# }
# function read_cluster_masters() {
#     if [[ $HL_CLUSTER_SERVERS != ?(-)+([0-9]) ]]; then
#         read_value "Cluster Masters (1Gi memory per node is required)" "${HL_CLUSTER_SERVERS}"
#         export HL_CLUSTER_SERVERS=${READ_VALUE}
#     fi
# }
# function read_cluster_agents() {
#     if [[ $HL_CLUSTER_AGENTS != ?(-)+([0-9]) ]]; then
#         read_value "Cluster Workers (1Gi memory per node is required)" "${HL_CLUSTER_AGENTS}"
#         export HL_CLUSTER_AGENTS=${READ_VALUE}
#     fi
# }
# function read_cluster_pv_size() {
#     if [[ -z $HL_CLUSTER_PV_SIZE ]]; then
#         read_value "Cluster PV Size (Gi)" "${HL_CLUSTER_PV_SIZE}"
#         export HL_CLUSTER_PV_SIZE=${READ_VALUE}
#     fi
# }

# function read_input() {
#     read_path
#     read_name
#     read_domain
#     read_cluster_api_port
#     read_cluster_external_ip
#     read_http_port
#     read_https_port
#     read_cluster_masters
#     read_cluster_agents
#     read_cluster_pv_size
# }
# read_input
# std_info "Using applyed values"
# printenv | grep HL_ | sort -r
