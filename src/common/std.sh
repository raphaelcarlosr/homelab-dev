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

sp="/-\|"
sc=0
spin() {
    printf "\b${sp:sc++:1}"
    ((sc == ${#sp})) && sc=0
}
endspin() {
    printf "\r%s\n" "$@"
}