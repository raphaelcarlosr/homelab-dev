#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'

function raise(){
  echo "${1}" >&2
}

function raise_error(){
  echo "${1}" >&2
  exit 1
}

function get_vm_name() {
  read -rp "${BLUE}VM Name: ${NC}" VM_NAME
  export VM_NAME
}

function all_colors(){
  echo "$BOLD R $UNDERLINE A $RED J $GREEN A. $BLUE S $NC"
}