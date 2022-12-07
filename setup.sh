#!/usr/bin/env bash

CPU=${CPU:-"2"}
MEMORY=${MEMORY:-"2G"}
DISK=${DISK:-"4G"}
VM_NAME=${VM_NAME:-"microk8s"}
export CPU MEMORY DISK VM_NAME

USE_REMOTE_REPO=0
if [ -z "${BASH_SOURCE:-}" ]; then
    cmd="${CMD:-}"
    BASE_DIR="${PWD}"
    USE_REMOTE_REPO=1
else
    cmd="${1:-}"
    BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
fi
REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null

function get_local_or_remote_file() {
    if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
        echo "${REPO_RAW_URL}"
    else
        echo "${BASE_DIR}"
    fi
}

function get_file() {
    if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
        curl "$REPO_RAW_URL/${1}" # --output "${1}"
    else
        cat "${BASE_DIR}/${1}"
    fi    
}


export REPO_RAW_URL
# banner_content=$(get_file "/assets/banner.txt" | envsubst)   
# echo "$banner_content"
get_file "/assets/banner.txt" | envsubst

source "$SCRIPT_DIR/src/load.sh"

exit;
cmd="${cmd:-$1}"

opt="$cmd" #"$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    multipass) _multipass "$@" ;;
     microk8s)  _microk8s "$@" ;;
          k3d)       _k3d "$@" ;;
    *)
      echo "${RED}Usage: ./setup <command>${NC}"
cat <<-EOF
Commands:
---------
  multipass    -> Manage multipass - virtualization orchestrator
  microk8s     -> Manage microk8s  - k8s orchestrator
      k3d      -> Manage microk8s  - k3s (minimal Kubernetes distribution) in docker
EOF
    ;;
esac