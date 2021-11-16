#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

######## Env
IMAGE_NAME=fmri_biomarker
IMAGE_TAG=1.3

GCR_PATH=cloudypipelines-com
CONTAINER_REGISTRY=gcr.io
docker_image=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
execScript=$HOME/workspace/Nexus_Platform/workflows/fMRI_Biomarker/script/run_model_training.sh

uid=$((1 + $RANDOM % 5000))
containerName="train_fmri_biomarker_${uid}"
MOUNT=$PWD/"mount_train_${uid}"

version=1
trainedModelOutputs="trained_model"
savedResults="trained_model_saved_results"

TASK_CALL_NAME=modelTraining
WORKFLOW_ID=$(uuidgen)
COPY_RESULTS=Y

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
    print_info "mkdir -p ${MOUNT}"
    mkdir -p ${MOUNT}
    print_info "cp ${execScript} ${MOUNT}/run_model_training.sh"
    cp  ${execScript} ${MOUNT}/run_model_training.sh

    print_info "cp ${trainData} ${MOUNT}/train_data.tar.gz"
    cp ${trainData} ${MOUNT}/train_data.tar.gz

    print_info "cp ${testData} ${MOUNT}/test_data.tar.gz"
    cp ${testData} ${MOUNT}/test_data.tar.gz
}

function cleanup() {
  print_info "stop ${containerName}"
  docker stop ${containerName} || echo "failed: docker stop ${containerName}. Ignore ..."
  print_info "docker rm -force ${containerName}"
  docker rm --force ${containerName} || echo "failed: docker rm --force ${containerName} . Ignore ..."
}

function run_docker() {
  local cmdArgs="${MOUNT}/run_model_training.sh ${MOUNT}/train_data.tar.gz ${MOUNT}/test_data.tar.gz ${version} ${trainedModelOutputs} ${savedResults}"
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

######## main entry
arg_count=2
if [[ "$#" -ne ${arg_count} ]]; then
    print_error "Invalid arguments: expecting ${arg_count}, actually passed: $#"
    exit 1
fi

######## collect args
trainData="$1"
testData="$2"

print_env
pre_run
time run_docker
cleanup


