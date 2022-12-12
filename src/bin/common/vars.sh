#!/usr/bin/env bash
std_header "Getting input"
export HL_CURRENT_EXTERNAL_IP=$(get_external_ip)

if [ -f "${BASE_DIR}/.env" ]; then
    # std_header "$SCRIPT_DIR"
    # std_header "$BASE_DIR"
    std_info "Using env file: $GREEN${BASE_DIR}/.env"
    # export $(echo $(cat ${BASE_DIR}/.env | sed 's/#.*//g' | xargs | envsubst))
    # export $(grep -v '^#' ${BASE_DIR}/.env | xargs | envsubst)
    # export $( grep -vE "^(#.*|\s*)$" "${BASE_DIR}/.env" | xargs | envsubst)
    set -o allexport # enable all variable definitions to be exported
    source <(sed -e "s/\r//" -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/=\"\1\"/g" "${BASE_DIR}/.env")
    set +o allexport
fi



HL_PATH=${HL_PATH:-~/.homelab}
HL_NAME=${NAME:-${HL_NAME}}
HL_FQDN_DOMAIN=${FQDN_DOMAIN:-${HL_FQDN_DOMAIN}}
HL_SSH_PRIVATE_KEY=${HL_PATH}/.ssh
export HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
export HL_SSH_PUBLIC_KEY_CONTENT=
HL_CLUSTER_API_PORT=${CLUSTER_API_PORT:-${HL_CLUSTER_API_PORT}}
HL_CLUSTER_API_EXTERNAL_IP=${CLUSTER_API_EXTERNAL_IP:-${HL_CLUSTER_API_EXTERNAL_IP}}
HL_CLUSTER_HTTP_PORT=${CLUSTER_HTTP_PORT:-${HL_CLUSTER_HTTP_PORT}}
HL_CLUSTER_HTTPS_PORT=${CLUSTER_HTTPS_PORT:-${HL_CLUSTER_HTTPS_PORT}}
HL_CLUSTER_SERVERS=${CLUSTER_SERVERS:-${HL_CLUSTER_SERVERS}}
HL_CLUSTER_AGENTS=${CLUSTER_AGENTS:-${HL_CLUSTER_AGENTS}}
HL_CLUSTER_PV_SIZE=${CLUSTER_PV_SIZE:-${HL_CLUSTER_PV_SIZE}}

# NGINX_LB_EXTERNAL_IP=${HL_CLUSTER_DOMAIN:-NGINX_LB_EXTERNAL_IP}



function read_path(){
    if [[ -z $HL_NAME ]]; then
        read_value "Homelab path" "${HL_PATH}"
        export HL_PATH=${READ_VALUE}
    fi    
}
function read_name(){
    if [[ -z $HL_NAME ]]; then
        read_value "Cluster Name" "${HL_NAME}"
        export HL_NAME=${READ_VALUE}
    fi    
}
function read_domain(){
    if [[ -z $HL_FQDN_DOMAIN ]]; then
        read_value "Cluster Domain" "${HL_FQDN_DOMAIN}"
        export HL_CLUSTER_DOMAIN=${HL_FQDN_DOMAIN}
    fi
}
function read_cluster_api_port(){
    if [[ $HL_CLUSTER_API_PORT != ?(-)+([0-9]) ]]; then
        # exit_with_message 1 "$HL_CLUSTER_API_PORT is not a port. Port must be a number"
        read_value "Cluster API Port (recommended: 5000-5500)" "${HL_CLUSTER_API_PORT}"
        export HL_CLUSTER_API_PORT=${READ_VALUE}
    fi
}
function read_cluster_external_ip(){
    if [[ -z $HL_CLUSTER_API_EXTERNAL_IP ]]; then
        read_value "Cluster API IP" "${HL_CLUSTER_API_EXTERNAL_IP}"
        export HL_CLUSTER_API_EXTERNAL_IP=${READ_VALUE}
    fi
}
function read_http_port(){
    if [[ -z $HL_CLUSTER_HTTP_PORT ]]; then
        read_value "Cluster HTTP Port" "${HL_CLUSTER_HTTP_PORT}"
        export HL_CLUSTER_HTTP_PORT=${READ_VALUE}
    fi
}
function read_https_port(){
    if [[ -z $HL_CLUSTER_HTTPS_PORT ]]; then
        read_value "Cluster HTTPS Port" "${HL_CLUSTER_HTTPS_PORT}"
        export HL_CLUSTER_HTTPS_PORT=${READ_VALUE}
    fi
}
function read_cluster_masters(){
    if [[ $HL_CLUSTER_SERVERS != ?(-)+([0-9]) ]]; then
        read_value "Cluster Masters (1Gi memory per node is required)" "${HL_CLUSTER_SERVERS}"
        export HL_CLUSTER_SERVERS=${READ_VALUE}
    fi
}
function read_cluster_agents(){
    if [[ $HL_CLUSTER_AGENTS != ?(-)+([0-9]) ]]; then
        read_value "Cluster Workers (1Gi memory per node is required)" "${HL_CLUSTER_AGENTS}"
        export HL_CLUSTER_AGENTS=${READ_VALUE}
    fi
}
function read_cluster_pv_size(){
    if [[ -z $HL_CLUSTER_PV_SIZE ]]; then
        read_value "Cluster PV Size (Gi)" "${HL_CLUSTER_PV_SIZE}"
        export HL_CLUSTER_PV_SIZE=${READ_VALUE}
    fi
}

function read_input() {
    read_path
    read_name
    read_domain
    read_cluster_api_port
    read_cluster_external_ip
    read_http_port
    read_https_port
    read_cluster_masters
    read_cluster_agents
    read_cluster_pv_size
}
read_input
std_info "Using applyed values"
printenv | grep HL_ | sort -r