#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### for runtime configurations
SUBMIT_EXE_DIR=${SCRIPT_DIR}
RTCP_RUNTIME_DEFAULT_SETTINGS=${SUBMIT_EXE_DIR}/rtcp_default_settings.conf
RTCP_RUNTIME_USER_SETTINGS=${SUBMIT_EXE_DIR}/RTCP_RUNTIME_USER_SETTINGS.conf

cd ${SCRIPT_DIR}
source ${RTCP_RUNTIME_DEFAULT_SETTINGS}
source ${RTCP_RUNTIME_USER_SETTINGS}
env |grep "RTCP_"

source ./workflow_common_settings.sh

#### global settings
COMP1_NAME="rtpreprocess"
COMP2_NAME="bayes_opt_simple"
CONTAINER_NAME_COMP1=${WORKFLOW_NAME}-${COMP1_NAME}-${PROFILE}
CONTAINER_NAME_COMP2=${WORKFLOW_NAME}-${COMP2_NAME}-${PROFILE}
MOUNT_COMP1=${SUBMIT_EXE_DIR}/mount_${COMP1_NAME}
MOUNT_COMP2=${SUBMIT_EXE_DIR}/mount_${COMP2_NAME}
CONTAINER_MOUNT_COMP1=/mount_${COMP1_NAME}
CONTAINER_MOUNT_COMP2=/mount_${COMP2_NAME}
COMP1_SETTINGS=${SUBMIT_EXE_DIR}/${COMP1_NAME}_SETTINGS.conf
COMP2_SETTINGS=${SUBMIT_EXE_DIR}/${COMP2_NAME}_SETTINGS.conf
TASK_CALL_NAME=wf-rt-closedloop

MAX_PROC=1
PRE_4D_NII=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/${RTCP_PRE_4D_NII}
SUBJECT_MASK_NII=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/${RTCP_SUBJECT_MASK_NII}

##PRE_4D_NII=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/4D_pre.nii ??
##SUBJECT_MASK_NII=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/Wager_ACC_cluster8.nii ??

## TODO: following lines may not needed
## cd  /home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread
## ln -s /labs/mahmoudilab/synergy-rt-preproc/4D_pre.nii 4D_pre.nii
## cd $SCRIPT_DIR

#### functions
function push_2_remote() {
   local REMOTE_USER=Synergy
   local REMOTE_HOST_IP=${RTCP_TASK_SERVER_IP}
   ##local REMOTE_HOST_IP=170.140.61.150
   local REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/DEV-synergy_process/DATA_FROM_BMI
   local datafile=$1
   chmod a+rwx ${datafile}
   local shortname=$( basename ${datafile} )
   print_info "scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/${shortname}"
   scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/${shortname} && print_info "scp ${shortname} succeeded" || print_info "scp ${shortname} failed"
}

function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}
function print_error() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Error: ${msg}"
}

function print_warning() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Warning: ${msg}"
}

function submit_job(){
  ## logic: copy input and config to container 1, call container 1 exec script with input/ output, copy to container 2, call, push
  local host_exec_dir=${SUBMIT_EXE_DIR}/execution/${TASK_CALL_NAME}/${WORKFLOW_ID}
  mkdir -p ${host_exec_dir} && chmod a+wx ${host_exec_dir}
  cp ${PRE_4D_NII} ${host_exec_dir}/4D_pre.nii
  cp ${SUBJECT_MASK_NII} ${host_exec_dir}/subject_mask.nii
  local comp1_host_exec_dir=${MOUNT_COMP1}/${TASK_CALL_NAME}/${WORKFLOW_ID}
  local comp2_host_exec_dir=${MOUNT_COMP2}/${TASK_CALL_NAME}/${WORKFLOW_ID}
  local comp1_exec_dir=${CONTAINER_MOUNT_COMP1}/${TASK_CALL_NAME}/${WORKFLOW_ID}
  local comp2_exec_dir=${CONTAINER_MOUNT_COMP2}/${TASK_CALL_NAME}/${WORKFLOW_ID}
  mkdir -p ${comp1_host_exec_dir} && chmod a+wx ${host_exec_dir}
  mkdir -p ${comp2_host_exec_dir} && chmod a+wx ${host_exec_dir}


  ## dicom input
  cp ${imagePath} ${host_exec_dir}/${nameonly}

  ## copy mask files to container 1
  cp ${host_exec_dir}/4D_pre.nii ${comp1_host_exec_dir}/4D_pre.nii
  cp ${host_exec_dir}/subject_mask.nii ${comp1_host_exec_dir}/subject_mask.nii
  cp ${COMP1_SETTINGS} ${MOUNT_COMP1}

  ## copy input to container 1
  cp ${host_exec_dir}/${nameonly} ${comp1_host_exec_dir}/${nameonly}
  
  ## call container 1
  local cmdArgs="${CONTAINER_HOME}/${EXEC_SCRIPT} ${nameonly} ${csvfilename} ${WORKFLOW_ID}"
  print_info "docker exec ${CONTAINER_NAME_COMP1} ${cmdArgs}"
  echo "calling container 1"
  time docker exec ${CONTAINER_NAME_COMP1} ${cmdArgs} 2>&1 | tee -a ${host_exec_dir}/process_$( date +'%Y-%m-%d' ).log 

  ## copy config files to container 2
  cp ${COMP2_SETTINGS} ${MOUNT_COMP2}

  ## copy input to container 2
  cp ${comp1_host_exec_dir}/csv/${csvfilename} ${comp2_host_exec_dir}/csv/${csvfilename}
  
  ## call container 2
  local cmdArgs="${CONTAINER_HOME}/${EXEC_SCRIPT} ${csvfilename} ${optimizer_output} ${WORKFLOW_ID}"
  print_info "docker exec ${CONTAINER_NAME_COMP2} ${cmdArgs}"
  echo "calling container 2"
  time docker exec ${CONTAINER_NAME_COMP2} ${cmdArgs} 2>&1 | tee -a ${host_exec_dir}/process_$( date +'%Y-%m-%d' ).log 
  
  ## copy container 2 output
  cp ${comp2_host_exec_dir}/csv/${optimizer_output} ${host_exec_dir}/csv/${optimizer_output}

  ## push
  push_2_remote ${host_exec_dir}/csv/${optimizer_output}
}

## cmd="./submit_non_cromwell.sh ${tmplist}/${nameonly}"
#### Main starts
msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"
print_info "user process started"

noArg=1
if [[ "$#" -ne ${noArg} ]]; then
    print_error "Invalid command line arguments, expecting ${noArg}"
    exit 1
fi

imagePath=$1
nameonly=$(basename -- "$imagePath")
csvfilename=average_Reward_sig.csv
WORKFLOW_ID=$(uuidgen)
[[ "$MAX_PROC" == 1 ]] && WORKFLOW_ID="single-thread"
print_info "imagePath=${imagePath}"
print_info "nameonly=${nameonly}"
print_info "csvfilename=${csvfilename}"
print_info "WORKFLOW_ID=${WORKFLOW_ID}"
optimizer_output=optimizer_out.csv

submit_job

