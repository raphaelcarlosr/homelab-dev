#!/usr/bin/env bash
dns() {
    external_ip() {
        echo "$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')"
        # local IP
        # IP=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')        
        # std_info "Host current external IP ${IP}"
        # echo "${IP}"
        # if [[ $UNAMECHK == "Darwin" ]]; then
        #     ifconfig | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | head -n1
        # else
        #     ip a | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | head -n1
        # fi
    }

    action="${1}"
    args=("${@:1}")
    $action "${args[@]}" # | std_buf
}


# ddns(){
#     local URL IP NAME DATA_FLAG DATA_VALUE
#     NAME=${1:-$D2K_CF_DNS_ENTRY_ID}    
#     URL="https://api.cloudflare.com/client/v4/zones/${D2K_CF_ZONE_ID}/dns_records/${NAME}"
#     IP=$(external_ip)
    
#     cf(){
#         DATA_FLAG=${2}
#         DATA_VALUE=${3}
#         # std_info "${1} ${URL} ${D2K_CF_TOKEN}"
#         # curl -X "${1}" "https://api.cloudflare.com/client/v4/user/tokens/verify" \
#         #     -H "Authorization: Bearer ${D2K_CF_DNS_TOKEN}" \
#         #     -H "Content-Type:application/json" | tail -1
#         local response
#         if [ "${DATA_FLAG}" = "" ] || [ "${DATA_VALUE}" = "" ]; then
#             response=$(curl -s -X "${1}" "${URL}" \
#                 -H "Content-Type: application/json" \
#                 -H "Authorization: Bearer ${D2K_CF_TOKEN}")
#         else 
#             response=$(curl -s -X "${1}" "${URL}" \
#                 -H "Content-Type: application/json" \
#                 -H "Authorization: Bearer ${D2K_CF_TOKEN}" \
#                 "${DATA_FLAG}" "${DATA_VALUE}")
#         fi
#         echo "${response}"
        
#     }
    
#     RESULT=$(cf GET)
#     IP_CF=$(jq -r '.result.content' <<< "${RESULT}")
#     std_info "${RESULT}"
#     # Compare IPs
#     if [ "$IP" = "$IP_CF" ]; then
#         std_info "No change."
#     else
#         RESULT=$(cf PUT --data "{\"type\":\"A\",\"name\":\"${NAME}\",\"content\":\"${IP}\"}")
#         std_success "DNS updated. ${IP} to ${NAME}"
#         std_success "${RESULT}"
#     fi
# }