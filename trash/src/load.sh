#!/usr/bin/env bash
HL_PKG_FILES=
function _load(){
    HL_PKG_FILES=()
    _dir=$1
    kind=${2:-resource}
    for file in "$_dir"/*.sh; do
        filename=$(basename -- "$file")
        # extension="${filename##*.}"
        filename="${filename%.*}"
        if [ "$filename" = "3.vars" ]; then
            set -o allexport
            # shellcheck source=/dev/null
            source "$file"
            set +o allexport
        else
            # shellcheck source=/dev/null
            source "$file"
        fi
        HL_PKG_FILES+=("${filename}")
    done
    if [ ! "$kind" = "resource" ]; then
        std_log "$GREEN${#HL_PKG_FILES[@]}$BLUE ${kind} ready: $GREEN${HL_PKG_FILES[*]}"
    fi
    export HL_PKG_FILES;
}

_load "$HL_SCRIPT_BIN/common"
HL_PKG_COMMON=("${HL_PKG_FILES[@]}")
# std_log "$GREEN${#pkg_common[@]}$BLUE ${kind} ready: $GREEN${pkg_common[*]}"

HL_HOST_OS=$(uname_os)
HL_HOST_ARCH=$(uname_arch)
HL_HOST_PLATFORM="${HL_HOST_OS}/${HL_HOST_ARCH}"
HL_HOST_AVAILABLE_MEMORY="$(check_memory)"
HL_HOST_DISTRO="$(check_distro)"
HL_CURRENT_EXTERNAL_IP=$(get_external_ip)
HL_SSH_PUBLIC_KEY_CONTENT="$(cat "${HL_SSH_PUBLIC_KEY}")"

export HL_HOST_OS \
    HL_HOST_ARCH \
    HL_HOST_PLATFORM \
    HL_HOST_AVAILABLE_MEMORY \
    HL_HOST_DISTRO \
    HL_CURRENT_EXTERNAL_IP \
    HL_CMD_PROCESS \
    HL_CMD_FILE \
    HL_CMD_ARGS \
    HL_CMD_ARGS_LEN \
    HL_SSH_PUBLIC_KEY_CONTENT \
    HL_PKG_COMMON

envsubst <"${HL_SCRIPT_SRC}/assets/banner.txt"
std_header "Developer Home Lab"
std_log "Using flag values"
for i in "${HL_FLAGS[@]}"; do std_log "${i}"; done

_load "$HL_SCRIPT_BIN/apps" "applications"
export HL_PKG_APPS=("${HL_PKG_FILES[@]}")
_load "$HL_SCRIPT_BIN/tools" "tools"
export HL_PKG_TOOLS=("${HL_PKG_FILES[@]}")
_load "$HL_SCRIPT_BIN/cli" "cli's"
export HL_PKG_CLIS=("${HL_PKG_FILES[@]}")

# Tools
# source "$HL_SCRIPT_BIN/tools/k3d.sh"
# source "$HL_SCRIPT_BIN/tools/multipass.sh"

# CLIs
# source "$HL_SCRIPT_BIN/cli/cluster.sh"

# export REPO_RAW_URL
# # banner_content=$(get_file "/assets/banner.txt" | envsubst)
# ## To get all functions : bash -c "source src/load.bash && declare -F"
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/std.sh"

# # echo "$banner_content"
# echo "$(cat "${SCRIPT_DIR}"/assets/banner.txt | envsubst)"
# std_header "($RED$$)$GREEN$0 $*($#) | $GREEN${REPO_URL}"

# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/undo.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/utils.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/network.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/vars.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/requirements.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/setup.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/common/resources.sh"

# # Tools

# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/tools/k3d.sh"
# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/bin/tools/multipass.sh"

# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/bin/registry.sh"
# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/bin/secrets.sh"
# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/bin/packages/k3m.sh"
# # # shellcheck source=/dev/null
# # source "$SCRIPT_DIR/bin/apps/ops/tekton.sh"

# # CLI

# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/cli/apps.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/cli/cloudflare.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/cli/cluster.sh"

# # std_header "Header"
# # std_log "Log"
# # std_success "Success"
# # std_error "Error"
# # std_info "Info"
