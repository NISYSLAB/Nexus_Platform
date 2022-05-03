#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEST_VM=${BMI_SYNERGY_1_VM}
EXE_SCRIPT=./zip_local.sh
LOCAL_DIR=/Users/anniegu/workspace/Nexus_Platform/workflows/realtime-closedloop/cromwell-framework
REMOTE_DIR=/home/pgu6/app/cromwell
LOCAL_ZIP=local_cromwell-framework.zip
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

function zip_wdl() {
  cd ${LOCAL_DIR}/wdl
  zip -r ${LOCAL_WDL_ZIP} ./*.wdl ./*.json ./*.sh
  local remote_wdl
  scp_to_vm ${LOCAL_DIR}/wdl/${LOCAL_WDL_ZIP} ${REMOTE_WDL_DIR}/${LOCAL_WDL_ZIP} ${DEST_VM}
}

#### Main starts
time zip_local
time scp2_s1
time zip_wdl