#!/usr/bin/env bash
execution_time(){
    ps -o etime= "${HL_CMD_PROCESS}" | sed -e 's/^[[:space:]]*//'
}
tag_to_version() {
    if [ -z "${HL_TAG}" ]; then
        log_info "checking GitHub for latest tag"
    else
        log_info "checking GitHub for tag '${HL_TAG}'"
    fi
    REALTAG=$(github_release "$OWNER/$REPO" "${HL_TAG}") && true
    if test -z "$REALTAG"; then
        log_crit "unable to find '${HL_TAG}' - use 'latest' or see https://github.com/${PREFIX}/releases for details"
        exit 1
    fi
    # if version starts with 'v', remove it
    HL_TAG="$REALTAG"
    #   VERSION=${TAG#v}
}
adjust_format() {
    # change format (tar.gz or zip) based on OS
    case ${OS} in
    windows) FORMAT=zip ;;
    esac
    true
}
adjust_os() {
    # adjust archive name based on OS
    case ${OS} in
    386) OS=i386 ;;
    amd64) OS=x86_64 ;;
    darwin) OS=Darwin ;;
    linux) OS=Linux ;;
    windows) OS=Windows ;;
    esac
    true
}
adjust_arch() {
    # adjust archive name based on ARCH
    case ${ARCH} in
    386) ARCH=i386 ;;
    amd64) ARCH=x86_64 ;;
    darwin) ARCH=Darwin ;;
    linux) ARCH=Linux ;;
    windows) ARCH=Windows ;;
    esac
    true
}
is_command() {
    command -v "$1" >/dev/null
}

