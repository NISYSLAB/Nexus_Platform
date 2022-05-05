#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Pre-defined
MATLAB_VER=/opt/mcr/v911
dicomDir="dicom"
niiDir="nii"

#### functions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function dicom2nifti() {
    print_info "dicom2nifti() started"
    mkdir -p ${dicomDir} && mkdir -p ${niiDir} && cp ${dicomInput} ${dicomDir}/input.tar.gz
    cd ${dicomDir} && tar -xzf input.tar.gz && rm -f input.tar.gz && cd -
    print_info "Files in directory: $(pwd)"
    ls
    print_info "Files in dicom directory: ${dicomDir}"
    ls ${dicomDir}/
    print_info "Calling: time python dicom_pypreprocess.py --filepath ${dicomDir} --savepath ${niiDir}"
    time python dicom_pypreprocess.py --filepath ${dicomDir} --savepath ${niiDir}
    rtn_code=$?
    print_info "dicom2nifti() user coding returned code=${rtn_code}"
    print_info "Files in nii directory: ${niiDir}"
    ls ${niiDir}
    print_info "dicom2nifti() completed"
}

function rtpreproc() {
  print_info "rtpreproc() started"
  cd ${currDir}
  local cmd_line="./run_RT_Preproc.sh ${MATLAB_VER} ${currDir}/${niiDir}"
  print_info "Calling: time ${cmd_line}"
  time ${cmd_line}
  rtn_code=$?
  print_info "rtpreproc() user coding returned code=${rtn_code}"
  print_info "rtpreproc() completed"
}

function csvgen() {
    print_info "csvgen() started"
    cd ${currDir}
    mkdir -p ${currDir}/csv
    print_info "Files in directory: $(pwd)"
    ls
    print_info "Calling: python output_randomcsv.py --savepath ${currDir}/csv --savename ${csvOutput}"
    time python output_randomcsv.py --savepath ${currDir}/csv --savename ${csvOutput}
    rtn_code=$?
    print_info "csvgen() user coding returned code=${rtn_code}"
    print_info "Files in directory: csv"
    ls csv
    cp csv/${csvOutput}  ./${csvOutput}
    print_info "csvgen() completed"
}

####

#### Main starts
## ./exec_realtime_loop.sh ${dicomInput} ${csvOutput} > ${log} 2>&1

msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"

currDir=$PWD
print_info "workDir=$currDir"

argCt=2
if [[ "$#" -ne ${argCt} ]]; then
    print_info "Invalid command line arguments, expecting $argCt"
    exit 1
fi

dicomInput=$1
csvOutput=$2

dicom2nifti
rtpreproc
csvgen
