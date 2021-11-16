#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "139733abE /${PASS}"
################################################
function scp_file() {
  local from=$1
  ##local to=$1
  echo "copy file ${from} to ${BMI_VM}"

  ##echo "scp -o 'ProxyJump ${JUMP_ODDJOBS}' "${from}" ${BMI_VM}:/home/pgu6/local_backend/"
  ##scp -o "ProxyCommand ssh ${USER}@${JUMP_ODDJOBS} -W %h:%p" "${from}" ${USER}@${BMI_VM}:/home/pgu6/local_backend/
  scp -o ProxyCommand="ssh -W %h:%p ${USER}@${JUMP_ODDJOBS}" "${from}" ${USER}@${BMI_VM}:/home/pgu6/local_backend/
}

function scp_file_2_jump() {
  local :q@from=$1
  ##local to=$1
  echo "copy file ${from} to jump box: ${JUMP_ODDJOBS}"
  echo "time scp $from ${USER}@${JUMP_ODDJOBS}:/home/pgu6"
  time scp "${from}" ${USER}@${JUMP_ODDJOBS}:/home/pgu6/
}

################################################
##scp_file ${PWD}/local_backend_1.zip
##scp_file ../docker/common_settings.sh
scp_file $PWD/dir.zip
