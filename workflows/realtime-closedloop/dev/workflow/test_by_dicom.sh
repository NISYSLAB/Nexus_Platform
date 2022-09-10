#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh

#### global settings
IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_NAME=realtime-closedloop-${PROFILE}

####
function preset() {
    echo "Received dicom tar.gz file: ${DICOM_TAR}"
    mkdir -p ${HOST_MOUNT}/test
    cp ${DICOM_TAR} ${HOST_MOUNT}/test
    cp ${PWD}/${EXEC_SCRIPT} ${HOST_MOUNT}/test/
}

function main_run() {
    local exe_dir=${CONTAINER_MOUNT}/test
    local nameonly=$( basename ${DICOM_TAR} )
    local csvfilename=D4_dcm2nii.nii
    local WORKFLOW_ID=test-executions
    local cmdArgs="${exe_dir}/${EXEC_SCRIPT} ${exe_dir}/${nameonly} ${csvfilename} ${WORKFLOW_ID}"
    echo "docker exec ${CONTAINER_NAME} ${cmdArgs}"
    docker exec ${CONTAINER_NAME} ${cmdArgs}
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
preset
main_run
