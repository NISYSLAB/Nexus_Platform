#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/conversion_configurations.sh

function cleanup() {
    docker stop ${CONTAINER_NAME} || (echo "${CONTAINER_NAME} not existing or running ...")
    docker rm -f -v ${CONTAINER_NAME}|| (echo "${CONTAINER_NAME} not existing or running ...")

}

function run_docker() {
    docker run -d \
     -v $PWD/dicom/:/app/dicom/ \
     -v $PWD/niftidir/:/app/niftidir/ \
     --name ${CONTAINER_NAME}  \
     -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${PYTHON_IMAGE_NAME}:${PYTHON_IMAGE_TAG}
}

cleanup
run_docker

sleep 2
docker ps
echo "Enter container: ${CONTAINER_NAME}"
echo "run: ./dcm2niix -o /app/niftidir -f D4_dcm2nii /app/dicom"
docker exec -it ${CONTAINER_NAME} /bin/bash
