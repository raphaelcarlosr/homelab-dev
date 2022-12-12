#!/usr/bin/env bash

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

function cluster_info() {
    kubectl cluster-info
    kubectl config get-contexts
    kubectl get nodes
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

function cluster_cli() {
    opt="$2"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Cluster ${action}"
    case $action in
    k3d)
        k3d_cli "$@"
        cluster_info
        cluster_dump
        ;;
    *)
        std_info "Usage"
        ;;
    esac
}


