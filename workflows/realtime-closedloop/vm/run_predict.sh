#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

######## Env
IMAGE_NAME=fmri_biomarker
IMAGE_TAG=1.4
##IMAGE_TAG=1.3

GCR_PATH=cloudypipelines-com
CONTAINER_REGISTRY=gcr.io
docker_image=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
execScript=/home/pgu6/app/listener/fMri_realtime/listener_execution/predict_exec.sh

fmri_biomarker_test_dataset_listener_out_folder="/home/pgu6/app/listener/fMri_realtime/listener_execution/mount_predict/outputs"

uid=$(uuidgen)
containerName="predict_fmri_biomarker"
MOUNT=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount_predict/${uid}
##MOUNT=$PWD/"mount_predict_${uid}"
DISK_MOUNTS=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount_predict

mkdir -p ${MOUNT}
mkdir -p ${DISK_MOUNTS}

version=1
trainedModelOutputs="trained_model"
savedResults="run1"
##savedResults="predict_saved_results"

TASK_CALL_NAME=wf_modelPredict
WORKFLOW_ID=${uid}
COPY_RESULTS=Y

#### for scp results to remote
## followings are FERN connection to BMI cluster for quasi rtfMRI (Michael/Kate) 
##REMOTE_TASK_RECEIVING_DIR=/mnt/drive0/synergyfernsync/synergy_process/DATA_FROM_BMI
##REMOTE_USER=synergyfernsync
##REMOTE_HOST_IP=170.140.32.177

## followings are for Task server
REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/synergy_process/DATA_FROM_BMI
REMOTE_USER=Synergy
REMOTE_HOST_IP=10.44.115.21
##REMOTE_HOST_IP=10.44.92.68

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
        -v ${DISK_MOUNTS}:${DISK_MOUNTS} \
        --name ${containerName}  \
	-e DISK_MOUNTS=${DISK_MOUNTS} \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${containerName} \
        -e WORKFLOW_ID=${WORKFLOW_ID} \
        -e COPY_RESULTS=${COPY_RESULTS} \
        ${docker_image} \
        /bin/bash ${cmdArgs} 2>&1 | tee ${MOUNT}/${TASK_CALL_NAME}.log

}

function filenameonly() {
    local path=$1
    local filename=$(basename -- "$path")
    echo ${filename}
}

function shortname_no_ext() {
    local path=$1
    echo "$(basename "$path" | sed 's/\(.*\)\..*/\1/')"
}

function exec_docker() {
  local cmdArgs="${MOUNT}/predict_exec.sh ${MOUNT}/trained_model.tar.gz ${MOUNT}/${test_data_file_name} ${version} ${trainedModelOutputs} ${savedResults}"
  echo "docker exec ${containerName} ${cmdArgs} 2>&1 | tee ${MOUNT}/${TASK_CALL_NAME}.log"
  docker exec ${containerName} ${cmdArgs} 2>&1 | tee ${MOUNT}/${TASK_CALL_NAME}.log
}

function push_2_remote() {
   local datafile=$1
   echo "scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/${shortname}-$(date -u +'%m_%d_%Y_%H_%M_%S').csv"
   scp ${datafile} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/${shortname}-$(date -u +"%m_%d_%Y_%H_%M_%S").csv
}

function exec_main() {
    pre_run
    exec_docker
    push_2_remote "${fmri_biomarker_test_dataset_listener_out_folder}/${shortname}.csv" 
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
savedResults=${changed_name}_${savedResults}.csv

shortname=$( shortname_no_ext ${testData} )

time exec_main  > ${MOUNT}/${TASK_CALL_NAME}.log 2>&1

