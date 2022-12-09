#!/usr/bin/env bash

function cleanup(){
    std_header "Cleanup"
}
function rollback(){
    cleanup 
    std_header "Rollback"
    exit "$1"
}

trap 'rollback $?' ERR SIGINT