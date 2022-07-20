#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
IMAGE=gcr.io/cloudypipelines-com/rt-closedloop:2.1
CONTAINER_NAME=realtime-closedloop-prod

MOUNT=/labs/mahmoudilab/synergy_rtcl_app/mount
CONTAINER_MOUNT=/mount
CONTAINER_HOME=/home/pgu6/realtime-closedloop
DISK_MOUNTS="${MOUNT}"
TASK_CALL_NAME=wf-rt-closedloop

#### functions
function cleanup() {
  echo "docker stop ${CONTAINER_NAME}"
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")

  echo "docker rm -f -v ${CONTAINER_NAME}"
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}

function create_container() {
  echo "Creating container: ${CONTAINER_NAME}"
  docker run --entrypoint /bin/bash \
        -p 9666:8080 \
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
echo "- - - - - - - - - - - - - - - - - - - "
docker ps -a
echo "- - - - - - - - - - - - - - - - - - - "
echo "Home directory"
docker exec "${CONTAINER_NAME}" pwd
echo "- - - - - - - - - - - - - - - - - - - "

echo "Files in ${CONTAINER_HOME}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_HOME}/"
echo "- - - - - - - - - - - - - - - - - - - "

echo "Files in ${CONTAINER_MOUNT}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_MOUNT}/"
echo "- - - - - - - - - - - - - - - - - - - "
