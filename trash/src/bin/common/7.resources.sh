#!/usr/bin/env bash

function read_cloud_init()
{
    HL_CLOUD_INIT_FILE="${SCRIPT_DIR}/resources/cloud-init.yaml"
    export HL_CLOUD_INIT_FILE
    local content
    content=$(cat "${HL_CLOUD_INIT_FILE}" | envsubst)    
    echo "${content}"
}
function read_ssh_content(){
    local content
    content=$(cat "${HL_SSH_PUBLIC_KEY}")    
    echo "$content"
}

# read_ssh_content
# read_cloud_init