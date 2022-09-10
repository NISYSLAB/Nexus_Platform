#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh

#### global settings
IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_NAME=realtime-closedloop-${PROFILE}
CONTAINER_HOME=/synergy-rtcl-app

DATA_MOUNT=${PWD}/data_mount
CONTAINER_DATA_MOUNT=/data_mount

LOG_MOUNT=${PWD}/log_mount
CONTAINER_LOG_MOUNT=/log_mount

PROCESS_MOUNT=${PWD}/process_mount
CONTAINER_PROCESS_MOUNT=/process_mount

EXEC_SCRIPT=exec_one.sh
DISK_MOUNTS="${PROCESS_MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function cleanup() {
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}

function create_container() {
  echo "Creating container: ${CONTAINER_NAME}"
  docker run --entrypoint /bin/bash \
        -v "${DATA_MOUNT}/":${CONTAINER_DATA_MOUNT}/ \
        -v "${LOG_MOUNT}/":${CONTAINER_LOG_MOUNT}/ \
        -v "${PROCESS_MOUNT}/":${CONTAINER_PROCESS_MOUNT}/ \
        --name ${CONTAINER_NAME}  \
        -e "DISK_MOUNTS=${DISK_MOUNTS}" \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${CONTAINER_NAME} \
        -itd "${IMAGE}"
}

#### Main starts
cleanup
time create_container
sleep 2
docker ps -a

echo "Home directory..."
docker exec "${CONTAINER_NAME}" pwd
echo ""

echo "Files in ${CONTAINER_HOME}..."
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_HOME}/"
echo ""

echo "Files in ${CONTAINER_DATA_MOUNT}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_DATA_MOUNT}/"
echo ""
