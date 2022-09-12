#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh

#### global settings
IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_NAME=realtime-closedloop-${PROFILE}

####
function pre_process() {
    echo "Received dicom tar.gz file: ${DICOM_TAR}"
    local host_dir=${HOST_MOUNT}/${WORKFLOW_ID}
    mkdir -p ${host_dir}
    cp ${DICOM_TAR} ${host_dir}/
    cp ${PWD}/${EXEC_SCRIPT} ${host_dir}/
    cp /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/4D_pre.nii  ${host_dir}/
    cp /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/Wager_ACC_cluster8.nii ${host_dir}/subject_mask.nii
    ##local container_exe_dir=${CONTAINER_MOUNT}/${WORKFLOW_ID}
    ## docker cp /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/4D_pre.nii ${CONTAINER_NAME}:${container_exe_dir}/
    ## docker cp /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/Wager_ACC_cluster8.nii ${CONTAINER_NAME}:${container_exe_dir}/subject_mask.nii
    ## docker cp /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/RewSig_Z_map.nii ${CONTAINER_NAME}:${container_exe_dir}/
    ## dockercp /labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image/wRewSig_Z_map.nii ${CONTAINER_NAME}:${container_exe_dir}/
}

function main_run() {
    local exe_dir=${CONTAINER_MOUNT}/${WORKFLOW_ID}
    local nameonly=$( basename ${DICOM_TAR} )
    local csvfilename=D4_dcm2nii.nii
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
WORKFLOW_ID=test-executions
pre_process
main_run
