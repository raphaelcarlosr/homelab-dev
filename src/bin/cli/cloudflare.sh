#!/usr/bin/env bash

function cloudflare_tunnel() {
    # docker run -v ${PWD}/config:/home/cloudflared/.cloudflared crazymax/cloudflared tunnel login
    std_header "Configuring Cloudflared"
    # if [ ! -f ~/.cloudflared/cert.pem ]
    # then
    #     cloudflared tunnel login
    # fi
    # CF_TUNNEL_NAME=$SVC_NAMESPACE-gateway
    # CF_TUNNEL_ID=$(cloudflared tunnel list | grep $CF_TUNNEL_NAME | awk '{ print $1 }')
    # if [[ $CF_TUNNEL_ID == "" ]]
    # then
    #     cloudflared tunnel create $CF_TUNNEL_NAME
    #     CF_TUNNEL_ID=$(cloudflared tunnel list | grep $CF_TUNNEL_NAME | awk '{ print $1 }')
    # fi

    # header "Creating DNS for tunnel $CF_TUNNEL_ID/$CF_TUNNEL_NAME"
    # cloudflared tunnel route dns $CF_TUNNEL_NAME labs.$CF_HOST_NAME
}

function cloudflare_cli() {
    opt="$2"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Cloudflare ${action}"
    case $action in
    tunnel)
        cloudflare_tunnel "$@"
        ;;
    *)
        std_info "Usage"
        ;;
    esac
}

# echo "Configuring Cloudflared"
# if [ ! -f ~/.cloudflared/cert.pem ]
# then
#   cloudflared tunnel login
# fi
# CF_TUNNEL_NAME=$SVC_NAMESPACE-gateway
# CF_TUNNEL_ID=$(cloudflared tunnel list | grep $CF_TUNNEL_NAME | awk '{ print $1 }')
# if [[ $CF_TUNNEL_ID == "" ]]
# then
#   cloudflared tunnel create $CF_TUNNEL_NAME
#   CF_TUNNEL_ID=$(cloudflared tunnel list | grep $CF_TUNNEL_NAME | awk '{ print $1 }')
# fi

# echo "Creating DNS for tunnel $CF_TUNNEL_ID/$CF_TUNNEL_NAME"
# cloudflared tunnel route dns $CF_TUNNEL_NAME labs.$CF_HOST_NAME