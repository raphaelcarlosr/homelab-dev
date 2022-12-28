#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120
function d2k_app() {
    local action app
    action="${2}"
    app="${3}"
    std_info "${WARN}${action} ${BLUE}${app}"
    $app "${action}"
    std_success "${WARN}${action} ${BLUE}${app}"
}
