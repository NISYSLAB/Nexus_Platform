#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Pre-defined
MATLAB_VER=/opt/mcr/v911
dicomDir="dicom"
niiDir="nii"
csvDir="csv"
niiOutput="nii.tar.gz"

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
    mkdir -p ${dicomDir} && mkdir -p ${niiDir} && cp ${dicomInput} ${dicomDir}/${shortname}
    ##print_info "files under $PWD" && ls ./*

    cd ${dicomDir} && tar -xvf ${shortname}
    rm -f ${shortname} && cd -

    ##print_info "Files in directory: $(pwd)" && ls
    ##print_info "Files in dicom directory: ${dicomDir}" && ls ${dicomDir}/

    cd ${CONTAINER_HOME}
    print_info "Calling: time python dicom_pypreprocess.py --filepath ${EXE_DIR}/${dicomDir} --savepath ${EXE_DIR}/${niiDir}"
    time python dicom_pypreprocess.py --filepath ${EXE_DIR}/${dicomDir} --savepath ${EXE_DIR}/${niiDir}
    rtn_code=$?
    print_info "dicom2nifti() user coding returned code=${rtn_code}"
    ##print_info "Files in nii directory: ${EXE_DIR}/${niiDir}" && ls ${EXE_DIR}/${niiDir}
    ##print_info "delete folder: ${EXE_DIR}/${dicomDir}" && rm -rf ${EXE_DIR}/${dicomDir}
    print_info "dicom2nifti(): OUTPUT=${host_exec_dir}/${niiDir}"
    print_info "dicom2nifti() completed"
}

function rtpreproc() {
  print_info "rtpreproc() started"
  cd ${CONTAINER_HOME}
  local cmd_line="./run_RT_Preproc.sh ${MATLAB_VER} ${EXE_DIR}/${niiDir}"
  print_info "Calling: time ${cmd_line}"
  time ${cmd_line}
  rtn_code=$?
  print_info "rtpreproc() user coding returned code=${rtn_code}"
  ## generate niiOutput
  cd ${EXE_DIR}
  tar -czf ${niiOutput} ${niiDir} && rm -rf ${niiDir}
  print_info "rtpreproc(): OUTPUT=${host_exec_dir}/TBD??"
  print_info "rtpreproc() completed"
}

function optimizer() {
    print_info "optimizer() started"
    cd ${CONTAINER_HOME}
    mkdir -p ${EXE_DIR}/${csvDir}
    ## print_info "Files in directory: $(pwd)" && ls

    print_info "Calling: python output_randomcsv.py --savepath ${EXE_DIR}/${csvDir} --savename ${csvOutput}"
    time python output_randomcsv.py --savepath ${EXE_DIR}/${csvDir} --savename ${csvOutput}
    rtn_code=$?
    print_info "optimizer() user coding returned code=${rtn_code}"
    print_info "Files in directory: ${csvDir}" && ls ${EXE_DIR}/${csvDir}

    ## print_info "csvOutput=${host_exec_dir}/${csvDir}/${csvOutput}"
    print_info "optimizer(): OUTPUT=${host_exec_dir}/${csvDir}/${csvOutput}"
    print_info "optimizer() completed"
}

####

#### Main starts
## ./exec_realtime_loop.sh ${dicomInput} ${csvOutput} ${WORKFLOW_ID} > ${log} 2>&1
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

dicomInput=$1
csvOutput=$2
shortname=$( basename ${dicomInput} )
WORKFLOW_ID=$3
EXE_DIR=${CONTAINER_MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}
host_exec_dir=${MOUNT}/${TASK_CALL_NAME}/${WORKFLOW_ID}

dicom2nifti
rtpreproc
optimizer
