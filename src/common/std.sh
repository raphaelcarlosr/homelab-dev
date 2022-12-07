#!/usr/bin/env bash

function std_header() {
    printf "\n----- [${BOLD}${1}${NORMAL}]\n"
}

function std_log() {
    echo " --- [${BOLD}${1}${NORMAL}]"
}
function std_success() {
    echo "$GREEN --- [${BOLD}${1}${NORMAL}]"
}
function std_error() {
    echo "$RED --- [${BOLD}${1}${NORMAL}]"
}
function std_info() {
    echo "$BLUE --- [${BOLD}${1}${NORMAL}]"
}