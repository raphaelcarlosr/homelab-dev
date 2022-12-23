#!/usr/bin/env bash
set -o allexport
# shellcheck source=/dev/null
source "$HL_SCRIPT_BIN/vars.sh"
set +o allexport

export HL_INI_LOG=()
export HL_PKG_FILES=

function load() {
    local dirname pattern kind
    HL_PKG_FILES=()
    dirname="${1}"
    pattern=${2-"sh"}
    kind=${2:-resource}
    for file in "${HL_SCRIPT_BIN}/$dirname"/*."${pattern}"; do
        filename=$(basename -- "$file")
        # extension="${filename##*.}"
        filename="${filename%.*}"
        if [ ! "$filename" = "cli" ]; then
            # shellcheck source=/dev/null
            source "$file"
            echo "$filename"
            HL_PKG_FILES+=("${filename}")
        fi
        
    done
    if [ ! "$kind" = "resource" ]; then
        HL_INI_LOG+=("$GREEN${#HL_PKG_FILES[@]}$BLUE ${kind} ready: $GREEN${HL_PKG_FILES[*]}")
    fi
    export HL_PKG_FILES
}

load "common"
export HL_PKG_COMMON=("${HL_PKG_FILES[@]}")

HL_HOST_OS=$(uname_os)
HL_HOST_ARCH=$(uname_arch)
HL_HOST_PLATFORM="${HL_HOST_OS}/${HL_HOST_ARCH}"
HL_HOST_AVAILABLE_MEMORY="$(check_memory)"
HL_HOST_DISTRO="$(check_distro)"
HL_CURRENT_EXTERNAL_IP=$(external_ip)
HL_SSH_PUBLIC_KEY_CONTENT= #"$(cat "${HL_SSH_PUBLIC_KEY}")"
HL_TITLE="${WARN}d2k $BLUE(D8G-2-K8S)$GREEN DEVELOPING$WARN TO$BLUE KUBERNETES$NORMAL"
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

export HL_MODULES=()
for file in "${HL_SCRIPT_BIN}/modules/"**/*cli.sh; do
    filename=$(basename -- "$file")
    # extension="${filename##*.}"
    filename="${filename%.*}"
    # shellcheck source=/dev/null
    source "$file"
    echo "${file}"
    HL_MODULES+=("${filename}")
done

# load "$HL_SCRIPT_APPS" "applications"
# export HL_PKG_APPS=("${HL_PKG_FILES[@]}")
# load "$HL_SCRIPT_TOOLS" "tools"
# export HL_PKG_TOOLS=("${HL_PKG_FILES[@]}")
# load "${HL_SCRIPT_CLIS}" "cli's"
# export HL_PKG_CLIS=("${HL_PKG_FILES[@]}")

args=( "${@:2}" )
cli="${1}_cli"
$cli "${args[@]}"
