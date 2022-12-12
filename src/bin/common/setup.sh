#!/usr/bin/env bash
std_header "Setup local environment on $GREEN${HL_PATH}"

function create_directories() {
    mkdir -p -v "${HL_PATH}"
}

function check_ssh_key() {
    if [ ! -f "${HL_SSH_PUBLIC_KEY}" ]; then
        # key does not exist, create key
        std_info "Specified key does not exist, creating $GREEN ssh key ${HL_PATH}/.ssh"
        ssh-keygen -b 2048 -f "${HL_PATH}"/.ssh -t rsa -C "homelab" -q -N ""
        export HL_SSH_PRIVATE_KEY=${HL_PATH}/ssh_key
        export HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
    fi
    HL_SSH_PUBLIC_KEY_CONTENT="$(cat "${HL_SSH_PUBLIC_KEY}")"
    export HL_SSH_PRIVATE_KEY HL_SSH_PUBLIC_KEY HL_SSH_PUBLIC_KEY_CONTENT
}

function require_docker() {
    if [[ "$(which docker)" == "" ]]; then
        std_log "Docker not found. Installing."
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt install docker.io
    fi
    std_log "$GREEN$(docker --version)"
}

function require_k3d() {
    if [[ "$(which k3d)" == "" ]]; then
        std_log "K3d not found. Installing."
        curl -LO https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$k3dVersion bash
    fi
    std_log "$GREEN$(k3d --version | tr '\n' ' ')"
}

function require_helm() {
    if [[ "$(which helm)" == "" ]]; then
        std_log "helm not found. Installing."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        get_helm.sh
        rm -f get_helm.sh
    fi
    std_log "helm $GREEN$(helm version)"
}

function require_k3sup() {
    if [[ "$(which k3sup)" == "" ]]; then
        std_log "k3sup not found. Installing."
        curl -sLS https://get.k3sup.dev | sh
        sudo install k3sup /usr/local/bin/
    fi
    local _version
    _version=$(k3sup version | tail -2 | tr '\n' ' ')
    std_log "k3sup $GREEN${_version}"
}

function require_jq() {
    if [[ "$(which jq)" == "" ]]; then
        std_log "jq not found. Installing."
        sudo apt install jq -y
    fi
    std_log "$(jq --version)"
}

function require_snapd() {
    if [[ "$(which snap)" == "" ]]; then
        std_log "snap not found. Installing."
        sudo apt install snapd
    fi
    local _version
    _version=$(snap --version | tr '\n' ' ')
    std_log "$GREEN${_version}"
}

function require_k9s() {
    if [[ "$(which k9s)" == "" ]]; then
        std_log "k9s not found. Installing."
        sudo snap install k9s
    fi
    local _version
    _version=$(k9s version | tail -3 | tr '\n' ' ')
    std_log "k9s $GREEN${_version}"
}

create_directories
# check_ssh_key
require_docker
require_k3d
require_helm
require_jq
require_snapd
require_k3sup
require_k9s
