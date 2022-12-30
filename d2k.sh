#!/usr/bin/env bash

###
# This file can be run locally or from a remote source:
#
# Local: ./setup.sh install
# Remote: curl https://raw.githubusercontent.com/raphaelcarlosr/homelab-dev/main/setup.sh | CMD=install sudo bash
###

D2K_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export D2K_SCRIPT_DIR
# D2K_SCRIPT_SRC="${D2K_SCRIPT_DIR}/src"
export D2K_COPY_RIGHT="$UNDERLINE${WARN}https://raphaelcarlosr.dev${NORMAL}"
export D2K_SCRIPT_ASSETS="${D2K_SCRIPT_DIR}/assets"
export D2K_SCRIPT_BIN="${D2K_SCRIPT_DIR}/bin"
export D2K_SCRIPT_CONFIG="${D2K_SCRIPT_DIR}/config"
# export D2K_SCRIPT_TOOLS="${D2K_SCRIPT_BIN}/tools"
# export D2K_SCRIPT_APPS="${D2K_SCRIPT_BIN}/apps"
# export D2K_SCRIPT_CLIS="${D2K_SCRIPT_BIN}/cli"
export D2K_OWNER=raphaelcarlosr
export D2K_REPO="homelab-dev"
export D2K_REPO_PREFIX="${D2K_OWNER}/${D2K_REPO}"
export D2K_REPO_URL=https://github.com/${D2K_REPO_PREFIX}
export D2K_REPO_RAW=https://raw.githubusercontent.com/${D2K_REPO_PREFIX}/main
export D2K_DOWNLOAD=${D2K_REPO_URL}/releases/download
export D2K_BINARY=${D2K_REPO}
export D2K_BINARY_FORMAT=tar.gz
export D2K_CMD_PROCESS=$$
export D2K_CMD_FILE=$0
export D2K_CMD_ARGS=$*
export D2K_CMD_ARGS_LEN=$#
export D2K_COPY_RIGHT
# set -o #allexport
# shellcheck source=/dev/null
source "$D2K_SCRIPT_BIN/injector.sh"
std_success "d2k finished"
std_line
# printenv | grep D2K_ | sort
# exit 0 
# cmd="${cmd:-$1}"

# opt="$cmd" #"$1"
# choice=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
# case $choice in
# cluster) cluster_cli "$@" ;;
# apps) apps_cli "$@" ;;
# cloudflare) cloudflare_cli "$@" ;;
# stack)
#     k3d_up "$@"
#     metallb_install "$@"
#     nginx_install "$@"
#     traefik_install "$@"
#     cloudflare_tunnel "$@"
#     ;;
# # microk8s) _microk8s "$@" ;;
# # k3d) _k3d "$@" ;;
# *)
#     std_header "${GREEN}Usage: ./homelab.sh <cli>"
#     std_info "cluster       -> Manage cluster"
#     # std_info "apps          -> Manage management"
#     # std_info "cloudflare    -> Cloudflare management"
#     # std_info "stack         -> k3d metallb traefik"
#     ;;
# esac
# printenv | grep D2K_ | sort
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
# # printenv | grep "D2K_" | sort
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
