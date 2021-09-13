#!/bin/bash
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function print_sys_info() {
  print_info "System Specs: $( uname -a )"
  print_info $(cat /etc/os-release )
}

function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

##############################
print_sys_info
print_info "SCRIPT_NAME=${SCRIPT_NAME} "
print_info "SCRIPT_DIR=${SCRIPT_DIR} "
print_info "LOCAL_USER=$(whoami) "
print_info "WORK_DIR=${PWD}"
print_info "${SCRIPT_NAME}: started at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"

URL=$1
OUTPUT=$2

echo "wget -O ${OUTPUT} ${URL}"
wget -O "${OUTPUT}" "${URL}" || exit    

ls -alt "${OUTPUT}"
cat "${OUTPUT}"

print_info "${SCRIPT_NAME}: finished at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"

