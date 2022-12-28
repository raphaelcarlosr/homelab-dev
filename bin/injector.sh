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

export HL_MODULES=()
for file in "${HL_SCRIPT_BIN}/modules/"**/*cli.sh; do
    filename=$(basename -- "$file")
    dirname=$(dirname -- "$file")
    # IFS='/' read -r -a parts <<<"$dirname"
    module="${dirname##*/}"
    # extension="${filename##*.}"
    filename="${filename%.*}"
    # shellcheck source=/dev/null
    source "$file"
    HL_MODULES+=("${module}_cli")
done

HL_HOST_OS=$(uname_os)
HL_HOST_ARCH=$(uname_arch)
HL_HOST_PLATFORM="${HL_HOST_OS}/${HL_HOST_ARCH}"
# HL_HOST_AVAILABLE_MEMORY="$(requirement_cli memory)"
# HL_HOST_DISTRO="$(requirement_cli distro)"
HL_CURRENT_EXTERNAL_IP=$(network_cli dns external_ip)
HL_CURRENT_EXTERNAL_IP=$(extract_ip "${HL_CURRENT_EXTERNAL_IP}")
HL_SSH_PUBLIC_KEY_CONTENT= #"$(cat "${HL_SSH_PUBLIC_KEY}")"
HL_TITLE="${GREEN}D${WARN}2${BLUE}K - ${GREEN}DEVELOPING$WARN TO$BLUE KUBERNETES (${GREEN}D8G${WARN}2${BLUE}K8S)$NORMAL"
export HL_HOST_OS \
    HL_HOST_ARCH \
    HL_HOST_PLATFORM \
    HL_HOST_AVAILABLE_MEMORY \
    HL_HOST_DISTRO \
    HL_CURRENT_EXTERNAL_IP \
    HL_SSH_PUBLIC_KEY_CONTENT \
    HL_TITLE

# setup_ssh_key
show_banner
std_info "${HL_TITLE}"
std_info "[${HL_CMD_PROCESS}] ${HL_CMD_FILE} ${HL_CMD_ARGS[*]} --debug=${HL_DEBUG} ${WARN}${HL_PATH}${NORMAL}"
std_debug "Using flag values"
for i in "${HL_FLAGS[@]}"; do std_debug "${i}"; done

# validate and setup
requirement_cli is_root 
# requirement_cli memory | std_buf
# requirement_cli distro | std_buf
setup_directories

cli="${1}_cli"
args=("${@:2}")
if [[ ${HL_MODULES[*]} =~ (^|[[:space:]])"${cli}"($|[[:space:]]) ]]; then
    std_debug "$GREEN${1}$NORMAL module" "std_info"
    $cli "${args[@]}" # | std_buf
else
    module="${cli/_cli/}"
    modules="${HL_MODULES[*]/_cli/}"
    std_error "'$RED${module}$NORMAL' is not valid module, try use $GREEN${modules}"
fi

