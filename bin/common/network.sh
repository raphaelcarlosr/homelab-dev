#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120
function ddns(){
    local URL IP NAME DATA_FLAG DATA_VALUE
    NAME=${1:-$HL_CF_DNS_ENTRY_ID}    
    URL="https://api.cloudflare.com/client/v4/zones/${HL_CF_ZONE_ID}/dns_records/${NAME}"
    IP=$(external_ip)
    
    cf(){
        DATA_FLAG=${2}
        DATA_VALUE=${3}
        # std_info "${1} ${URL} ${HL_CF_TOKEN}"
        # curl -X "${1}" "https://api.cloudflare.com/client/v4/user/tokens/verify" \
        #     -H "Authorization: Bearer ${HL_CF_DNS_TOKEN}" \
        #     -H "Content-Type:application/json" | tail -1
        local response
        if [ "${DATA_FLAG}" = "" ] || [ "${DATA_VALUE}" = "" ]; then
            response=$(curl -s -X "${1}" "${URL}" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${HL_CF_TOKEN}")
        else 
            response=$(curl -s -X "${1}" "${URL}" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer ${HL_CF_TOKEN}" \
                "${DATA_FLAG}" "${DATA_VALUE}")
        fi
        echo "${response}"
        
    }
    
    RESULT=$(cf GET)
    IP_CF=$(jq -r '.result.content' <<< "${RESULT}")
    std_info "${RESULT}"
    # Compare IPs
    if [ "$IP" = "$IP_CF" ]; then
        std_info "No change."
    else
        RESULT=$(cf PUT --data "{\"type\":\"A\",\"name\":\"${NAME}\",\"content\":\"${IP}\"}")
        std_success "DNS updated. ${IP} to ${NAME}"
        std_success "${RESULT}"
    fi
}

function external_ip() {
    local IP
    IP=$(dig +short txt ch whoami.cloudflare @1.0.0.1| tr -d '"')
    echo "${IP}"
    # if [[ $UNAMECHK == "Darwin" ]]; then
    #     ifconfig | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | head -n1
    # else
    #     ip a | grep "inet " | grep -v "127.0.0.1" | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | head -n1
    # fi
}

function etc_hosts() {
    local HOSTSFILE BAKFILE DOMAINREGEX IPREGEX URLREGEX
    HOSTSFILE="/etc/hosts"
    BAKFILE="$HOSTSFILE.bak"
    DOMAINREGEX="^[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]+$"
    IPREGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
    URLREGEX="^https?:\/\/[a-zA-Z0-9]{1}[a-zA-Z0-9\/\.\-]+$"
    backup() {
        cat $HOSTSFILE >$BAKFILE
    }

    usage() {
        std_info "Commands:"
        std_info "- add      <host> <ip>"
        std_info "- remove   <host>"
        std_info "- update   <host> <ip>"
        std_info "- check    <host>"
        std_info "- rollback"
        std_info "- import   <file or url> [--append]"
        std_info "- export   <file>"
    }

    case $1 in
    add)
        if [ ! $# == 3 ]; then
            std_error "Incorrect Usage: add <host> <ip>"
            return
        fi

        if [[ ! $2 =~ $DOMAINREGEX ]]; then
            std_error "Invalid host: \"$2\""
            return
        fi

        if [[ ! $3 =~ $IPREGEX ]]; then
            std_warn "Invalid IP: \"$3\""
            return
        fi

        REGEX="${2}$"

        if [ $(cat $HOSTSFILE | grep $REGEX | wc -l | sed 's/^ *//g') != 0 ]; then
            std_warn "Unable to add host \"$2\" because it already exists."
            return
        fi

        echo "" >> $HOSTSFILE
        echo -e "$3\t$2" >> $HOSTSFILE

        std_info "Successfully added host \"$2\"."
        ;;

    check)
        if [ ! $# == 2 ]; then
            std_error "Incorrect usage: check <host>"
            return
        fi

        REGEX="${2}$"

        if [ $(cat $HOSTSFILE | grep $REGEX | wc -l | sed 's/^ *//g') != 0 ]; then
            std_info "$(cat $HOSTSFILE | grep "$2")"
            return
        else
            std_error "Unable to check host \"$2\" because it does not exist."
            return
        fi
        ;;

    remove)
        if [ ! $# == 2 ]; then
            std_error "Incorrect usage: remove <host>"
            return
        fi
        REGEX="$2$"
        if [ $(cat $HOSTSFILE | grep $REGEX | wc -l | sed 's/^ *//g') = 0 ]; then
            std_warn "Unable to remove host \"$2\" because it does not exist."
            return
        fi

        backup

        cat $HOSTSFILE | sed -e "/$2$/ d" >tmp && mv tmp $HOSTSFILE

        std_info "Successfully removed host \"$2\"."
        ;;

    update)
        if [ ! $# == 3 ]; then
            std_error "Incorrect usage: update <host> <ip>"
            return
        fi

        if [[ ! $3 =~ $IPREGEX ]]; then
            std_warn "Invalid IP: \"$3\""
            return
        fi

        if [[ ! $2 =~ $DOMAINREGEX ]]; then
            std_warn "Invalid host: \"$2\""
            return
        fi

        backup

        $0 remove "$2"

        $0 add "$2" "$3"

        std_info "Successfully updated host \"$2\" to \"$3\"."
        return
        ;;

    import)
        TEMPFILE="./hosts-import-$(date +%s).tmp"
        APPEND=0
        if [ ! $# -gt 1 ]; then
            std_error "Incorrect usage: import <file> [--append]"
            return
        fi
        if [ ! -z "$3" ]; then
            if [ "$3" == "--append" ]; then
                APPEND=1
            fi
        fi

        if [[ $2 =~ $URLREGEX ]]; then
            echo "curl -s -o $TEMPFILE $2"
        else
            TEMPFILE=$2
        fi

        if [ -f "$TEMPFILE" ]; then
            backup

            IMPORTPREFIX="\n# IMPORTED FROM: $2\n"

            if [ $APPEND == 0 ]; then
                echo -e "$(head -n 11 $HOSTSFILE)$(echo $IMPORTPREFIX)$(cat $TEMPFILE)" >$HOSTSFILE

                std_info "Successfully imported \"$2\"."
                return
            else
                echo -e $IMPORTPREFIX >>$HOSTSFILE

                cat $TEMPFILE >>$HOSTSFILE

                std_info "Successfully appended \"$2\""
                return
            fi
        else
            echo "Invalid file"
            echo ""
            exit 1
        fi
        ;;

    export)
        if [ ! $# == 2 ]; then
            std_info "Usage: export <file>"
            return
        fi
        cat $HOSTSFILE >"$2"

        std_info "Successfully exported to \"$2\""
        return
        ;;

    rollback)
        if [ -f $BAKFILE ]; then
            cat $BAKFILE >$HOSTSFILE

            rm $BAKFILE

            std_info "Successfully rolled back."
        else
            std_error "Unable to roll back because no backup file exists."
            return
        fi
        ;;

    -h)
        usage
        return
        ;;

    *)
        std_error "etc_hosts Incorrect usage: -h for help"
        usage
        return
        ;;

    esac
}
