#!/usr/bin/env bash
set -o allexport
# shellcheck source=/dev/null
source "$HL_SCRIPT_BIN/vars.sh"
set +o allexport


export HL_INI_LOG=()
export HL_PKG_FILES=

function load(){
    HL_PKG_FILES=()
    _dir=$1
    kind=${2:-resource}
    for file in "$_dir"/*.sh; do
        filename=$(basename -- "$file")
        # extension="${filename##*.}"
        filename="${filename%.*}"
        # shellcheck source=/dev/null
        source "$file"
        HL_PKG_FILES+=("${filename}")
    done
    if [ ! "$kind" = "resource" ]; then
        HL_INI_LOG+=("$GREEN${#HL_PKG_FILES[@]}$BLUE ${kind} ready: $GREEN${HL_PKG_FILES[*]}")
    fi
    export HL_PKG_FILES;
}

load "$HL_SCRIPT_BIN/common"
export HL_PKG_COMMON=("${HL_PKG_FILES[@]}")

HL_HOST_OS=$(uname_os)
HL_HOST_ARCH=$(uname_arch)
HL_HOST_PLATFORM="${HL_HOST_OS}/${HL_HOST_ARCH}"
HL_HOST_AVAILABLE_MEMORY="$(check_memory)"
HL_HOST_DISTRO="$(check_distro)"
HL_CURRENT_EXTERNAL_IP=$(get_external_ip)
HL_SSH_PUBLIC_KEY_CONTENT= #"$(cat "${HL_SSH_PUBLIC_KEY}")"
HL_TITLE="(D8G-2-K8S)$GREEN DEVELOPING$WARN TO$BLUE KUBERNETES$NORMAL"
export HL_HOST_OS \
    HL_HOST_ARCH \
    HL_HOST_PLATFORM \
    HL_HOST_AVAILABLE_MEMORY \
    HL_HOST_DISTRO \
    HL_CURRENT_EXTERNAL_IP \
    HL_SSH_PUBLIC_KEY_CONTENT \
    HL_TITLE

# validate and setup
is_root
setup_directories
# setup_ssh_key
show_banner
std_header "${WARN}(D2k)${NORMAL}D9T-4-K8S"
std_debug "Using flag values"
for i in "${HL_FLAGS[@]}"; do std_debug "${i}"; done

load "$HL_SCRIPT_APPS" "applications"
export HL_PKG_APPS=("${HL_PKG_FILES[@]}")
load "$HL_SCRIPT_TOOLS" "tools"
export HL_PKG_TOOLS=("${HL_PKG_FILES[@]}")
load "${HL_SCRIPT_CLIS}" "cli's"
export HL_PKG_CLIS=("${HL_PKG_FILES[@]}")

cli="d2k_${1}"
$cli "$@"