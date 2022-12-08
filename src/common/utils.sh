#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
# BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YES_NO="(${BOLD}Y${NORMAL}es/${BOLD}N${NORMAL}o)"

function raise(){
  echo "${1}" >&2
}

function raise_error(){
  echo "${1}" >&2
  exit 1
}

function exit_with_message() {
    # $1 is error code
    # $2 is error message
    echo "Error $1: $2"
    exit $1
}

function exit_after_cleanup() {
    echo "Error $1: $2"
    rollback $1
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

function htpasswd(){
  if [ ! -f auth ]; then
      mkdir auth
  fi
  docker run --entrypoint htpasswd httpd:2 -Bbn "${1}" "${2}" > auth/htpasswd
}

