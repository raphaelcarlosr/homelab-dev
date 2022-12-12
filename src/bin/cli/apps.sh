#!/usr/bin/env bash

function apps_cli() {
    opt="$2"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Apps ${action}"
    case $action in
    metallb) metallb_cli "$@" ;;
    *)
        std_info "Usage"
        ;;
    esac
}