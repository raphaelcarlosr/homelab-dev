#!/usr/bin/env bash
std_header "Checking host requirements"

if [ $EUID -ne 0 ]; then
    exit_with_message 1 "Run this as root or with sudo privilege."
fi

function check_distro() {
    distroId=$(grep -w DISTRIB_ID /etc/*-release | cut -d "=" -f 2)
    distroVersion=$(grep -w DISTRIB_RELEASE /etc/*-release | cut -d "=" -f 2)
    std_info "Distro: $GREEN$distroId:$distroVersion"
    if [ "$distroId" != "Ubuntu" ]; then
        exit_with_message 1 "Unsupported Distro. This script is written for Ubuntu OS only."
    fi
}

function check_memory() {
    totalMem=$(free --giga | grep -w Mem | tr -s " " | cut -d " " -f 2)
    usedMem=$(free --giga | grep -w Mem | tr -s " " | cut -d " " -f 3)
    availableMem=$(expr "$totalMem" - "$usedMem")
    std_info "Available Memory: $GREEN${availableMem}Gi"
    if [ "$availableMem" -lt 2 ]; then
        exit_with_message 1 "Atleast 2Gi of free memory required."
    fi
}

function check_ssh_key(){
    if [ -f "${HL_SSH_PUBLIC_KEY}" ]
    then
        # key exists, read content
        HL_SSH_PUBLIC_KEY_CONTENT="$(cat ${HL_SSH_PUBLIC_KEY})"
    else 
        # key does not exist, create key
        std_info "Specified key does not exist, creating $GREEN ssh key ${HL_PATH}/ssh_key"
        ssh-keygen -b 2048 -f "${HL_PATH}"/ssh_key -t rsa -C "homelab" -q -N ""
        HL_SSH_PRIVATE_KEY=${HL_PATH}/ssh_key
        HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
        HL_SSH_PUBLIC_KEY_CONTENT="$(cat "${HL_SSH_PUBLIC_KEY}")"
    fi    
}

check_distro
check_memory
# check_ssh_key