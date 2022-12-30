#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120

function metallb(){
    local action
    action="${1}"

    # values(){
    #     helm template traefik/traefik
    # }
    deploy(){
        metallbVersion="v0.13.7"   
        std_log "Deploying$GREEN MetalLB. ${metallbVersion}"
        d2k_cluster cluster "network_range" "k3d"
        stdbuf -oL kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${metallbVersion}/config/manifests/metallb-native.yaml" | std_buf
        cluster_wait_for_pod "controller" "metallb-system"
        std_info "MetalLB Network Range: $GREEN${D2K_NETWORK_IP_RANGE}${NORMAL}"
        addres_pool_manifest | kubectl apply -f- | std_buf
        stdbuf -oL kubectl get all -n metallb-system | std_buf
        std_success "Deploy done"
    }

    addres_pool_manifest(){
        cat <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: cheap
  namespace: metallb-system
spec:
  addresses:
    - ${D2K_NETWORK_IP_RANGE}
EOF
    }  
    $action "$@"   
}