uname_os() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$os" in
    cygwin_nt*) os="windows" ;;
    mingw*) os="windows" ;;
    msys_nt*) os="windows" ;;
    esac
    echo "$os"
}
uname_arch() {
    arch=$(uname -m)
    case $arch in
    x86_64) arch="amd64" ;;
    x86) arch="386" ;;
    i686) arch="386" ;;
    i386) arch="386" ;;
    aarch64) arch="arm64" ;;
    armv5*) arch="armv5" ;;
    armv6*) arch="armv6" ;;
    armv7*) arch="armv7" ;;
    esac
    echo ${arch}
}
uname_os_check() {
    os=$(uname_os)
    case "$os" in
    darwin) return 0 ;;
    dragonfly) return 0 ;;
    freebsd) return 0 ;;
    linux) return 0 ;;
    android) return 0 ;;
    nacl) return 0 ;;
    netbsd) return 0 ;;
    openbsd) return 0 ;;
    plan9) return 0 ;;
    solaris) return 0 ;;
    windows) return 0 ;;
    esac
    log_crit "uname_os_check '$(uname -s)' got converted to '$os' which is not a GOOS value. Please file bug at https://github.com/client9/shlib"
    return 1
}
uname_arch_check() {
    arch=$(uname_arch)
    case "$arch" in
    386) return 0 ;;
    amd64) return 0 ;;
    arm64) return 0 ;;
    armv5) return 0 ;;
    armv6) return 0 ;;
    armv7) return 0 ;;
    ppc64) return 0 ;;
    ppc64le) return 0 ;;
    mips) return 0 ;;
    mipsle) return 0 ;;
    mips64) return 0 ;;
    mips64le) return 0 ;;
    s390x) return 0 ;;
    amd64p32) return 0 ;;
    esac
    log_crit "uname_arch_check '$(uname -m)' got converted to '$arch' which is not a GOARCH value.  Please file bug report at https://github.com/client9/shlib"
    return 1
}
untar() {
    tarball=$1
    case "${tarball}" in
    *.tar.gz | *.tgz) tar --no-same-owner -xzf "${tarball}" ;;
    *.tar) tar --no-same-owner -xf "${tarball}" ;;
    *.zip) unzip "${tarball}" ;;
    *)
        log_err "untar unknown archive format for ${tarball}"
        return 1
        ;;
    esac
}
http_download_curl() {
    local_file=$1
    source_url=$2
    header=$3
    if [ -z "$header" ]; then
        code=$(curl -w '%{http_code}' -sL -o "$local_file" "$source_url")
    else
        code=$(curl -w '%{http_code}' -sL -H "$header" -o "$local_file" "$source_url")
    fi
    if [ "$code" != "200" ]; then
        log_debug "http_download_curl received HTTP status $code"
        return 1
    fi
    return 0
}
http_download_wget() {
    local_file=$1
    source_url=$2
    header=$3
    if [ -z "$header" ]; then
        wget -q -O "$local_file" "$source_url"
    else
        wget -q --header "$header" -O "$local_file" "$source_url"
    fi
}
http_download() {
    log_debug "http_download $2"
    if is_command curl; then
        http_download_curl "$@"
        return
    elif is_command wget; then
        http_download_wget "$@"
        return
    fi
    log_crit "http_download unable to find wget or curl"
    return 1
}
http_copy() {
    tmp=$(mktemp)
    http_download "${tmp}" "$1" "$2" || return 1
    body=$(cat "$tmp")
    rm -f "${tmp}"
    echo "$body"
}
github_release() {
    owner_repo=$1
    version=$2
    test -z "$version" && version="latest"
    giturl="https://github.com/${owner_repo}/releases/${version}"
    json=$(http_copy "$giturl" "Accept:application/json")
    test -z "$json" && return 1
    version=$(echo "$json" | tr -s '\n' ' ' | sed 's/.*"tag_name":"//' | sed 's/".*//')
    test -z "$version" && return 1
    echo "$version"
}
hash_sha256() {
    TARGET=${1:-/dev/stdin}
    if is_command gsha256sum; then
        hash=$(gsha256sum "$TARGET") || return 1
        echo "$hash" | cut -d ' ' -f 1
    elif is_command sha256sum; then
        hash=$(sha256sum "$TARGET") || return 1
        echo "$hash" | cut -d ' ' -f 1
    elif is_command shasum; then
        hash=$(shasum -a 256 "$TARGET" 2>/dev/null) || return 1
        echo "$hash" | cut -d ' ' -f 1
    elif is_command openssl; then
        hash=$(openssl -dst openssl dgst -sha256 "$TARGET") || return 1
        echo "$hash" | cut -d ' ' -f a
    else
        log_crit "hash_sha256 unable to find command to compute sha-256 hash"
        return 1
    fi
}
hash_sha256_verify() {
    TARGET=$1
    checksums=$2
    if [ -z "$checksums" ]; then
        log_err "hash_sha256_verify checksum file not specified in arg2"
        return 1
    fi
    BASENAME=${TARGET##*/}
    want=$(grep "${BASENAME}" "${checksums}" 2>/dev/null | tr '\t' ' ' | cut -d ' ' -f 1)
    if [ -z "$want" ]; then
        log_err "hash_sha256_verify unable to find checksum for '${TARGET}' in '${checksums}'"
        return 1
    fi
    got=$(hash_sha256 "$TARGET")
    if [ "$want" != "$got" ]; then
        log_err "hash_sha256_verify checksum for '$TARGET' did not verify ${want} vs $got"
        return 1
    fi
}

# function get_vm_name() {
#   read -rp "${BLUE}VM Name: ${NC}" VM_NAME
#   export VM_NAME
# }

# function all_colors(){
#   echo "$BOLD R $UNDERLINE A $RED J $GREEN A. $BLUE S $NC"
# }

# function get_local_or_remote_file() {
#     if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
#         echo "${REPO_RAW_URL}"
#     else
#         echo "${BASE_DIR}"
#     fi
# }

# function get_file() {
#     if [ "${USE_REMOTE_REPO}" -eq 1 ]; then
#         curl "$REPO_RAW_URL/${1}" # --output "${1}"
#     else
#         cat "${BASE_DIR}/${1}"
#     fi
# }