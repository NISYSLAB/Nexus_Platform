#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh

#### global settings
IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_NAME=realtime-closedloop-${PROFILE}

echo "Stop Pipeline ..."
echo "docker stop ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME}