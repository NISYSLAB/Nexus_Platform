#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Pre-defined
MATLAB_VER=/opt/mcr/v911
DICOM_DIR="dicom"
NII_DIR="nii"
CSV_DIR="csv"
NII_OUTPUT="nii.tar.gz"

MOUNT=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount
CONTAINER_MOUNT=/mount
CONTAINER_HOME=/home/pgu6/realtime-closedloop
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
    cp ${dicom_input} ${DICOM_DIR}/${shortname}

    cd ${DICOM_DIR} && tar -xvf ${shortname}
    rm -f ${shortname} && cd ${EXE_DIR}

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
  cd ${CONTAINER_HOME}
  ##local cmd_line="./run_RT_Preproc.sh ${MATLAB_VER} ${EXE_DIR}/${NII_DIR}"
  local cmd_line="./run_RT_Preproc.sh ${MATLAB_VER} ${EXE_DIR}/${NII_DIR}/D4_dcm2nii.nii ${pre_nii} ${EXE_DIR}/${CSV_DIR}/${csv_output}"
  print_info "Calling: time ${cmd_line}"
  time ${cmd_line}
  rtn_code=$?
  print_info "rtpreproc() user coding returned code=${rtn_code}"
  ## generate NII_OUTPUT
  cd ${EXE_DIR}
  ##tar -czf ${NII_OUTPUT} ${NII_DIR} && rm -rf ${NII_DIR}
  chmod a+w ${EXE_DIR}/${CSV_DIR}/*.*
  print_info "rtpreproc(): Host:  OUTPUT=${HOST_EXEC_DIR}/${CSV_DIR}/${csv_output}"
  print_info "rtpreproc(): Docker:OUTPUT=${EXE_DIR}/${CSV_DIR}/${csv_output}"
  print_info "rtpreproc(): completed"
}

function optimizer() {
    print_info "optimizer() started"
    local optimizer_output=optimizer_out.csv
    cd ${CONTAINER_HOME}
    mkdir -p ${EXE_DIR}/${CSV_DIR}

    ## python fMRI_Bayesian_optimization.py --savepath <csv-output-folder> --savename <csv-output-filename).csv --objectivepath <path to objective.csv file>
    local cmd_line="python fMRI_Bayesian_optimization.py --savepath ${EXE_DIR}/${CSV_DIR} --savename ${optimizer_output} --objectivepath ${EXE_DIR}/${CSV_DIR}/${csv_output}"

    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    ## time python output_randomcsv.py --savepath ${EXE_DIR}/${CSV_DIR} --savename ${csv_output}
    rtn_code=$?
    print_info "optimizer() user coding returned code=${rtn_code}"
    print_info "Files in directory: ${EXE_DIR}/${CSV_DIR}/" && ls ${EXE_DIR}/${CSV_DIR}

    ## print_info "csv_output=${HOST_EXEC_DIR}/${CSV_DIR}/${csv_output}"
    chmod a+w ${EXE_DIR}/${CSV_DIR}/*.*
    print_info "optimizer(): Host:   OUTPUT=${HOST_EXEC_DIR}/${CSV_DIR}/${optimizer_output}"
    print_info "optimizer(): Docker: OUTPUT=${EXE_DIR}/${CSV_DIR}/${optimizer_output}"
    print_info "optimizer() completed"
}

function save_output() {
  chmod -R a+w ${EXE_DIR}
  cd  ${EXE_DIR}
  local save_zip=saved_outputs_$(date -u +"%m%d%Y-%H-%M-%S").tar.gz
  print_info "tar -czf ${save_zip} ${DICOM_DIR} ${NII_DIR} ${CSV_DIR}"
  tar -czf ${save_zip} ${DICOM_DIR} ${NII_DIR} ${CSV_DIR}

  print_info "save_output(): Host:   OUTPUT=${HOST_EXEC_DIR}/${save_zip}"
  print_info "save_output(): Docker: OUTPUT=${EXE_DIR}/${save_zip}"
}

####

#### Main starts
## ./exec_realtime_loop.sh ${dicom_input} ${csv_output} ${WORKFLOW_ID} > ${log} 2>&1
## exe_dir=${CONTAINER_MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}
##${exe_dir}/exec_realtime_loop.sh ${exe_dir}/${nameonly} ${csvfilename} ${WORKFLOW_ID}
## TASK_CALL_NAME=wf-rt-closedloop

msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"
currDir=$PWD
print_info "workDir=$currDir"

argCt=3
if [[ "$#" -ne ${argCt} ]]; then
    print_info "Invalid command line arguments, expecting $argCt"
    exit 1
fi

dicom_input=$1
csv_output=$2
shortname=$( basename ${dicom_input} )
WORKFLOW_ID=$3
EXE_DIR=${CONTAINER_MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}
HOST_EXEC_DIR=${MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}

dicom2nifti
rtpreproc
optimizer
save_output
