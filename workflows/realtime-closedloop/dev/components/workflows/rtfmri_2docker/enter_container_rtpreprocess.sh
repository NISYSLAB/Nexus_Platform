#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./container_settings_rtpreprocess.sh

echo "Enter Pipeline ..."
echo "docker exec -it ${CONTAINER_NAME} /bin/bash"
docker exec -it ${CONTAINER_NAME} /bin/bash