#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Pre-defined
MATLAB_VER=/opt/mcr/v911
DICOM_DIR="dicom"
NII_DIR="nii"
CSV_DIR="csv"
NII_OUTPUT="nii.tar.gz"

CONTAINER_MOUNT="/mount_bayes_opt_simple"

CONTAINER_HOME=/home/yzhu382/dev-synergy-rtcl-app/src/rt_prepro

source ${CONTAINER_MOUNT}/bayes_opt_simple_SETTINGS.conf

#### functions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function optimizer() {
    print_info "optimizer() started"
    cd ${CONTAINER_HOME}
    mkdir -p ${EXE_DIR}/${CSV_DIR}
    chmod -R a+rw ${EXE_DIR}/${CSV_DIR}

    local cmd_line="python fMRI_Bayesian_optimization.py --savepath ${EXE_DIR}/${CSV_DIR} --savename ${CSV_OUTPUT} --objectivepath ${EXE_DIR}/${CSV_DIR}/${CSV_INPUT}"

    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "optimizer() user coding returned code=${rtn_code}"
    print_info "Files in directory: ${EXE_DIR}/${CSV_DIR}/" && ls ${EXE_DIR}/${CSV_DIR}

    chmod a+w ${EXE_DIR}/${CSV_DIR}/*.*
    print_info "optimizer(): Docker: OUTPUT=${EXE_DIR}/${CSV_DIR}/${CSV_OUTPUT}"
    print_info "optimizer() completed"
}

function save_output() {
  chmod -R a+w ${EXE_DIR}
  cd  ${EXE_DIR}
  local save_zip=saved_outputs_$(date -u +"%Y-%m-%d-%H-%M-%S").tar.gz
  print_info "tar -czf ${save_zip} ${CSV_DIR}"
  tar -czf ${save_zip} ${CSV_DIR}

  print_info "save_output(): Docker: OUTPUT=${EXE_DIR}/${save_zip}"
}

#### Main starts
msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"
currDir=$PWD
print_info "workDir=$currDir"

argCt=3
if [[ "$#" -ne ${argCt} ]]; then
    print_info "Invalid command line arguments, expecting $argCt"
    exit 1
fi

CSV_INPUT=$1
CSV_OUTPUT=$2
WORKFLOW_ID=$3
EXE_DIR=${CONTAINER_MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}
mkdir -p ${EXE_DIR}
chmod -R a+rw ${EXE_DIR}

optimizer
save_output
