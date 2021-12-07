#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

######## Env
IMAGE_NAME=fmri_biomarker
IMAGE_TAG=1.3

GCR_PATH=cloudypipelines-com
CONTAINER_REGISTRY=gcr.io
docker_image=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
execScript=${predict_exec_script}

##uid=$((1 + $RANDOM % 5000))
uid=$(uuidgen)
uid=${uid:0:12}
containerName="predict_fmri_biomarker"
MOUNT=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount_predit/${uid}
##MOUNT=$PWD/"mount_predit_${uid}"
+DISK_MOUNTS=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount_predit

version=1
trainedModelOutputs="trained_model"
savedResults="predict_saved_results"

TASK_CALL_NAME=modelPredict
##WORKFLOW_ID=$(uuidgen)
COPY_RESULTS=Y

## for scp results to remote
REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/synergy_process/DATA_FROM_BMI
REMOTE_USER=Synergy
REMOTE_HOST_IP=10.44.92.68

######## functions
function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")][${SCRIPT_NAME}]: Info: ${msg}"
}

print_env() {
  print_info "trainData=$trainData"
  print_info "testData=$testData"
  print_info "version=$version"
  print_info "trainedModelOutputs=$trainedModelOutputs"
  print_info "savedResults=$savedResults"
  print_info "containerName=$containerName"
  print_info "execScript=$execScript"
  print_info "MOUNT=${MOUNT}"
}

function pre_run() {
    mkdir -p ${MOUNT}
    cp  ${execScript} ${MOUNT}/predict_exec.sh
    cp ${trainData} ${MOUNT}/trained_model.tar.gz
    mv ${testData} ${MOUNT}/${test_data_file_name}
}


function run_docker() {
  local cmdArgs="${MOUNT}/predict_exec.sh ${MOUNT}/trained_model.tar.gz ${MOUNT}/${test_data_file_name} ${version} ${trainedModelOutputs} ${savedResults}"
  docker run --rm -t \
        -v ${MOUNT}:${MOUNT} \
        --name ${containerName}  \
        -e DISK_MOUNTS=${MOUNT} \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${containerName} \
        -e WORKFLOW_ID=${WORKFLOW_ID} \
        -e COPY_RESULTS=${COPY_RESULTS} \
        ${docker_image} \
        /bin/bash ${cmdArgs} 2>&1 | tee ${MOUNT}/${TASK_CALL_NAME}.log

}
function exec_docker() {
  local cmdArgs="${MOUNT}/predict_exec.sh ${MOUNT}/trained_model.tar.gz ${MOUNT}/${test_data_file_name} ${version} ${trainedModelOutputs} ${savedResults}"
  echo "docker exec ${containerName} ${cmdArgs} 2>&1 | tee ${MOUNT}/${TASK_CALL_NAME}.log"
  docker exec ${containerName} ${cmdArgs} 2>&1 | tee ${MOUNT}/${TASK_CALL_NAME}.log
}

function push_2_remote() {
   local datafile=$1
   echo "scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/"
   ##scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/${uid}_${savedResults}.tar.gz
   scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/$(date -u +"%m_%d_%Y_%H_%M_%S")_${savedResults}.tar.gz
}

######## main entry
arg_count=2
if [[ "$#" -ne ${arg_count} ]]; then
    print_error "Invalid arguments: expecting ${arg_count}, actually passed: $#"
    exit 1
fi

######## collect args
trainData="$1"
testData="$2"

test_data_file_name=$( basename ${testData} )
changed_name=$(echo ${test_data_file_name} | tr '.' '_' )
savedResults=${changed_name}_${savedResults}

##print_info "Processing Started: ${test_data_file_name}"
##print_env
pre_run
##time run_docker
time exec_docker
push_2_remote "${MOUNT}/${savedResults}.tar.gz"  >> ${MOUNT}/${TASK_CALL_NAME}.log 2>&1

##print_info "Processing Completed: ${test_data_file_name}"