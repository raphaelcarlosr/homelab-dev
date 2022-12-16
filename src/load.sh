#!/usr/bin/env bash
# shellcheck source=/dev/null
source "$HL_SCRIPT_BIN/common/std.sh"
source "$HL_SCRIPT_BIN/common/undo.sh"
set -o allexport
source "$HL_SCRIPT_BIN/common/vars.sh"
set +o allexport
source "$HL_SCRIPT_BIN/common/utils.sh"
source "$HL_SCRIPT_BIN/common/network.sh"
source "$HL_SCRIPT_BIN/common/requirements.sh"
source "$HL_SCRIPT_BIN/common/resources.sh"
source "$HL_SCRIPT_BIN/common/setup.sh"

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
    HL_SSH_PUBLIC_KEY_CONTENT

envsubst <"${HL_SCRIPT_SRC}/assets/banner.txt"
std_header "Developer Home Lab"
std_log "Using flag values"
for i in "${HL_FLAGS[@]}"; do std_log "${i}"; done

function _load(){
    _dir=$1
    kind=${2:-resource}
    i=0
    for file in "$_dir"/*.sh; do
        source "$file"
        i=$(("$i"+1))
    done
    std_log "$GREEN${i}$BLUE ${kind} ready to install"
}

_load "$HL_SCRIPT_BIN/apps" "applications"
_load "$HL_SCRIPT_BIN/tools" "tools"
_load "$HL_SCRIPT_BIN/cli" "cli's"

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
