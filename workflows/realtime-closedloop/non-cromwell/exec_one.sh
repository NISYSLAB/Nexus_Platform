#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Pre-defined
MATLAB_VER=/opt/mcr/v911
dicomDir="dicom"
niiDir="nii"
niiOutput="nii.tar.gz"

CONTAINER_HOME=/home/pgu6/realtime-closedloop
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function nameonly() {
  shortname=$( basename ${dicomInput} )
}

function dicom2nifti() {
    print_info "dicom2nifti() started"
    cd ${EXE_DIR}
    mkdir -p ${dicomDir} && mkdir -p ${niiDir} && cp ${dicomInput} ${dicomDir}/${shortname}
    cd ${dicomDir} && unzip ${shortname} || echo "Unable to unzip, try tar" &&  tar -xzf ${shortname}
    rm -f ${shortname} && cd -
    print_info "Files in directory: $(pwd)"
    ls
    print_info "Files in dicom directory: ${dicomDir}"
    ls ${dicomDir}/
    cd {CONTAINER_HOME}
    print_info "Calling: time python dicom_pypreprocess.py --filepath ${EXE_DIR}/${dicomDir} --savepath ${EXE_DIR}/${niiDir}"
    time python dicom_pypreprocess.py --filepath ${EXE_DIR}/${dicomDir} --savepath ${EXE_DIR}/${niiDir}
    rtn_code=$?
    print_info "dicom2nifti() user coding returned code=${rtn_code}"
    print_info "Files in nii directory: ${EXE_DIR}/${niiDir}"
    ls ${EXE_DIR}/${niiDir}
    ## delete dicomDir
    rm -rf ${EXE_DIR}/${dicomDir}
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
  print_info "rtpreproc() completed"
}

function csvgen() {
    print_info "csvgen() started"
    cd ${CONTAINER_HOME}
    mkdir -p ${EXE_DIR}/csv
    print_info "Files in directory: $(pwd)"
    ls
    print_info "Calling: python output_randomcsv.py --savepath ${EXE_DIR}/csv --savename ${csvOutput}"
    time python output_randomcsv.py --savepath ${EXE_DIR}/csv --savename ${csvOutput}
    rtn_code=$?
    print_info "csvgen() user coding returned code=${rtn_code}"
    print_info "Files in directory: csv"
    ls ${EXE_DIR}/csv
    print_info "csvOutput=${EXE_DIR}/csv/${csvOutput}"
    print_info "csvOutput=${MOUNT}/csv/${csvOutput}"
    print_info "csvgen() completed"
}

####

#### Main starts
## ./exec_realtime_loop.sh ${dicomInput} ${csvOutput} ${WORKFLOW_ID} > ${log} 2>&1
## exe_dir=${CONTAINER_HOME}/${TASK_CALL_NAME}/${WORKFLOW_ID}
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
shortname=$( nameonly )
WORKFLOW_ID=$3
EXE_DIR=${CONTAINER_HOME}/${TASK_CALL_NAME}/${WORKFLOW_ID}

dicom2nifti
rtpreproc
csvgen
