#!/bin/bash
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

######## global decleartions
    
LOOP=10
SECONDS_WAIT=20

######## function definitions

function print_sys_info() {
  print_info "System Specs: $( uname -a )"
  print_info $(cat /etc/os-release )
}

function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function is_http_ok() {
    local url=$1
    local OK=200
    local CODE=$(curl -s -o /dev/null -w "%{http_code}" "${url}")
    if [ "$OK" == "$CODE" ]; then
      echo "Y"
    else
      echo "N"
    fi
}

function download() {

    for (( c=1; c<=${LOOP}; c++ ))
    do  
      echo "######## At loop $c: download: ${URL}"
      GOOD=$(is_http_ok "${URL}")
      if [ "$GOOD" == "Y" ]; then
        echo "download url was ready: ${URL}"
        echo "curl ${URL} --output ${OUTPUT}"
        curl "${URL}" --output "${OUTPUT}" || exit 1
        break
      else
        echo "download url was Not ready, wait ${SECONDS_WAIT} seconds: ${URL}"
        sleep "${SECONDS_WAIT}"
      fi
      
    done
}

######## exec starts
print_sys_info
print_info "SCRIPT_NAME=${SCRIPT_NAME} "
print_info "SCRIPT_DIR=${SCRIPT_DIR} "
print_info "LOCAL_USER=$(whoami) "
print_info "WORK_DIR=${PWD}"
print_info "${SCRIPT_NAME}: started at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"

URL=$1
OUTPUT=$2

download

ls -alt "${OUTPUT}"
cat "${OUTPUT}"

print_info "${SCRIPT_NAME}: finished at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"

