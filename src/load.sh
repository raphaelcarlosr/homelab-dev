#!/usr/bin/env bash

export REPO_RAW_URL
# banner_content=$(get_file "/assets/banner.txt" | envsubst)   
# echo "$banner_content"
echo "$(get_file "/assets/banner.txt" | envsubst)"

## To get all functions : bash -c "source src/load.bash && declare -F"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/common/std.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/common/undo.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/common/requirements.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/common/utils.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/multipass.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/apps/tekton.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cli/cluster.sh"

# std_header "Header"
# std_log "Log"
# std_success "Success"
# std_error "Error"
# std_info "Info"