#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MIDPOINT_HOST_IP=170.140.32.177
MIDPOINT_USER=synergyfernsync
SRC=/labs/mahmoudilab/synergy_remote_data1/midpointserver/local_midpointserver.zip
DEST=/mnt/drive0/synergyfernsync/synergy_process/
COPY_CMD="scp ${SRC} ${MIDPOINT_USER}@${MIDPOINT_HOST_IP}:${DEST}"
echo "time ${COPY_CMD}"
time ${COPY_CMD}
