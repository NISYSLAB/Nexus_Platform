#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./app_settings.sh

#### Start

if [ "$#" -ne 1 ]; then
    echo "./${SCRIPT_NAME} file"
    echo "./${SCRIPT_NAME} /tmp/test.txt"
    exit
fi

datafile=$1

scp ${datafile} ${USER}@${HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/
