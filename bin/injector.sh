#!/usr/bin/env bash


export D2K_INI_LOG=()
export D2K_PKG_FILES=

function load() {
    local dirname pattern kind
    D2K_PKG_FILES=()
    dirname="${1}"
    pattern=${2-"sh"}
    kind=${2:-resource}
    for file in "${D2K_SCRIPT_BIN}/$dirname"/*."${pattern}"; do
        filename=$(basename -- "$file")
        # extension="${filename##*.}"
        filename="${filename%.*}"
        if [ ! "$filename" = "cli" ]; then
            # shellcheck source=/dev/null
            source "$file"
            D2K_PKG_FILES+=("${filename}")
        fi

    done
    if [ ! "$kind" = "resource" ]; then
        D2K_INI_LOG+=("$GREEN${#D2K_PKG_FILES[@]}$BLUE ${kind} ready: $GREEN${D2K_PKG_FILES[*]}")
    fi
    export D2K_PKG_FILES
}

load "common"
export D2K_PKG_COMMON=("${D2K_PKG_FILES[@]}")

export D2K_MODULES=()
for file in "${D2K_SCRIPT_BIN}/modules/"**/*cli.sh; do
    filename=$(basename -- "$file")
    dirname=$(dirname -- "$file")
    # IFS='/' read -r -a parts <<<"$dirname"
    module="${dirname##*/}"
    # extension="${filename##*.}"
    filename="${filename%.*}"
    # shellcheck source=/dev/null
    source "$file"
    D2K_MODULES+=("${module}_cli")
done

# set -o allexport
# shellcheck source=/dev/null
source "$D2K_SCRIPT_BIN/vars.sh"
# set +o allexport

D2K_HOST_OS=$(uname_os)
D2K_HOST_ARCH=$(uname_arch)
D2K_HOST_PLATFORM="${D2K_HOST_OS}/${D2K_HOST_ARCH}"
# D2K_HOST_AVAILABLE_MEMORY="$(requirement_cli memory)"
# D2K_HOST_DISTRO="$(requirement_cli distro)"
D2K_CURRENT_EXTERNAL_IP=$(network_cli dns external_ip)
D2K_CURRENT_EXTERNAL_IP=$(extract_ip "${D2K_CURRENT_EXTERNAL_IP}")
D2K_SSH_PUBLIC_KEY_CONTENT= #"$(cat "${D2K_SSH_PUBLIC_KEY}")"
D2K_TITLE="${GREEN}D${WARN}2${BLUE}K - ${GREEN}DEVELOPING$WARN TO$BLUE KUBERNETES (${GREEN}D8G${WARN}2${BLUE}K8S)$NORMAL"
export D2K_HOST_OS \
    D2K_HOST_ARCH \
    D2K_HOST_PLATFORM \
    D2K_HOST_AVAILABLE_MEMORY \
    D2K_HOST_DISTRO \
    D2K_CURRENT_EXTERNAL_IP \
    D2K_SSH_PUBLIC_KEY_CONTENT \
    D2K_TITLE

# setup_ssh_key
show_banner
std_info "${D2K_TITLE}"
std_info "[${D2K_CMD_PROCESS}] ${D2K_CMD_FILE} ${D2K_CMD_ARGS[*]} --debug=${D2K_DEBUG} ${WARN}${D2K_CONFIG_ENV_PATH}${NORMAL}"
std_debug "Using flag values"
for i in "${D2K_FLAGS[@]}"; do std_debug "${i}"; done

# validate and setup
requirement_cli is_root 
requirement_cli docker 
requirement_cli niet 
# requirement_cli memory | std_buf
# requirement_cli distro | std_buf
setup_directories

cli="${1}_cli"
args=("${@:2}")
if [[ ${D2K_MODULES[*]} =~ (^|[[:space:]])"${cli}"($|[[:space:]]) ]]; then
    std_debug "$GREEN${1}$NORMAL module" "std_info"
    $cli "${args[@]}" # | std_buf
else
    module="${cli/_cli/}"
    modules="${D2K_MODULES[*]/_cli/}"
    std_error "'$RED${module}$NORMAL' is not valid module, try use $GREEN${modules}"
fi

