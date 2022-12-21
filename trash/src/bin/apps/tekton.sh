#!/usr/bin/env bash
function tekton_install(){
    std_header "Deploying Tekton"
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.20.0/release.yaml
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/previous/v0.13.0/tekton-dashboard-release.yaml
    wait_for_pod "tekton-dashboard" "tekton-pipelines"

    kubectl get all -n tekton-pipelines
    std_info "kubectl port-forward service/tekton-dashboard -n tekton-pipelines 9097:9097"
    std_success "Deploy done"
}

function tekton_cli(){
    opt="$3"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Tekton ${action}"
    case $action in
    install) tekton_install "$@" ;;
    *)
        std_info "Usage"
        ;;
    esac
}