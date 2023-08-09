#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh
## TODO: put these in a config file and make things automatic
COMP1_NAME="rtpreprocess"
COMP2_NAME="bayes_opt_simple"

#### functions
function cleanup() {
  docker stop "${CONTAINER_NAME_WORKFLOW}" || (echo "${CONTAINER_NAME_WORKFLOW} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME_WORKFLOW}" || (echo "${CONTAINER_NAME_WORKFLOW} not existing or running ...")
}

function create_container() {
  local HOST_MOUNT="${PWD}/mount_${COMP_NAME}"
  local DISK_MOUNTS="${HOST_MOUNT}"
  local CONTAINER_MOUNT="/$( basename ${HOST_MOUNT} )"
  local TASK_CALL_NAME="wf-rt-closedloop-2comp-${CONTAINER_NAME_WORKFLOW}"
  local IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${CONTAINER_NAME}:${IMAGE_TAG}
  echo "Creating container: ${CONTAINER_NAME_WORKFLOW}"
  ## mkdir -p ${HOST_MOUNT}/rt_prepro
  ## chmod -R a+rw ${HOST_MOUNT}/rt_prepro
  docker run --entrypoint /bin/bash \
        -v "${HOST_MOUNT}/":${CONTAINER_MOUNT}/ \
        --name ${CONTAINER_NAME_WORKFLOW}  \
        -e "DISK_MOUNTS=${DISK_MOUNTS}" \
        -e TASK_CALL_NAME=${TASK_CALL_NAME} \
        -e TASK_CALL_ATTEMPT=1 \
        -e containerName=${CONTAINER_NAME_WORKFLOW} \
        -itd "${IMAGE}"
}

function cleanup_and_create(){
  cleanup 
  create_container 
}

#### Main starts
cleanup 
source ./container_settings_${COMP1_NAME}.sh
time cleanup_and_create
source ./container_settings_${COMP2_NAME}.sh
time cleanup_and_create
sleep 2
docker ps -a

# echo "Home directory..."
# docker exec "${CONTAINER_NAME}" pwd
# echo ""

# echo "Files in ${CONTAINER_HOME}..."
# docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_HOME}/"
# echo ""

# echo "Files in ${CONTAINER_MOUNT}"
# docker exec "${CONTAINER_NAME}" bash -c "ls ${CONTAINER_MOUNT}/"
# echo ""
