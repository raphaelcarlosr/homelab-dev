#!/usr/bin/env bash

function cleanup(){
    echo "Cleanup"
}
function rollback(){
    echo "Rollback"
}

trap 'rollback $?' ERR SIGINT