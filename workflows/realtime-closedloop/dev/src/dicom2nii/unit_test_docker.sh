#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh

container_name=dicom2nii-DEV
####
function pre_process() {
    echo "Received dicom tar.gz file: ${DICOM_TAR}"
    echo "Cleanup docom/nii folders before new run"
    rm -rf dicom/*.*
    rm -rf nii/*.*
    tar -xf "${DICOM_TAR}" --directory "${PWD}/dicom"
    echo "dicom images under dicom folder ..."
    echo ""
    ls dicom/*
    echo ""
}

function main_run() {
    local exe_dir=/synergy-rtcl-app
    local nameonly=$( basename ${DICOM_TAR} )
    local command="./dcm2niix -o ${exe_dir}/nii -f D4_dcm2nii ${exe_dir}/dicom"
    echo ""
    echo "docker exec ${container_name} ${command}"
    docker exec ${container_name} ${command}
    echo ""
    echo "Files in dicom folder"
    ls dicom/*
    echo ""
    echo "File in nii folder"
    ls nii/*
    echo ""
}
#### Main starts
msg="Calling: ${SCRIPT_NAME} $@"
argCt=1
if [[ "$#" -ne ${argCt} ]]; then
    echo "Usage: ./${SCRIPT_NAME} <dicom-tar.gz-file-full-path>"
    echo "  e.g: ./${SCRIPT_NAME} /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed/single-thread/dcm_1_5-6-2022.tar.gz"
    exit 1
fi

DICOM_TAR=$1
pre_process
main_run
