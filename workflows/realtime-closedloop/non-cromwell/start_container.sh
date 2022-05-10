#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
IMAGE=us.gcr.io/cloudypipelines-com/closedloop-preprocess-tools:matlab-1.1
CONTAINER_NAME=realtime-closedloop-prod

MOUNT=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount
CONTAINER_HOME=/home/pgu6/realtime-closedloop
execScript=exec_one.sh
DISK_MOUNTS="${MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function cleanup() {
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}

function create_container() {
  echo "Creating container: ${CONTAINER_NAME}"
  docker create -t \
        -v "${MOUNT}":${CONTAINER_HOME}/ \
        --name ${CONTAINER_NAME}  \
        -e "DISK_MOUNTS=${DISK_MOUNTS}" \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${container_full_name} \
        "${IMAGE}"

    echo "Starting container: ${CONTAINER_NAME}"
    docker start "${CONTAINER_NAME}"
}

function prep() {
    mkdir -p "${MOUNT}"
    mkdir -p ${MOUNT}/${TASK_CALL_NAME}
}

function delete_docker() {
    docker stop ${CONTAINER_NAME}
    docker rm -f -v ${CONTAINER_NAME}
}

#### Main starts
cleanup
prep
create_container
echo "docker exec ${container_full_name} pwd"
docker exec "${container_full_name}" pwd
docker exec "${container_full_name}" bash -c "ls ${CONTAINER_HOME}/"
