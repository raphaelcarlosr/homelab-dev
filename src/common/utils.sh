#!/usr/bin/env bash

# function raise(){
#   std_info "${1}" >&2
# }

# function raise_error(){
#   std_error "${1}" >&2
#   exit 1
# }

function exit_with_message() {
    # $1 is error code
    # $2 is error message
    std_error "Error $1: $2"
    std_error "Exit code for the script: $?"
    exit "$1"
}

function exit_after_cleanup() {
    std_error "Error $1: $2"
    rollback "$1"
}

READ_VALUE=
function read_value() {
    read -rp "${1} [${BOLD}${2}${NORMAL}]: " READ_VALUE
    if [ "${READ_VALUE}" = "" ]; then
        READ_VALUE=$2
    fi
}

function get_vm_name() {
  read -rp "${BLUE}VM Name: ${NC}" VM_NAME
  export VM_NAME
}

function all_colors(){
  echo "$BOLD R $UNDERLINE A $RED J $GREEN A. $BLUE S $NC"
}

function get_local_or_remote_file() {
    if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
        echo "${REPO_RAW_URL}"
    else
        echo "${BASE_DIR}"
    fi
}

function get_file() {
    if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
        curl "$REPO_RAW_URL/${1}" # --output "${1}"
    else
        cat "${BASE_DIR}/${1}"
    fi
}