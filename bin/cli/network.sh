#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120
function d2k_network() {
    local action
    action="${2}"
    std_info "${WARN}${action}"
    $action | std_buf
    std_success "${WARN}${action}"
}
