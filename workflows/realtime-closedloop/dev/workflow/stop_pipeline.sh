#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./workflow_common_settings.sh

echo "Stop Pipeline ..."
echo "docker stop ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME}
docker ps -a