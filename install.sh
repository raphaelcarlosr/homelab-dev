#!/usr/bin/env bash

export KUBECONFIG=/home/$SUDO_USER/.kube/config

# Input data
READ_VALUE=
D2K_CONFIG_CLUSTER_NAME=homelab-cluster
D2K_CONFIG_CLUSTER_DOMAIN=me.localhost
D2K_CONFIG_CLUSTER_API_PORT=5510
if [[ $UNAMECHK == "Darwin" ]]; then
    D2K_CONFIG_CLUSTER_API_EXTERNAL_IP=$(ifconfig | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | head -n1)
else
    D2K_CONFIG_CLUSTER_API_EXTERNAL_IP=$(ip a | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | head -n1)
fi
D2K_CONFIG_CLUSTER_HTTP_PORT=80
D2K_CONFIG_CLUSTER_HTTPS_PORT=443
D2K_CONFIG_CLUSTER_SERVERS=1
D2K_CONFIG_CLUSTER_AGENTS=1
D2K_CONFIG_CLUSTER_PV_SIZE=10

NGINX_LB_EXTERNAL_IP=

function exitWithMsg() {
    # $1 is error code
    # $2 is error message
    echo "Error $1: $2"
    exit $1
}

function exitAfterCleanup() {
    echo "Error $1: $2"
    rollback $1
}

function cleanup() {
    header "Cleaning up"
    rm tmp-k3d-${D2K_CONFIG_CLUSTER_NAME}.yaml
}

function rollback() {
    cleanup
    header "Rolling back, before exiting..."
    # $1 is error code
    if [[ "$(which k3d)" != "" ]]; then
        hasCluster=$(k3d cluster list | grep -w $D2K_CONFIG_CLUSTER_NAME | cut -d " " -f 1)
        if [ "$hasCluster" == "$D2K_CONFIG_CLUSTER_NAME" ]; then
            log "$D2K_CONFIG_CLUSTER_NAME already exists"
            k3d cluster delete $D2K_CONFIG_CLUSTER_NAME
            # read -p "$clusterName already exists, want to delete [Y/n]" deleteCluster
            # if [[ $deleteCluster == "Y" ]]; then
            #     k3d cluster delete $clusterName
            # else
            #     exitWithMsg 100 "Cluster with name $clusterName already exist."
            # fi
        fi
        sleep 2
        # k3d cluster delete $clusterName
    fi
    if [ -d /home/$SUDO_USER/.kube ]; then
        sudo chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube
    fi
    exit $1
}

###
# This file can be run locally or from a remote source:
#
# Local: ./setup.sh install
# Remote: curl https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main/install.sh | CMD=install sudo bash
###

# set -euo pipefail

USE_REMOTE_REPO=0
if [ -z "${BASH_SOURCE:-}" ]; then
    cmd="${CMD:-}"
    DIR="${PWD}"
    USE_REMOTE_REPO=1
else
    cmd="${1:-}"
    DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
fi
REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main}"

# ######
BASE_DIR=DIR # $(cd $(dirname $0) && pwd)

trap 'rollback $?' ERR SIGINT

if [ $EUID -ne 0 ]; then
    exitWithMsg 1 "Run this as root or with sudo privilege."
fi

