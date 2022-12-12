#!/usr/bin/env bash

###
# This file can be run locally or from a remote source:
#
# Local: ./setup.sh install
# Remote: curl https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main/setup.sh | CMD=install sudo bash
###

REPO_URL="${REPO_RAW_URL:-https://github.com/raphaelcarlosr/homelab-dev}"
REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main}"

export REPO_URL REPO_RAW_URL

USE_REMOTE_REPO=0
if [ -z "${BASH_SOURCE:-}" ]; then
    cmd="${CMD:-}"
    BASE_DIR="${PWD}"
    USE_REMOTE_REPO=1
else
    cmd="${1:-}"
    BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
    SCRIPT_DIR="/tmp/homelab-dev"
    rm -rf $SCRIPT_DIR
    git clone "${REPO_URL}.git" $SCRIPT_DIR
fi

# shellcheck source=/dev/null
source "$SCRIPT_DIR/src/load.sh"

cmd="${cmd:-$1}"
std_header "Command: $*"

opt="$cmd" #"$1"
choice=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
case $choice in
cluster) cluster_cli "$@" ;;
apps) apps_cli "$@" ;;
cloudflare) cloudflare_cli "$@" ;;
# microk8s) _microk8s "$@" ;;
# k3d) _k3d "$@" ;;
*)
    std_header "${GREEN}Usage: ./homelab.sh <command>${NC}"
    std_info "cluster       -> Manage cluster - cluster management"
    ;;
esac
