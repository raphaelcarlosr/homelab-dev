#!/usr/bin/env bash

export REPO_RAW_URL
# banner_content=$(get_file "/assets/banner.txt" | envsubst)   
## To get all functions : bash -c "source src/load.bash && declare -F"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/std.sh"

# echo "$banner_content"
echo "$(cat "${SCRIPT_DIR}"/assets/banner.txt | envsubst)"
std_header "($RED$$)$GREEN$0 $*($#) | $GREEN${REPO_URL}"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/undo.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/utils.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/network.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/vars.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/requirements.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/setup.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/common/resources.sh"

# Tools

# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/tools/k3d.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/tools/multipass.sh"

# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/registry.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/secrets.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/packages/k3m.sh"
# # shellcheck source=/dev/null
# source "$SCRIPT_DIR/bin/apps/ops/tekton.sh"

# CLI

# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/cli/cluster.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/cli/apps.sh"

# std_header "Header"
# std_log "Log"
# std_success "Success"
# std_error "Error"
# std_info "Info"