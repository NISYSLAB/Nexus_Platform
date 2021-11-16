#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./app_settings.sh
source ../.ssl/.settings.sh

echo "234RT12- ${TASK_PASS} / 138Dept%%22"
echo "ssh ${TASK_USER}@${TASK_HOST_IP}"
ssh  "${TASK_USER}"@"${TASK_HOST_IP}"