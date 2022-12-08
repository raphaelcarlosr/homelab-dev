#!/usr/bin/env bash
function tekton_install(){
    # Configure kubectl
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.20.0/release.yaml
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/previous/v0.13.0/tekton-dashboard-release.yaml
}

function tekton_status(){
    kubectl get pods -n tekton-pipelines
    kubectl get svc tekton-dashboard -n tekton-pipelines
}