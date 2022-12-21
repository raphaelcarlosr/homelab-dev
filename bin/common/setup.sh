#!/usr/bin/env bash

function setup_directories() {
    mkdir -p -v "${HL_PATH}" >/dev/null
}

function setup_ssh_key() {
    if [ ! -f "${HL_SSH_PUBLIC_KEY}" ]; then
        # key does not exist, create key
        # std_info "Specified key does not exist, creating $GREEN ssh key ${HL_PATH}/.ssh"
        ssh-keygen -b 2048 -f "${HL_PATH}"/.ssh -t rsa -C "homelab" -q -N ""
    fi
}
