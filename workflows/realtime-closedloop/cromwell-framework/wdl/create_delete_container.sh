#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
CONTAINER_NAME=rtloop-test
IMAGE=us.gcr.io/cloudypipelines-com/closedloop-preprocess-tools:matlab-1.1

#### functions
function run_docker() {
    docker run -d \
     -v $PWD/dicom/:/app/dicom/ \
     --name ${CONTAINER_NAME}  \
     -t ${IMAGE}
}

function delete_docker() {
    docker stop ${CONTAINER_NAME}
    docker rm -f -v ${CONTAINER_NAME}
}

## Main starts
echo "---------------------------------------------"
echo "Create container "
time run_docker
echo "---------------------------------------------"
echo "Delete container"
time delete_docker
echo "---------------------------------------------"
echo ""