sp="/-\|"
sc=0
spin() {
    printf "\b${sp:sc++:1}"
    ((sc == ${#sp})) && sc=0
}
endspin() {
    printf "\r%s\n" "$@"
}

# bold text
bold=$(tput bold)
normal=$(tput sgr0)
yes_no="(${bold}Y${normal}es/${bold}N${normal}o)"

# $1 text to show - $2 default value
function read_value() {
    read -p "${1} [${bold}${2}${normal}]: " READ_VALUE
    if [ "${READ_VALUE}" = "" ]; then
        READ_VALUE=$2
    fi
}

function header() {
    printf "\n----- [${bold}${1}${normal}]\n"
}

function log() {
    echo "--- [${bold}${1}${normal}]"
}

function check_distro() {
    log "Checking distro requirements"
    distroId=$(grep -w DISTRIB_ID /etc/*-release | cut -d "=" -f 2)
    distroVersion=$(grep -w DISTRIB_RELEASE /etc/*-release | cut -d "=" -f 2)
    log "Distro: $distroId:$distroVersion"
    if [ "$distroId" != "Ubuntu" ]; then
        exitWithMsg 1 "Unsupported Distro. This script is written for Ubuntu OS only."
    fi
}

function check_memory() {
    log "Checking memory"
    totalMem=$(free --giga | grep -w Mem | tr -s " " | cut -d " " -f 2)
    usedMem=$(free --giga | grep -w Mem | tr -s " " | cut -d " " -f 3)
    availableMem=$(expr $totalMem - $usedMem)
    log "Available Memory: "$availableMem"Gi"
    if [ $availableMem -lt 2 ]; then
        exitWithMsg 1 "Atleast 2Gi of free memory required."
    fi
}

function check_host_requirements() {
    header "Checking host requirements"
    check_distro
    check_memory
}

function config() {
    header "Setup"
    read_value "Cluster Name" "${D2K_CONFIG_CLUSTER_NAME}"
    D2K_CONFIG_CLUSTER_NAME=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_NAME=${D2K_CONFIG_CLUSTER_NAME}

    read_value "Cluster Domain" "${D2K_CONFIG_CLUSTER_DOMAIN}"
    D2K_CONFIG_CLUSTER_DOMAIN=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_DOMAIN=${D2K_CONFIG_CLUSTER_DOMAIN}

    read_value "Cluster API Port (recommended: 5000-5500)" "${D2K_CONFIG_CLUSTER_API_PORT}"
    D2K_CONFIG_CLUSTER_API_PORT=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_API_PORT=${D2K_CONFIG_CLUSTER_API_PORT}

    read_value "Cluster API IP" "${D2K_CONFIG_CLUSTER_API_EXTERNAL_IP}"
    D2K_CONFIG_CLUSTER_API_EXTERNAL_IP=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_API_EXTERNAL_IP=${D2K_CONFIG_CLUSTER_API_EXTERNAL_IP}

    read_value "Cluster HTTP Port" "${D2K_CONFIG_CLUSTER_HTTP_PORT}"
    D2K_CONFIG_CLUSTER_HTTP_PORT=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_HTTP_PORT=${D2K_CONFIG_CLUSTER_HTTP_PORT}

    read_value "Cluster HTTPS Port" "${D2K_CONFIG_CLUSTER_HTTPS_PORT}"
    D2K_CONFIG_CLUSTER_HTTPS_PORT=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_HTTPS_PORT=${D2K_CONFIG_CLUSTER_HTTPS_PORT}

    read_value "Cluster Masters (1Gi memory per node is required)" "${D2K_CONFIG_CLUSTER_SERVERS}"
    D2K_CONFIG_CLUSTER_SERVERS=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_SERVERS=${D2K_CONFIG_CLUSTER_SERVERS}

    read_value "Cluster Workers (1Gi memory per node is required)" "${D2K_CONFIG_CLUSTER_AGENTS}"
    D2K_CONFIG_CLUSTER_AGENTS=${READ_VALUE}
    export D2K_CONFIG_CLUSTER_AGENTS=${D2K_CONFIG_CLUSTER_AGENTS}

    read_value "Cluster PV Size (Gi)" "${D2K_CONFIG_CLUSTER_PV_SIZE}"
    D2K_CONFIG_CLUSTER_PV_SIZE=${READ_VALUE}
}

function get_local_or_remote_file() {
    if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
        echo "${REPO_RAW_URL}"
    else
        echo "${DIR}"
    fi
}

function validate_config() {
    if [[ $D2K_CONFIG_CLUSTER_API_PORT != ?(-)+([0-9]) ]]; then
        exitWithMsg 1 "$D2K_CONFIG_CLUSTER_API_PORT is not a port. Port must be a number"
    fi
    if [[ $D2K_CONFIG_CLUSTER_AGENTS != ?(-)+([0-9]) ]]; then
        exitWithMsg 1 "$D2K_CONFIG_CLUSTER_AGENTS is not a number. Number of worker node must be a number"
    fi
}

function check_and_install_dependencies() {
    header "Installing dependencies"
    if [[ "$(which docker)" == "" ]]; then
        log "Docker not found. Installing."
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt install docker.io
    fi
    log "$(docker --version)"

    if [[ "$(which k3d)" == "" ]]; then
        log "K3d not found. Installing."
        curl -LO https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$k3dVersion bash
    fi
    log "$(k3d --version)"

    if [[ "$(which helm)" == "" ]]; then
        log "helm not found. Installing."
        curl -fsSL -o $PWD/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 $PWD/get_helm.sh
        $PWD/get_helm.sh
        rm -f $PWD/get_helm.sh
    fi
    log "$(helm version)"

    if [[ "$(which k3sup)" == "" ]]; then
        log "k3sup not found. Installing."
        curl -sLS https://get.k3sup.dev | sh
        sudo install k3sup /usr/local/bin/
    fi
    log "$(k3sup version)"

    if [[ "$(which kubectl)" == "" ]]; then
        echo "kubectl not found. Installing."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
    fi
    log "$(kubectl version --output=json)"

    if [[ "$(which jq)" == "" ]]; then
        log "jq not found. Installing."
        sudo apt install jq -y
    fi
    log "$(jq --version)"

    if [[ "$(which htpasswd)" == "" ]]; then
        log "htpasswd not found. Installing."
        sudo apt install apache2-utils
    fi

    if [[ "$(which snap)" == "" ]]; then
        log "snap not found. Installing."
        sudo apt install snapd
    fi

    if [[ "$(which multipass)" == "" ]]; then
        log "multipass not found. Installing."
        sudo snap install multipass
    fi
    log "$(multipass --version)"
}

function cluster_k3d_create() {
    header "Deleting Previous Cluster"
    k3d cluster delete ${D2K_CONFIG_CLUSTER_NAME}

    header "Creating K3D cluster"
    # https://k3d.io/v5.4.1/usage/configfile/
    # curl "$(get_local_or_remote_file)/resources/k3d.yaml" | envsubst - --output "tmp-k3d-${D2K_CONFIG_CLUSTER_NAME}.yaml"
    cat resources/k3d.yaml | envsubst >tmp-k3d-${D2K_CONFIG_CLUSTER_NAME}.yaml
    k3d cluster create --config tmp-k3d-${D2K_CONFIG_CLUSTER_NAME}.yaml
    export KUBECONFIG=$(k3d kubeconfig write ${D2K_CONFIG_CLUSTER_NAME})
    kubectl cluster-info
    kubectl get nodes
    if [ $? -ne 0 ]; then
        exitAfterCleanup 1 "Failed to spinup cluster."
    fi
    log "Waiting for cluster up"
    until [[ $(kubectl get pods -A -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep coredns | awk -F " " '{print $1}') = 'True' ]]; do
        spin
    done
    endspin
    kubectl get pods -A
}

function cluster_create() {
    header "Creating cluster"
    cluster_k3d_create
}

# function helm_add_repos() {
#     header "Updating helm repositories"
#     helm repo add traefik https://helm.traefik.io/traefik
#     helm repo update
# }

function app_metallb_install() {
    metallbVersion="v0.13.7"
    header "Deploying MetalLB loadbalancer. ${metallbVersion}"
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/$metallbVersion/config/manifests/metallb-native.yaml
    log "Waiting for MetalLB to be ready"
    # kubectl wait --timeout=150s --for=condition=ready pod -l app=metallb,component=controller -n metallb-system
    until [[ $(kubectl get pods -n metallb-system -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep controller | awk -F " " '{print $1}') = 'True' ]]; do
        spin
    done
    endspin

    log "Checking network range"
    cidr_block=$(docker network inspect ${D2K_CONFIG_CLUSTER_NAME}-net | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
    base_addr=${cidr_block%???}
    first_addr=$(echo $base_addr | awk -F'.' '{print $1,$2,$3,240}' OFS='.')
    NETWORK_IP_RANGE=$first_addr/29
    log "Creating config for network range ($NETWORK_IP_RANGE) config map"
    export NETWORK_IP_RANGE=$NETWORK_IP_RANGE

    # cat apps/metallb.yaml | envsubst '${NETWORK_IP_RANGE}' | kubectl apply -f -
    if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
        curl "$(get_local_or_remote_file)/apps/metallb.yaml" --output "/tmp/metallb.yaml"
        # envsubst < "/tmp/metallb.yaml" | kubectl apply -f -
        cat /tmp/metallb.yaml | envsubst | kubectl apply -f -
    else
        # envsubst < "${DIR}/apps/metallb.yaml" | kubectl apply -f -
        cat ${DIR}/apps/metallb.yaml | envsubst | kubectl apply -f -
    fi
    # readFileAndApply /apps/metallb.yaml metallb.yaml
    log "Resources"
    kubectl get all -n metallb-system
    # kubectl get configmaps -n metallb-system config -o yaml
}

function app_ngix_install() {
    ingressControllerVersion="master"
    header "Deploying Nginx Ingress Controller. ${ingressControllerVersion}"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$ingressControllerVersion/deploy/static/provider/cloud/deploy.yaml
    log "Waiting for Nginx Ingress controller to be ready"
    # kubectl wait --timeout=180s  --for=condition=ready pod -l app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx -n ingress-nginx
    until [[ $(kubectl get pods -n ingress-nginx -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep controller | awk -F " " '{print $1}') = 'True' ]]; do
        spin
    done
    endspin

    log "Getting Loadbalancer IP"
    NGINX_LB_EXTERNAL_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    log "LoadBalancer IP: $NGINX_LB_EXTERNAL_IP"
    log "Resources"
    kubectl get all -n ingress-nginx
}

function app_traefik_install() {
    header "Installing Traefik"
    helm upgrade \
        -f apps/traefik.values.yaml \
        --atomic \
        --cleanup-on-fail \
        --create-namespace \
        --install \
        --namespace=traefik \
        --repo=https://helm.traefik.io/traefik \
        --reset-values \
        --wait \
        traefik traefik

    # helm install traefik traefik/traefik \
    #     -f apps/traefik.values.yaml \
    #     --namespace traefik \
    #     --create-namespace

    helm ls
    log "Waiting for Traefik Ingress controller to be ready"
    until [[ $(kubectl get pods -n traefik -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep traefik | awk -F " " '{print $1}') = 'True' ]]; do
        spin
    done
    endspin "Done"

    kubectl apply -f apps/traefik.yaml -n traefik

    # helm upgrade traefik traefik/traefik -f apps/traefik.values.yaml
    # kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
    # kubectl get pods
    # kubectl get svc/traefik
    # kubectl get all -l"app.kubernetes.io/instance=traefik"
}

function apps_install() {
    header "Installing apps"
    app_metallb_install
    # app_ngix_install
    app_traefik_install
}

function dns_setup_managed() {
    log "Configuring ${MANAGED_DNS_PROVIDER} managed DNS provider"
    case "${MANAGED_DNS_PROVIDER:-}" in
    cloudflare)
        log "Installing Cloudflare managed DNS"
        kubectl create secret generic cloudflare-api-token \
            -n cert-manager \
            --from-literal=api-token="${CLOUDFLARE_API_TOKEN}" \
            --dry-run=client -o yaml |
            kubectl replace --force -f -

        if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
            curl "$(get_local_or_remote_file)/assets/cloudflare.yaml" --output "/tmp/cloudflare.yaml"
            envsubst <"/tmp/cloudflare.yaml" | kubectl apply -f -
        else
            envsubst <"${DIR}/assets/cloudflare.yaml" | kubectl apply -f -
        fi
        ;;
    gcp)
        log "Installing GCP managed DNS"
        kubectl create secret generic clouddns-dns01-solver \
            -n cert-manager \
            --from-file=key.json="${GCP_SERVICE_ACCOUNT_KEY}" \
            --dry-run=client -o yaml |
            kubectl replace --force -f -

        if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
            curl "$(get_local_or_remote_file)/assets/gcp.yaml" --output "/tmp/gcp.yaml"
            envsubst <"/tmp/gcp.yaml" | kubectl apply -f -
        else
            envsubst <"${DIR}/assets/gcp.yaml" | kubectl apply -f -
        fi
        ;;
    route53)
        log "Installing Route 53 managed DNS"
        kubectl create secret generic route53-api-secret \
            -n cert-manager \
            --from-literal=secret-access-key="${ROUTE53_SECRET_KEY}" \
            --dry-run=client -o yaml |
            kubectl replace --force -f -

        if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
            curl "$(get_local_or_remote_file)/assets/route53.yaml" --output "/tmp/route53.yaml"
            envsubst <"/tmp/route53.yaml" | kubectl apply -f -
        else
            envsubst <"${DIR}/assets/route53.yaml" | kubectl apply -f -
        fi
        ;;
    selfsigned)
        log "A self-signed certificate will be created"
        ;;
    *)
        log "Not installing managed DNS"
        ;;
    esac
}

function dns_cloudflare_tunnel() {
    # docker run -v ${PWD}/config:/home/cloudflared/.cloudflared crazymax/cloudflared tunnel login
    log "Configuring Cloudflared"
    # if [ ! -f ~/.cloudflared/cert.pem ]
    # then
    #     cloudflared tunnel login
    # fi
    # CF_TUNNEL_NAME=$SVC_NAMESPACE-gateway
    # CF_TUNNEL_ID=$(cloudflared tunnel list | grep $CF_TUNNEL_NAME | awk '{ print $1 }')
    # if [[ $CF_TUNNEL_ID == "" ]]
    # then
    #     cloudflared tunnel create $CF_TUNNEL_NAME
    #     CF_TUNNEL_ID=$(cloudflared tunnel list | grep $CF_TUNNEL_NAME | awk '{ print $1 }')
    # fi

    # header "Creating DNS for tunnel $CF_TUNNEL_ID/$CF_TUNNEL_NAME"
    # cloudflared tunnel route dns $CF_TUNNEL_NAME labs.$CF_HOST_NAME
}

function dns_setup() {
    header "Setuping DNS"
    set_cloudflare_tunnel
}

check_host_requirements
config
validate_config
check_and_install_dependencies
cluster_create
# helm_add_repos
# dns_setup
apps_install
cleanup

# kubectl apply -f apps/whoami.yaml
# kubectl scale deployment whoami --replicas=5
# kubectl scale deployment whoami --replicas=2
# kubectl get deployments
# kubectl get rs
# htpasswd -nBb admin password > auth
# kubectl create secret generic admin-secret --from-file=auth

function clusterInfo() {
    echo
    echo
    echo "---------------------------------------------------------------------------"
    echo "---------------------------------------------------------------------------"
    echo "Cluster name: ${D2K_CONFIG_CLUSTER_NAME}"
    echo "K8s server: https://0.0.0.0:${D2K_CONFIG_CLUSTER_API_PORT}"
    echo "Ingress Load Balancer: $NGINX_LB_EXTERNAL_IP"
    echo "Open sample app in browser: http://$NGINX_LB_EXTERNAL_IP/sampleapp"
    echo "To switch to this cluster use export KUBECONFIG=\$(k3d kubeconfig write ${D2K_CONFIG_CLUSTER_NAME})"
    echo "Then kubectl cluster-info"
    echo "To stop this cluster (If running), run: k3d cluster stop $D2K_CONFIG_CLUSTER_NAME"
    echo "To start this cluster (If stopped), run: k3d cluster start $D2K_CONFIG_CLUSTER_NAME"
    echo "To delete this cluster, run: k3d cluster delete $D2K_CONFIG_CLUSTER_NAME"
    echo "To list all clusters, run: k3d cluster list"
    echo "To switch to another cluster (In case of multiple clusters), run: kubectl config use-context k3d-<CLUSTERNAME>"
    echo "---------------------------------------------------------------------------"
    echo "- Traefik kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000"
    echo "---------------------------------------------------------------------------"
    echo
}

k3dclusterinfo="/home/$SUDO_USER/k3dclusters.info"
if [ -d /home/$SUDO_USER/.kube ]; then
    sudo chown -R root:root /home/$SUDO_USER/.kube
fi
clusterInfo | tee -a "$k3dclusterinfo"
chown $SUDO_USER:$SUDO_USER "$k3dclusterinfo"
chmod 400 "$k3dclusterinfo"
header "Find cluster info in "$k3dclusterinfo" file."
header "Thank's, more info see https://raphaelcarlosr.dev"
header "|-- have funny! --|"

############################################################## exit

# k3dVersion="v5.4.6"
# metallbVersion="v0.13.7"
# ingressControllerVersion="v1.5.1"

# k3dclusterinfo="/home/$SUDO_USER/k3dclusters.info"
# if [ -d /home/$SUDO_USER/.kube ]; then
#     sudo chown -R root:root /home/$SUDO_USER/.kube
# fi

# echo
# read -p "Enter cluster name: " clusterName
# read -p "Enter number of worker nodes (0 to 3) (1Gi memory per node is required): " nodeCount
# read -p "Enter kubernetes api port (recommended: 5000-5500): " apiPort
# echo

# if [[ $apiPort != ?(-)+([0-9]) ]]; then
#     exitWithMsg 1 "$apiPort is not a port. Port must be a number"
# fi

# if [[ $nodeCount != ?(-)+([0-9]) ]]; then
#     exitWithMsg 1 "$nodeCount is not a number. Number of worker node must be a number"
# fi

# # echo
# # echo "Updating apt packages."
# # sudo apt update
# # echo

# echo "Checking docker..."
# if [[ "$(which docker)" == "" ]]; then
#     echo "Docker not found. Installing."
#     sudo apt-get remove docker docker-engine docker.io containerd runc
#     sudo apt install docker.io
# fi
# echo "$(docker --version)"

# echo "Checking K3d..."
# if [[ "$(which k3d)" == "" ]]; then
#     echo "K3d not found. Installing."
#     curl -LO https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$k3dVersion bash
# fi
# echo "$(k3d --version)"

# echo "Checking HELM..."
# if [[ "$(which helm)" == "" ]]; then
#     echo "helm not found. Installing."
#     curl -fsSL -o $PWD/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
#     chmod 700 $PWD/get_helm.sh
#     $PWD/get_helm.sh
#     rm -f $PWD/get_helm.sh
# fi
# echo "$(helm version)"

# echo "Checking k3sup..."
# if [[ "$(which k3sup)" == "" ]]; then
#     echo "k3sup not found. Installing."
#     curl -sLS https://get.k3sup.dev | sh
#     sudo install k3sup /usr/local/bin/
# fi
# echo "$(k3sup version)"

# echo "Installing json parser."
# if [[ "$(which jq)" == "" ]]; then
#     echo "jq not found. Installing."
#     sudo apt install jq -y
# fi
# echo "$(jq --version)"

# echo
# echo "Checking if cluster already exists."
# hasCluster=$(k3d cluster list | grep -w $clusterName | cut -d " " -f 1)
# if [ "$hasCluster" == "$clusterName" ]; then
#     k3d cluster delete $clusterName
#     # read -p "$clusterName already exists, want to delete [Y/n]" deleteCluster
#     # if [[ $deleteCluster == "Y" ]]; then
#     #     k3d cluster delete $clusterName
#     # else
#     #     exitWithMsg 100 "Cluster with name $clusterName already exist."
#     # fi
# fi

# #Host IP Check
# if [[ $EXTERNAL_IP == "" ]]; then
# 	if [[ $UNAMECHK == "Darwin" ]]; then
# 		EXTERNAL_IP=$(ifconfig | grep "inet " | grep -v  "127.0.0.1" | awk -F " " '{print $2}'|head -n1)
# 	else
# 		EXTERNAL_IP=$(ip a | grep "inet " | grep -v  "127.0.0.1" | awk -F " " '{print $2}'|awk -F "/" '{print $1}'|head -n1)
# 	fi
# fi
# echo "Host external IP $EXTERNAL_IP"

# echo
# echo "Creating cluster"
# echo
# k3d cluster create $clusterName \
# --api-port $apiPort \
# --agents $nodeCount \
# --k3s-arg "--disable=traefik@server:0" --k3s-arg "--disable=servicelb@server:0" \
# --no-lb \
# --wait \
# --timeout 15m
# echo "Cluster $clusterName created."

# echo "Checking kubectl..."
# if [[ "$(which kubectl)" == "" ]]; then
#     echo "kubectl not found. Installing."
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#     chmod +x kubectl
#     sudo mv ./kubectl /usr/local/bin/kubectl
# fi
# echo "Kubectl installed."
# echo "$(kubectl version --output=json)"
# export KUBECONFIG=$(k3d kubeconfig write $clusterName)

# kubectl cluster-info
# if [ $? -ne 0 ]; then
#     exitAfterCleanup 1 "Failed to spinup cluster."
# fi

# # until [[ $(kubectl get pods -A -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep coredns | awk -F " " '{print $1}' ) = 'True' ]]; do
# #   spin
# # done
# # endspin

# echo
# echo "Deploying MetalLB loadbalancer."
# echo
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/$metallbVersion/config/manifests/metallb-native.yaml
# sleep 2
# echo "Waiting for MetalLB to be ready. It may take 10 seconds or more."
# # kubectl wait --timeout=150s --for=condition=ready pod -l app=metallb,component=controller -n metallb-system
# # sleep 5

# echo
# echo "Checking network range"
# cidr_block=$(docker network inspect k3d-$clusterName | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
# base_addr=${cidr_block%???}
# first_addr=$(echo $base_addr | awk -F'.' '{print $1,$2,$3,240}' OFS='.')
# range=$first_addr/29

# echo "Creating config for network range $range"
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   namespace: metallb-system
#   name: config
# data:
#   config: |
#     address-pools:
#     - name: default
#       protocol: layer2
#       addresses:
#       - $range
# EOF

# echo
# echo "Deploying Nginx Ingress Controller."
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$ingressControllerVersion/deploy/static/provider/aws/deploy.yaml
# echo "Waiting for Nginx Ingress controller to be ready. It may take 10 seconds or more."
# # kubectl wait --timeout=180s  --for=condition=ready pod -l app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx -n ingress-nginx
# # sleep 5

# echo "Getting Loadbalancer IP"
# externalIP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# echo "LoadBalancer IP: $externalIP"

# function clusterInfo()
# {
#     echo
#     echo
#     echo "---------------------------------------------------------------------------"
#     echo "---------------------------------------------------------------------------"
#     echo "Cluster name: $clusterName"
#     echo "K8s server: https://0.0.0.0:$apiPort"
#     echo "Ingress Load Balancer: $externalIP"
#     echo "Open sample app in browser: http://$externalIP/sampleapp"
#     echo "To stop this cluster (If running), run: k3d cluster stop $clusterName"
#     echo "To start this cluster (If stopped), run: k3d cluster start $clusterName"
#     echo "To delete this cluster, run: k3d cluster delete $clusterName"
#     echo "To list all clusters, run: k3d cluster list"
#     echo "To switch to another cluster (In case of multiple clusters), run: kubectl config use-context k3d-<CLUSTERNAME>"
#     echo "---------------------------------------------------------------------------"
#     echo "---------------------------------------------------------------------------"
#     echo
# }
# clusterInfo | tee -a "$k3dclusterinfo"
# chown $SUDO_USER:$SUDO_USER "$k3dclusterinfo"
# chmod 400 "$k3dclusterinfo"
# echo "Find cluster info in "$k3dclusterinfo" file."
# echo "|-- THANK YOU --|"
# echo
