#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./src_common_settings.sh

#### global settings
IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_NAME=realtime-closedloop-TEST

MOUNT=${PWD}/data_mount
CONTAINER_MOUNT=/data_mount
CONTAINER_HOME=/synergy-rtcl-app
EXEC_SCRIPT=exec_one.sh
DISK_MOUNTS="${MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function cleanup() {
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}

function create_container() {
  echo "Creating container: ${CONTAINER_NAME}"
  docker run --entrypoint /bin/bash \
        -v "${MOUNT}/":${CONTAINER_MOUNT}/ \
        --name ${CONTAINER_NAME}  \
        -e "DISK_MOUNTS=${DISK_MOUNTS}" \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${CONTAINER_NAME} \
        -itd "${IMAGE}"
}

function prep() {
    mkdir -p "${MOUNT}"
    mkdir -p ${MOUNT}/${TASK_CALL_NAME}
}

#### Main starts
cleanup
prep
time create_container
sleep 2
docker ps -a

echo "Home directory"
docker exec "${CONTAINER_NAME}" pwd

echo "Files in ${CONTAINER_HOME}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_HOME}/"

echo "Files in ${CONTAINER_MOUNT}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_MOUNT}/"
