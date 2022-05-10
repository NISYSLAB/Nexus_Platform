#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEST_VM=${BMI_SYNERGY_1_VM}
EXE_SCRIPT=./zip_local.sh
LOCAL_DIR=/Users/anniegu/workspace/Nexus_Platform/workflows/realtime-closedloop/non-cromwell
REMOTE_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
LOCAL_ZIP=local_non-wdl.zip
LOCAL_WDL_ZIP=local_wdl.zip
REMOTE_WDL_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl

#### functions
function zip_local() {
    cd ${LOCAL_DIR}
    rm -rf $LOCAL_ZIP
    zip -r $LOCAL_ZIP ./*.sh -x ./deploy2_s1.sh -x zip_remote.sh -x download_s1.sh
}

function scp2_s1() {
  scp_to_vm ${LOCAL_DIR}/${LOCAL_ZIP} ${REMOTE_DIR}/${LOCAL_ZIP} ${DEST_VM}
}

#### Main starts
time zip_local
time scp2_s1
