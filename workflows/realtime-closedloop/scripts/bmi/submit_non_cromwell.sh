#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
CONTAINER_NAME=realtime-closedloop-prod
MOUNT=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount
CONTAINER_MOUNT=/mount
CONTAINER_HOME=/home/pgu6/realtime-closedloop
execScript=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl/exec_one.sh
DISK_MOUNTS="${MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop

#### functions
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
  ## exec scrpt
  cp ${execScript} ${host_exec_dir}/exec_realtime_loop.sh
  ## dicom input
  cp ${imagePath} ${host_exec_dir}/${nameonly}

  local exe_dir=${CONTAINER_MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}
  local cmdArgs="${exe_dir}/exec_realtime_loop.sh ${exe_dir}/${nameonly} ${csvfilename} ${WORKFLOW_ID}"
  print_info "docker exec ${CONTAINER_NAME} ${cmdArgs}"
  docker exec ${CONTAINER_NAME} ${cmdArgs} 2>&1 | tee ${host_exec_dir}/process.log
  print_info "finalOutput=${host_exec_dir}/csv/${csvfilename}"
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
csvfilename="${nameonly%.*}"
csvfilename="${csvfilename%.*}".csv
WORKFLOW_ID=$(uuidgen)
print_info "imagePath=${imagePath}"
print_info "nameonly=${nameonly}"
print_info "csvfilename=${csvfilename}"
print_info "WORKFLOW_ID=${WORKFLOW_ID}"

submit_job