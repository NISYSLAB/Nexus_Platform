#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

TASK_HOST_IP=170.140.61.150
TASK_USER=Synergy
SRC=/labs/mahmoudilab/synergy_remote_data1/taskserver/local_taskserver.zip
DEST=/Users/Synergy/synergy_process/
COPY_CMD="scp ${SRC} ${TASK_USER}@${TASK_HOST_IP}:${DEST}"
echo "time ${COPY_CMD}"
time ${COPY_CMD}
