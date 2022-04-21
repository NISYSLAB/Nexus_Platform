#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
##source ${SCRIPT_DIR}/common_configurations.sh
CONTAINER_NAME=marker-test-container
DOCKER_IMAGE=us.gcr.io/cloudypipelines-com/fmri_biomarker:1.3

function cleanup() {
    docker stop ${CONTAINER_NAME} || (echo "${CONTAINER_NAME} not existing or running ...")
    docker rm -f -v ${CONTAINER_NAME}|| (echo "${CONTAINER_NAME} not existing or running ...")

}


function run_docker() {
    docker run -d \
    --name ${CONTAINER_NAME}  \
    -v $PWD/test/:/root/work/test \
    -v $PWD/train/:/root/work/train \
    -v $PWD/trained_model/:/root/work/trained_model \
    -t ${DOCKER_IMAGE}
}

cleanup
run_docker

sleep 2
docker ps
echo "Enter container: ${CONTAINER_NAME}"
docker exec -it ${CONTAINER_NAME} /bin/sh
