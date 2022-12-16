#!/usr/bin/env bash

###
# This file can be run locally or from a remote source:
#
# Local: ./setup.sh install
# Remote: curl https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main/setup.sh | CMD=install sudo bash
###

HL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HL_SCRIPT_SRC="${HL_SCRIPT_DIR}/src"
HL_SCRIPT_BIN="${HL_SCRIPT_SRC}/bin"
HL_OWNER=raphaelcarlosr
HL_REPO="homelab-dev"
HL_REPO_PREFIX="${HL_OWNER}/${HL_REPO}"
HL_REPO_URL=https://github.com/${HL_REPO_PREFIX}
HL_REPO_RAW=https://raw.githubusercontent.com/${HL_REPO_PREFIX}/main
HL_DOWNLOAD=${HL_REPO_URL}/releases/download
HL_BINARY=${HL_REPO}
HL_BINARY_FORMAT=tar.gz
HL_CMD_PROCESS=$$
HL_CMD_FILE=$0
HL_CMD_ARGS=$*
HL_CMD_ARGS_LEN=$#

export HL_SCRIPT_DIR \
    HL_SCRIPT_SRC \
    HL_SCRIPT_BIN \
    HL_OWNER \
    HL_REPO \
    HL_REPO_PREFIX \
    HL_REPO_URL \
    HL_REPO_RAW \
    HL_DOWNLOAD \
    HL_BINARY \
    HL_BINARY_FORMAT \
    HL_CMD_PROCESS \
    HL_CMD_FILE \
    HL_CMD_ARGS \
    HL_CMD_ARGS_LEN

# set -o #allexport
# shellcheck source=/dev/null
source "$HL_SCRIPT_SRC/load.sh"

cmd="${cmd:-$1}"

opt="$cmd" #"$1"
choice=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
case $choice in
cluster) cluster_cli "$@" ;;
apps) apps_cli "$@" ;;
cloudflare) cloudflare_cli "$@" ;;
stack)
    k3d_up "$@"
    metallb_install "$@"
    nginx_install "$@"
    traefik_install "$@"
    cloudflare_tunnel "$@"
    ;;
# microk8s) _microk8s "$@" ;;
# k3d) _k3d "$@" ;;
*)
    std_header "${GREEN}Usage: ./homelab.sh <cli>"
    std_info "cluster       -> Manage cluster"
    # std_info "apps          -> Manage management"
    # std_info "cloudflare    -> Cloudflare management"
    # std_info "stack         -> k3d metallb traefik"
    ;;
esac
# printenv | grep HL_ | sort
# # exit

# # REPO_URL="${REPO_RAW_URL:-https://github.com/raphaelcarlosr/homelab-dev}"
# # REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main}"

# # USE_REMOTE_REPO=0
# # if [ -z "${BASH_SOURCE:-}" ]; then
# #     cmd="${CMD:-}"
# #     BASE_DIR="${PWD}"
# #     USE_REMOTE_REPO=1
# # else
# #     cmd="${1:-}"
# #     BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# # fi

# # if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
# #     SCRIPT_DIR="/tmp/homelab-dev"
# #     rm -rf $SCRIPT_DIR
# #     git clone "${REPO_URL}.git" $SCRIPT_DIR
# # fi
# # set -o allexport # enable all variable definitions to be exported
# # SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# # export REPO_URL REPO_RAW_URL USE_REMOTE_REPO BASE_DIR SCRIPT_DIR
# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/src/args.sh"
# # set +o allexport
# # printenv | grep "HL_" | sort
# # exit

# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/src/load.sh"

# # cmd="${cmd:-$1}"
# # std_header "Command: $*"

# # opt="$cmd" #"$1"
# # choice=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
# # case $choice in
# # cluster) cluster_cli "$@" ;;
# # apps) apps_cli "$@" ;;
# # cloudflare) cloudflare_cli "$@" ;;
# # stack)
# #     k3d_up "$@"
# #     metallb_install "$@"
# #     nginx_install "$@"
# #     traefik_install "$@"
# #     cloudflare_tunnel "$@"
# #     ;;
# # # microk8s) _microk8s "$@" ;;
# # # k3d) _k3d "$@" ;;
# # *)
# #     std_header "${GREEN}Usage: ./homelab.sh <command>${NC}"
# #     std_info "cluster       -> Manage cluster"
# #     std_info "apps          -> Manage management"
# #     std_info "cloudflare    -> Cloudflare management"
# #     std_info "stack         -> k3d metallb traefik"
# #     ;;
# # esac
