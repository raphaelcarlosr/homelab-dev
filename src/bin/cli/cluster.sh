#!/usr/bin/env bash

function cluster_cli() {
    opt="$2"
    provider="$3"
    actions=('create delete start stop info kubectl')
    providers=('k3d')
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "${action^} cluster (${HL_CLUSTER_NAME}) using ${provider}"

    if [[ ! ${actions[*]} =~ (^|[[:space:]])"${action}"($|[[:space:]]) ]]; then
        std_error "'${action}' is not valid action"
        return
    fi
    if [[ ! ${providers[*]} =~ (^|[[:space:]])"${provider}"($|[[:space:]]) ]]; then
        std_error "'${provider}' is not valid provider"
        return
    fi

    fn="${provider}_${action}"
    $fn "$@"

    case $action in
    create)
        std_array "$(kubectl cluster-info | tr '\n' '|')" "|"
        metallb_install
        cert_manager_deploy
        cluster_dns_managed_setup
        cluster_info
        ;;
    delete)
        std_header "Deleting cluster"
        ;;
    start)
        std_header "Starting cluster"
        ;;
    stop)
        std_header "Stoping cluster"
        ;;
    info)
        std_header "Getting cluster info"
        ;;
    kubectl)
        std_header "Exporting cluster kubectl"
        ;;
    *)
        valid=0
        std_header "${GREEN}Usage: ./homelab.sh <command>${NC}"
        std_info "create        -> Create cluster"
        std_info "delete        -> Delete cluster"
        std_info "start         -> Start cluster"
        std_info "stop          -> Stop cluster"
        std_info "info          -> Show cluster info"
        std_info "kubectl       -> Get cluster kubectl"
        ;;
    esac

    # if [ "$valid" -eq "1" ]; then
    #     $fn "$@"
    # fi
}

function wait_for_pod() {
    # local _pod, _namespace
    _pod=$1
    _namespace=${2:-default}
    std_log "Waiting for pod ($GREEN${_namespace}:${_pod}$BLUE) up"
    until [[ $(kubectl get pods -n "${_namespace}" -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep "${_pod}" | awk -F " " '{print $1}') = 'True' ]]; do
        spin
    done
    endspin
}

function cluster_dump() {
    echo
    echo
    echo "---------------------------------------------------------------------------"
    echo "---------------------------------------------------------------------------"
    echo "Cluster name: ${HL_CLUSTER_NAME}"
    echo "K8s server: https://0.0.0.0:${HL_CLUSTER_API_PORT}"
    echo "Ingress Load Balancer: $NGINX_LB_EXTERNAL_IP"
    echo "Open sample app in browser: http://$NGINX_LB_EXTERNAL_IP/sampleapp"
    echo "To switch to this cluster use export KUBECONFIG=\$(k3d kubeconfig write ${HL_CLUSTER_NAME})"
    echo "Then kubectl cluster-info"
    echo "To stop this cluster (If running), run: k3d cluster stop $HL_CLUSTER_NAME"
    echo "To start this cluster (If stopped), run: k3d cluster start $HL_CLUSTER_NAME"
    echo "To delete this cluster, run: k3d cluster delete $HL_CLUSTER_NAME"
    echo "To list all clusters, run: k3d cluster list"
    echo "To switch to another cluster (In case of multiple clusters), run: kubectl config use-context k3d-<CLUSTERNAME>"
    echo "---------------------------------------------------------------------------"
    echo "- Traefik kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000"
    echo "---------------------------------------------------------------------------"
    echo
}

function cluster_dns_managed_setup() {
    provider=${HL_CLUSTER_MANAGED_DNS_PROVIDER}
    std_log "Configuring ${provider} managed DNS provider"
    temp_file=$(mktemp).yaml
    case "${provider}" in
    cloudflare)
        std_log "Installing Cloudflare managed DNS"
        S=$(kubectl create secret generic cloudflare-api-token \
            -n cert-manager \
            --from-literal=api-token="${HL_CF_TOKEN}" \
            --dry-run=client -o yaml | kubectl replace --force -f -)
        std_log "${S}"
        envsubst < "${HL_SCRIPT_SRC}/assets/manifests/issuer.cloudflare.yaml" > "${temp_file}"
        S=$(kubectl apply -f "${temp_file}")
        std_log "${S}"
        ;;
    gcp)
        std_log "Installing GCP managed DNS"
        kubectl create secret generic clouddns-dns01-solver \
            -n cert-manager \
            --from-file=key.json="${HL_GCP_SERVICE_ACCOUNT}" \
            --dry-run=client -o yaml |
            kubectl replace --force -f -

        envsubst < "${HL_SCRIPT_SRC}/assets/manifests/issuer.gcp.yaml" > "${temp_file}"
        kubectl apply -f "${temp_file}"
        ;;
    route53)
        std_log "Installing Route 53 managed DNS"
        kubectl create secret generic route53-api-secret \
            -n cert-manager \
            --from-literal=secret-access-key="${ROUTE53_SECRET_KEY}" \
            --dry-run=client -o yaml |
            kubectl replace --force -f -

        envsubst < "${HL_SCRIPT_SRC}/assets/manifests/issuer.route53.yaml" > "${temp_file}"
        kubectl apply -f "${temp_file}" 
        ;;
    selfsigned)
        std_log "A self-signed certificate will be created"
        ;;
    *)
        std_log "Not installing managed DNS"
        ;;
    esac
    rm -f "${temp_file}"
}

function cluster_info() {
    # std_array "$(kubectl cluster-info | tr '\n' '|')" "|"
    std_log "---------------------------------------------------------------------------"
    std_log "---------------------------------------------------------------------------"
    std_log "Cluster name: ${HL_CLUSTER_NAME}"
    std_log "K8s server: https://0.0.0.0:${HL_CLUSTER_API_PORT}"
    std_log "Ingress Load Balancer: $NGINX_LB_EXTERNAL_IP"
    std_log "Open sample app in browser: http://$NGINX_LB_EXTERNAL_IP/sampleapp"
    std_log "To switch to this cluster use export KUBECONFIG=\$(k3d kubeconfig write ${HL_CLUSTER_NAME})"
    std_log "Then kubectl cluster-info"
    std_log "To stop this cluster (If running), run: k3d cluster stop $HL_CLUSTER_NAME"
    std_log "To start this cluster (If stopped), run: k3d cluster start $HL_CLUSTER_NAME"
    std_log "To delete this cluster, run: k3d cluster delete $HL_CLUSTER_NAME"
    std_log "To list all clusters, run: k3d cluster list"
    std_log "To switch to another cluster (In case of multiple clusters), run: kubectl config use-context k3d-<CLUSTERNAME>"
    std_log "---------------------------------------------------------------------------"
    std_log "- Traefik kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000"
    std_log "---------------------------------------------------------------------------"

    kubectl config get-contexts
    kubectl get nodes
    kubectl get all -A
}
