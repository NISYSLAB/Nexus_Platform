#!/usr/bin/env bash

cd ..
source ./common_settings.sh
cd -

## Customized envs
JUMP_NEBULA=nebula.bmi.emory.edu 
DATALINK=datalink.bmi.emory.edu
JUMP_ODDJOBS=oddjobs.bmi.emory.edu
BMI_VM=cromwell-7.priv.bmi.emory.edu
SYNERGY_1_VM=synergy1.priv.bmi.emory.edu
SYNERGY_2_VM=synergy2.priv.bmi.emory.edu
##BMI_VM=physionet2020.priv.bmi.emory.edu
USER=${BMI_VM_USER}
PASS=${BMI_VM_PASS}
SSH_ID_FILE=/Users/anniegu/.ssh/bmi_ssh_key

export server_ssl_key_store_path=/home/ssl/keystore.p12
export auth_option=BASIC

#### function definitions
################################################
function scp_to_vm() {
  local src=$1
  local dest=$2
  local dest_vm=$3
  echo "SCP file: ${src} ${USER}@${dest_vm}:${dest}"
  ##echo "scp -o 'ProxyJump ${JUMP_ODDJOBS}' "${from}" ${BMI_VM}:/home/pgu6/local_backend/"
  ##scp -o "ProxyCommand ssh ${USER}@${JUMP_ODDJOBS} -W %h:%p" "${from}" ${USER}@${BMI_VM}:/home/pgu6/local_backend/
  scp -o ProxyCommand="ssh -W %h:%p ${USER}@${JUMP_ODDJOBS}" -v "${src}" "${USER}"@"${dest_vm}":"${dest}"
}

function scp_to_jumpbox() {
  local from=$1
  local dest=$2
  echo "copy file ${from} to jump box: ${JUMP_ODDJOBS}"
  echo "time scp $from ${USER}@${JUMP_ODDJOBS}:${dest}"
  time scp "${from}" "${USER}"@"${JUMP_ODDJOBS}":"${dest}"
}
