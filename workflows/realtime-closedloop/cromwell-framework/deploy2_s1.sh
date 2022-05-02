#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEST_VM=${BMI_SYNERGY_1_VM}
EXE_SCRIPT=./zip_local.sh
LOCAL_DIR=/Users/anniegu/workspace/Nexus_Platform/workflows/realtime-closedloop/cromwell-framework
REMOTE_DIR=/home/pgu6/app/cromwell
LOCAL_ZIP=local_cromwell-framework.zip

#### functions
function zip_local() {
    cd ${LOCAL_DIR}
    zip -r $LOCAL_ZIP ./*.sh
}

function scp2_s1() {
  scp_to_vm ${LOCAL_DIR}/${LOCAL_ZIP} ${REMOTE_DIR}/${LOCAL_ZIP} ${DEST_VM}
}

#### Main starts
time zip_local
time scp2_s1