#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YES_NO="(${BOLD}Y${NORMAL}es/${BOLD}N${NORMAL}o)"

function std_header() {
    printf "\n$BLUE----- [${BOLD}${1}${NORMAL}] -----\n"
}

function std_log() {
    echo "$BLUE ---- [${BOLD}${1}${NORMAL}]"
}

function std_success() {
    echo "$GREEN ---- [${BOLD}${1}${NORMAL}]"
}

function std_error() {
    echo "$RED ---- [${BOLD}${1}${NORMAL}]"
}

function std_info() {
    echo "$BLUE ---- [${BOLD}${1}${NORMAL}]"
}

function std_array(){
    str=$1
    separator=${2:-'|'}
    log=${3:-"std_log"}
    IFS="${separator}" read -ra INFO <<< "${str}"
    for i in "${INFO[@]}"; do $log "${i:-Done}"; done
}

function std_debug(){
    str=$1
    log=${2:-"std_log"}
    if [ "${HL_DEBUG}" -eq 1 ]; then
        $log "${str}"
    fi
}

function std_debug_array(){
    str=$1
    separator=${2:-'|'}
    log=${3:-"std_log"}
    if [ "${HL_DEBUG}" -eq 1 ]; then
        std_array "${str}" "${separator}" "${log}"
    fi
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