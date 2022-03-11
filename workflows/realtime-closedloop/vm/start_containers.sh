#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function print_usage() {
    echo "Usage: ./${MY_NAME} <numberOfContainers>"
    echo " e.g.: ./${MY_NAME} 2"
}

######## Env
IMAGE_NAME=fmri_biomarker
IMAGE_TAG=1.4
##IMAGE_TAG=1.3

GCR_PATH=cloudypipelines-com
CONTAINER_REGISTRY=gcr.io
docker_image=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
execScript=${predict_exec_script}

containerName="predict_fmri_biomarker"
MOUNT=$PWD/"mount_predict"

version=1
trainedModelOutputs="trained_model"
savedResults="predict_saved_results"

TASK_CALL_NAME=wf_modelPredict
WORKFLOW_ID=$(uuidgen)
COPY_RESULTS=Y

function cleanup() {
    docker stop ${containerName} || echo "failed: docker stop ${containerName}. Ignore ..."
    docker rm --force ${containerName} || echo "failed: docker rm --force ${containerName} . Ignore ..."
}

function create_container() {
  ##docker run --rm -t \
  docker create -t \
        -v ${MOUNT}:${MOUNT} \
        --name ${containerName}  \
	-e DISK_MOUNTS=${MOUNT} \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${containerName} \
        -e COPY_RESULTS=${COPY_RESULTS} \
        ${docker_image} 
}

######## main entry

##if [ $# -lt 1 ]
##then
 ## print_usage
  ##exit 0;
##fi

######## Main starts
container_count=1
##container_count=$1
echo "${container_count} containes will be created"

mkdir -p ${MOUNT}
for (( count=1; count<=${container_count}; count++ ))
do
    ##containerName="predict_fmri_biomarker"_${count}
    ##MOUNT=$PWD/"mount_predit"_${count}
    ##TASK_CALL_NAME=modelPredict_${count}    
    echo "Stop/Remove ${containerName}" 
    cleanup || echo "OK ${containerName} not existing"
    echo "Creating container: ${containerName}"
    create_container
    echo "Start ${containerName}"
    docker start ${containerName}
    echo "docker exec ${containerName} ls"
done

docker ps -a

