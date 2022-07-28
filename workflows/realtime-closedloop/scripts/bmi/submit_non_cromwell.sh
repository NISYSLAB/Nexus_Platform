#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
CONTAINER_NAME=realtime-closedloop-prod
MOUNT=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount
CONTAINER_MOUNT=/mount
CONTAINER_HOME=/home/pgu6/realtime-closedloop
EXEC_SCRIPT=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl/exec_one.sh
DISK_MOUNTS="${MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop
MAX_PROC=1
PRE_4D_NII=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/4D_pre.nii
SUBJECT_MASK_NII=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/Wager_ACC_cluster8.nii

## TODO: following lines may not needed
## cd  /home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread
## ln -s /labs/mahmoudilab/synergy-rt-preproc/4D_pre.nii 4D_pre.nii
## cd $SCRIPT_DIR

#### functions
function push_2_remote() {
   local REMOTE_USER=Synergy
   ##local REMOTE_HOST_IP=10.44.106.72
   local REMOTE_HOST_IP=10.44.86.87
   ##local REMOTE_HOST_IP=170.140.61.150
   local REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/synergy_process/DATA_FROM_BMI
   local datafile=$1
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
  local host_exec_dir=${MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}
  mkdir -p ${host_exec_dir}
  cp ${PRE_4D_NII} ${host_exec_dir}/4D_pre.nii
  cp ${SUBJECT_MASK_NII} ${host_exec_dir}/subject_mask.nii
  ## exec scrpt
  local nameonly_exec_script=$( basename ${EXEC_SCRIPT} )
  cp ${EXEC_SCRIPT} ${host_exec_dir}/${nameonly_exec_script}
  ## dicom input
  cp ${imagePath} ${host_exec_dir}/${nameonly}

  local exe_dir=${CONTAINER_MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}

  local cmdArgs="${exe_dir}/${nameonly_exec_script} ${exe_dir}/${nameonly} ${csvfilename} ${WORKFLOW_ID}"
  print_info "docker exec ${CONTAINER_NAME} ${cmdArgs}"
  docker exec ${CONTAINER_NAME} ${cmdArgs} 2>&1 | tee -a ${host_exec_dir}/process_$( date +'%Y-%m-%d' ).log
  print_info "finalOutput=${host_exec_dir}/csv/${optimizer_output}"
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
##csvfilename="${nameonly%.*}"
##csvfilename="${csvfilename%.*}".csv
csvfilename=objective.csv
WORKFLOW_ID=$(uuidgen)
[[ "$MAX_PROC" == 1 ]] && WORKFLOW_ID="single-thread"
print_info "imagePath=${imagePath}"
print_info "nameonly=${nameonly}"
print_info "csvfilename=${csvfilename}"
print_info "WORKFLOW_ID=${WORKFLOW_ID}"
optimizer_output=optimizer_out.csv

submit_job
