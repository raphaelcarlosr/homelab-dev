#!/usr/bin/env bash

is_root(){
    if [ $EUID -ne 0 ]; then
        exit_with_message 1 "Run this as root or with sudo privilege."
    fi
    std_success "Running as root or sudo privilege"
}

distro() {
    distroId=$(grep -w DISTRIB_ID /etc/*-release | cut -d "=" -f 2)
    distroVersion=$(grep -w DISTRIB_RELEASE /etc/*-release | cut -d "=" -f 2)
    if [ "$distroId" != "Ubuntu" ]; then
        exit_with_message 1 "$distroId:$distroVersion is unsupported Distro. This script is written for Ubuntu OS only."
    fi
    echo "$distroId:$distroVersion"
}

memory() {
    min="${1:-2}"
    totalMem=$(free --giga | grep -w Mem | tr -s " " | cut -d " " -f 2)
    usedMem=$(free --giga | grep -w Mem | tr -s " " | cut -d " " -f 3)
    availableMem=$(("$totalMem" - "$usedMem"))
    # std_info "Available Memory: $GREEN${availableMem}Gi"
    if [ "$availableMem" -lt "$min" ]; then
        exit_with_message 1 "Atleast ${WARN}${min}Gi${NORMAL} of free memory required. Just ${RED}${availableMem}Gi${NORMAL} available"
    fi
    echo "${availableMem}Gi"
}