#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

TASK_HOST_IP=170.140.61.150
TASK_USER=Synergy

echo "234RT12  ${PASS} / 138Dept%%22"

time scp /labs/mahmoudilab/synergy_remote_data1/taskserver/local_taskserver.zip ${TASK_USER}@${TASK_HOST_IP}:/Users/Synergy/synergy_process/