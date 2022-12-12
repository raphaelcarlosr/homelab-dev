#!/usr/bin/env bash

# Apps
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/apps/infra/metallb.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/apps/infra/nginx.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/bin/apps/infra/traefik.sh"

function apps_cli() {
    opt="$2"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Apps ${action}"
    case $action in
    metallb) metallb_cli "$@" ;;
    nginx) nginx_cli "$@" ;;
    traefik) traefik_cli "$@" ;;
    *)
        std_info "Usage"
        ;;
    esac
}