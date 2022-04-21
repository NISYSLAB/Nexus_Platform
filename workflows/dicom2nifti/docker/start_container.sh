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
     --name ${CONTAINER_NAME}  \
     -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${PYTHON_IMAGE_NAME}:${PYTHON_IMAGE_TAG}
}

cleanup
run_docker

sleep 2
docker ps
echo "Enter container: ${CONTAINER_NAME}"
echo "run: python dicom_pypreprocess.py --filepath /app/dicom --savepath /app/nii"
docker exec -it ${CONTAINER_NAME} /bin/bash
