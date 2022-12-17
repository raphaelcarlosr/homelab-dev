#!/usr/bin/env bash

function get_external_ip(){
    if [[ $UNAMECHK == "Darwin" ]]; then
        ifconfig | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | head -n1
    else
        ip a | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | head -n1
    fi
}