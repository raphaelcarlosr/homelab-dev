#!/usr/bin/env bash

function config_cli() {
    # https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
    POSITIONAL_ARGS=()
    echo "Args ${BASE_DIR}"
    while [[ $# -gt 0 ]]; do
        case $1 in
        -p | --path)
            HL_PATH="$2"
            export HL_PATH
            shift # past argument
            shift # past value
            ;;
        -n | --name)
            HL_NAME="$2"
            export HL_NAME
            shift # past argument
            shift # past value
            ;;
        -d | --domain)
            HL_FQDN_DOMAIN="$2"
            export HL_FQDN_DOMAIN
            shift # past argument
            shift # past value
            ;;
        --default)
            DEFAULT=YES
            shift # past argument
            ;;
        -* | --*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift                   # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
}
