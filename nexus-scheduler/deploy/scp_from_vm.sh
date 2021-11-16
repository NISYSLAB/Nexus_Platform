#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "13973-AB3 /${PASS}"
################################################
function scp_file() {
  local from=$1
  ##local to=$1
  echo "time scp $from ${USER}@${JUMP_ODDJOBS}:/home/pgu6/matlab_scheduler/deploy/"
  time scp -o ${USER}@${JUMP_ODDJOBS}:/home/pgu6/matlab_scheduler/deploy/
  ##time scp $from ${USER}@${JUMP_ODDJOBS}:/home/pgu6/matlab_scheduler/deploy/
}

function scp_from_remote_via_jumpbox() {
  local remote_file_path=$1
  local local_file_path=$2
  echo "remote_file_path=$remote_file_path"
  echo "local_file_path=$local_file_path"
  set -x
  scp -oProxyJump=${USER}@${JUMP_ODDJOBS} ${USER}@${BMI_VM}:${remote_file_path} ${local_file_path}
  ##scp -o "ProxyCommand ssh ${USER}@${JUMP_ODDJOBS} -W %h:%p" ${USER}@${BMI_VM}:${remote_file_path} ${local_file_path}
  ##scp -oProxyCommand = "ssh -W %h:%p ${USER}@${JUMP_ODDJOBS}" ${USER}@${BMI_VM}:${remote_file_path} ${local_file_path}

}
################################################
##scp_file "${PWD}/ssl/physionet-challenge-12lead-ecg-d875b52d05f9.json"
scp_from_remote_via_jumpbox "/home/pgu6/local_backend/nginx/conf/default.conf" "$PWD/vm_default.conf"
