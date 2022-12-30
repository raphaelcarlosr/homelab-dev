#!/usr/bin/env bash

require_k3d() {
    if [[ "$(which k3d)" == "" ]]; then
        std_log "K3d not found. Installing."
        curl -LO https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$k3dVersion bash
    fi
    std_debug "$GREEN$(k3d --version | tr '\n' ' ')"
}

require_helm() {
    if [[ "$(which helm)" == "" ]]; then
        std_log "helm not found. Installing."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        get_helm.sh
        rm -f get_helm.sh
    fi
    std_debug "helm $GREEN$(helm version)"
}

require_k3sup() {
    if [[ "$(which k3sup)" == "" ]]; then
        std_log "k3sup not found. Installing."
        curl -sLS https://get.k3sup.dev | sh
        sudo install k3sup /usr/local/bin/
    fi
    local _version
    _version=$(k3sup version | tail -2 | tr '\n' ' ')
    std_debug "k3sup $GREEN${_version}"
}

require_jq() {
    if [[ "$(which jq)" == "" ]]; then
        std_log "jq not found. Installing."
        sudo apt install jq -y
    fi
    std_debug "$(jq --version)"
}

require_snapd() {
    if [[ "$(which snap)" == "" ]]; then
        std_log "snap not found. Installing."
        sudo apt install snapd
    fi
    local _version
    _version=$(snap --version | tr '\n' ' ')
    std_debug "$GREEN${_version}"
}

require_k9s() {
    if [[ "$(which k9s)" == "" ]]; then
        std_log "k9s not found. Installing."
        sudo snap install k9s
    fi
    local _version
    _version=$(k9s version | tail -3 | tr '\n' ' ')
    std_debug "k9s $GREEN${_version}"
}

require_docker() {
    if [[ "$(which docker)" == "" ]]; then
        std_log "Docker not found. Installing."
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt install docker.io
    fi
    std_debug "$GREEN$(docker --version)"
}

require_cloudflared() {
    if [[ "$(which cloudflared)" == "" ]]; then
        std_log "Cloudflared not found. Installing."
        sudo mkdir -p --mode=0755 /usr/share/keyrings
        curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
        echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
        sudo apt-get update && sudo apt-get install cloudflared
    fi
    std_log "$GREEN$(docker --version)"
}

require_niet(){
    if [[ "$(which niet)" == "" ]]; then
        std_log "niet not found. Installing."
        apt install python3-pip
        pip install -U niet
    fi
    std_debug "$GREEN$(niet --version)"
}
require_kubectl(){
    if [[ "$(which kubectl)" == "" ]]; then
        std_log "kubectl not found. Installing."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    fi
    std_debug "${GREEN}kubectl:$(kubectl version --client -o=yaml | niet clientVersion.gitVersion)"
}