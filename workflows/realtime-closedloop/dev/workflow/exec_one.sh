#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Pre-defined
MATLAB_VER=/opt/mcr/v911
DICOM_DIR="dicom"
NII_DIR="nii"
CSV_DIR="csv"
NII_OUTPUT="nii.tar.gz"

HOST_MOUNT="/labs/mahmoudilab/dev-synergy-rtcl-app/workflow/mount"
CONTAINER_MOUNT="/mount"

CONTAINER_HOME=/synergy-rtcl-app
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function dicom2nifti() {
    print_info "dicom2nifti() started"
    cd ${EXE_DIR}
    mkdir -p ${DICOM_DIR} && mkdir -p ${NII_DIR}
    rm -rf ${DICOM_DIR}/*.*
    rm -rf ${NII_DIR}/*.*
    cp ${DICOM_INPUT} ${DICOM_DIR}/${DICOM_NAMEONLY}

    cd ${DICOM_DIR} && tar -xvf ${DICOM_NAMEONLY}
    rm -f ${DICOM_NAMEONLY}

    cd ${CONTAINER_HOME}
    local command="./dcm2niix -o ${EXE_DIR}/${NII_DIR} -f D4_dcm2nii ${EXE_DIR}/${DICOM_DIR}"
    print_info "Calling: ${command}"
    time ${command}
    ## print_info "Calling: time python dicom_pypreprocess.py --filepath ${EXE_DIR}/${DICOM_DIR} --savepath ${EXE_DIR}/${NII_DIR}"
    ## time python dicom_pypreprocess.py --filepath ${EXE_DIR}/${DICOM_DIR} --savepath ${EXE_DIR}/${NII_DIR}
    rtn_code=$?
    print_info "dicom2nifti() user coding returned code=${rtn_code}"

    print_info "dicom2nifti(): Host:   OUTPUT=${HOST_EXEC_DIR}/${NII_DIR}"
    print_info "dicom2nifti(): Docker: OUTPUT=${EXE_DIR}/${NII_DIR}"
    print_info "dicom2nifti() completed"
}

function rtpreproc() {
  print_info "rtpreproc() started"
  mkdir -p ${EXE_DIR}/${CSV_DIR}
  ## TODO: find out where prenii comes from?

  local pre_nii=${EXE_DIR}/4D_pre.nii
  local subject_mask_nii=${EXE_DIR}/subject_mask.nii
  cd ${CONTAINER_HOME}
  ##local cmd_line="./run_RT_Preproc.sh ${MATLAB_VER} ${EXE_DIR}/${NII_DIR}"
  local cmd_line="./run_RT_Preproc.sh ${MATLAB_VER} ${EXE_DIR}/${NII_DIR}/D4_dcm2nii.nii ${pre_nii} ${subject_mask_nii} ${EXE_DIR}/${CSV_DIR}/${CSV_OUTPUT}"
  print_info "Calling: time ${cmd_line}"
  time ${cmd_line}
  rtn_code=$?
  print_info "rtpreproc() user coding returned code=${rtn_code}"
  ## ??print_info "mv /home/pgu6/realtime-closedloop/$CSV_OUTPUT /mount/wf-rt-closedloop/single-thread/csv/${CSV_OUTPUT}"
  ##  ?? mv /home/pgu6/realtime-closedloop/$CSV_OUTPUT /mount/wf-rt-closedloop/single-thread/csv/${CSV_OUTPUT}
  ## generate NII_OUTPUT
  echo "File under CONTAINER_HOME=${CONTAINER_HOME}"
  ls ${CONTAINER_HOME}/

  echo "File list under EXE_DIR=${EXE_DIR}"
  ls ${EXE_DIR}/*
  cd ${EXE_DIR}

  ##tar -czf ${NII_OUTPUT} ${NII_DIR} && rm -rf ${NII_DIR}
  chmod a+w ${EXE_DIR}/${CSV_DIR}/*.*
  print_info "rtpreproc(): Host:  OUTPUT=${HOST_EXEC_DIR}/${CSV_DIR}/${CSV_OUTPUT}"
  print_info "rtpreproc(): Docker:OUTPUT=${EXE_DIR}/${CSV_DIR}/${CSV_OUTPUT}"
  print_info "rtpreproc(): completed"
}

function optimizer() {
    print_info "optimizer() started"
    local optimizer_output=optimizer_out.csv
    cd ${CONTAINER_HOME}
    mkdir -p ${EXE_DIR}/${CSV_DIR}

    ## python fMRI_Bayesian_optimization.py --savepath <csv-output-folder> --savename <csv-output-filename).csv --objectivepath <path to $CSV_OUTPUT  file>
    local cmd_line="python fMRI_Bayesian_optimization.py --savepath ${EXE_DIR}/${CSV_DIR} --savename ${optimizer_output} --objectivepath ${EXE_DIR}/${CSV_DIR}/${CSV_OUTPUT}"

    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    ## time python output_randomcsv.py --savepath ${EXE_DIR}/${CSV_DIR} --savename ${CSV_OUTPUT}
    rtn_code=$?
    print_info "optimizer() user coding returned code=${rtn_code}"
    print_info "Files in directory: ${EXE_DIR}/${CSV_DIR}/" && ls ${EXE_DIR}/${CSV_DIR}

    ## print_info "CSV_OUTPUT=${HOST_EXEC_DIR}/${CSV_DIR}/${CSV_OUTPUT}"
    chmod a+w ${EXE_DIR}/${CSV_DIR}/*.*
    print_info "optimizer(): Host:   OUTPUT=${HOST_EXEC_DIR}/${CSV_DIR}/${optimizer_output}"
    print_info "optimizer(): Docker: OUTPUT=${EXE_DIR}/${CSV_DIR}/${optimizer_output}"
    print_info "optimizer() completed"
}

function save_output() {
  chmod -R a+w ${EXE_DIR}
  cd  ${EXE_DIR}
  local save_zip=saved_outputs_$(date -u +"%Y-%m-%d-%H-%M-%S").tar.gz
  print_info "tar -czf ${save_zip} ${DICOM_DIR} ${NII_DIR} ${CSV_DIR}"
  tar -czf ${save_zip} ${DICOM_DIR} ${NII_DIR} ${CSV_DIR}

  print_info "save_output(): Host:   OUTPUT=${HOST_EXEC_DIR}/${save_zip}"
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

DICOM_INPUT=$1
CSV_OUTPUT=$2
DICOM_NAMEONLY=$( basename ${DICOM_INPUT} )
WORKFLOW_ID=$3
EXE_DIR=${CONTAINER_MOUNT}/${WORKFLOW_ID}
mkdir -p ${EXE_DIR}
chmod -R a+r ${EXE_DIR}
HOST_EXEC_DIR=${HOST_MOUNT}/${WORKFLOW_ID}

dicom2nifti
rtpreproc
exit 0
optimizer
save_output
