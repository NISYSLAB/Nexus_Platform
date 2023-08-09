#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh

DISK_MOUNTS="${HOST_MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function cleanup() {
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}

function create_container() {
  echo "Creating container: ${CONTAINER_NAME}"
  ## mkdir -p ${HOST_MOUNT}/rt_prepro
  ## chmod -R a+rw ${HOST_MOUNT}/rt_prepro
  docker run --entrypoint /bin/bash \
        -v "${HOST_MOUNT}/":${CONTAINER_MOUNT}/ \
        -v "/home/yzhu382/dev-synergy-rtcl-app/src/rt_prepro":/home/yzhu382/dev-synergy-rtcl-app/src/rt_prepro \
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

echo "Files in ${CONTAINER_MOUNT}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_MOUNT}/"
echo ""
