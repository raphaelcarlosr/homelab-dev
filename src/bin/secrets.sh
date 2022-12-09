#!/usr/bin/env bash
function htpasswd(){
  if [ ! -f auth ]; then
      mkdir auth
  fi
  docker run --entrypoint htpasswd httpd:2 -Bbn "${1}" "${2}" > auth/htpasswd
}