#!/usr/bin/env bash

function nginx_install(){
    ingressControllerVersion="master"
    std_header "Deploying Nginx Ingress Controller. ${ingressControllerVersion}"
    kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/${ingressControllerVersion}/deploy/static/provider/cloud/deploy.yaml"
    wait_for_pod "controller" "ingress-nginx"
    nginx_lb_ip
    kubectl get all -n ingress-nginx
    std_success "Deploy done"
}

function nginx_lb_ip(){
    HL_NGINX_LB_EXTERNAL_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    export HL_NGINX_LB_EXTERNAL_IP
    std_log "LoadBalancer IP: $HL_NGINX_LB_EXTERNAL_IP"
}

function nginx_cli(){
    opt="$3"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "NGIX ${action}"
    case $action in
    install) nginx_install "$@" ;;
    *)
        std_info "Usage"
        ;;
    esac
}
