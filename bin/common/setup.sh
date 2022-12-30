#!/usr/bin/env bash

function setup_directories() {
    mkdir -p -v "${D2K_CONFIG_ENV_PATH}" >/dev/null
    rm -rf "${D2K_SCRIPT_TMP}"
    mkdir -p -v "${D2K_SCRIPT_TMP}" >/dev/null
    sudo chmod a+rwx "${D2K_SCRIPT_TMP}"    
}

function setup_ssh_key() {
    if [ ! -f "${D2K_SSH_PUBLIC_KEY}" ]; then
        # key does not exist, create key
        # std_info "Specified key does not exist, creating $GREEN ssh key ${D2K_CONFIG_ENV_PATH}/.ssh"
        ssh-keygen -b 2048 -f "${D2K_CONFIG_ENV_PATH}"/.ssh -t rsa -C "homelab" -q -N ""
    fi
}
