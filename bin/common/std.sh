#!/usr/bin/env bash

export NC=$'\e[0m' # No Color
export BOLD=$'\033[1m'
export UNDERLINE=$'\033[4m'
export RED=$'\e[31m'
export GREEN=$'\e[32m'
export BLUE=$'\e[34m'
export WARN=$'\e[33m'
# export BOLD=$(tput bold)
NORMAL=$(tput sgr0)
export NORMAL
export YES_NO="(${BOLD}Y${NORMAL}es/${BOLD}N${NORMAL}o)"

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

export HL_READ_VALUE=
function read_value() {
    read -rp "${1} [${BOLD}${2}${NORMAL}]: " HL_READ_VALUE
    if [ "${HL_READ_VALUE}" = "" ]; then
        HL_READ_VALUE=$2
    fi
}

function std_header() {
    printf "\n$BLUE----- [${BOLD}${1}${NORMAL}] -----\n"
}

function std_log() {
    echo "${BLUE}${BOLD}DEBUG${NORMAL}[$(execution_time)] ${1}"
}

function std_success() {
    echo "$GREEN${BOLD}SUCCESS${NORMAL}[$(execution_time)] ${1}"
}
function std_warn() {
    echo "$WARN${BOLD}WARN${NORMAL}[$(execution_time)] ${1}"
}
function std_error() {
    echo "$RED${BOLD}ERROR${NORMAL}[$(execution_time)] ${1}"
}
function std_info() {
    echo "$BLUE${BOLD}INFO${NORMAL}[$(execution_time)] ${1}"
}
function std_array() {
    str=$1
    separator=${2:-'|'}
    log=${3:-"std_log"}
    IFS="${separator}" read -ra INFO <<<"${str}"
    for i in "${INFO[@]}"; do $log "${i:-Done}"; done
}
function std_debug() {
    str=$1
    log=${2:-"std_log"}
    if [ "${HL_DEBUG}" -eq 1 ]; then
        $log "${str}"
    fi
}
function std_debug_array() {
    str=$1
    separator=${2:-'|'}
    log=${3:-"std_log"}
    if [ "${HL_DEBUG}" -eq 1 ]; then
        std_array "${str}" "${separator}" "${log}"
    fi
}
function std_line() {
    echo "------------------------------------------------------------------------------------------------------------------------"
}
std_buf() {
    log=${1:-"std_info"}
    while IFS= read -r line; do
        $log "$line"
    done
}
function show_env_info() {
    envsubst <"${HL_SCRIPT_ASSETS}/env-info.txt" | column -t -s $'\t'
}
function show_banner() {
    envsubst <"${HL_SCRIPT_ASSETS}/logo.txt"
    echo
    std_line
    # echo "[d2k]${HL_TITLE}   $UNDERLINE${WARN}https://raphaelcarlosr.dev${NORMAL}    $UNDERLINE${WARN}https://github.com/raphaelcarlosr/homelab-dev$NORMAL" | column -t -s $'\t'
    # std_line
    # show_env_info
    # std_line
}
function spinner() {
    local action="${1}"
    spinnerRun() {
        i=1
        sp="/-\|"
        while true; do
            printf "\b${sp:i++%${#sp}:1}"
        done
    }
    spinnerRun &
    local spinnerPid=$!
    ${action} | std_buf
    kill "${spinnerPid}"
    printf "\bDone"
}

sp="/-\|"
sc=0
spin() {
    printf "\b${sp:sc++:1}"
    ((sc == ${#sp})) && sc=0
}
endspin() {
    printf "\r%s\n" "$@"
}
