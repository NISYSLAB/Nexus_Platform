#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

################################################

function scp_realtime_closedloop_vm() {
  ## get zip from pgu6@synergy1:/home/pgu6/app/listener/fMri_realtime/listener_execution/gra/gra.zip
  scp_from_vm /home/pgu6/app/listener/fMri_realtime/listener_execution/realtime_closedloop.zip ./vm/realtime_closedloop.zip ${SYNERGY_1_VM}

  echo "./vm/gra.zip transferred"
  ls -alt ./vm/realtime_closedloop.zip
}

function scp_mahmoudimatlab_realtime_closedloop() {
  local SRC=/home/pgu6/realtime-closedloop/remote_mahmoudimatlab_realtime-closedloop.zip
  local DEST=$PWD
  local REMOTE_VM=${BMI_MATLAB_SYNERGY_VM}

  scp_from_vm ${SRC} ${DEST} ${REMOTE_VM}
}

function exec_remote_zip_cmd() {
  local REMOTE_VM=${BMI_MATLAB_SYNERGY_VM}
  local EXEC_SCRIPT=$PWD/get_zip.sh
  exec_on_vm ${REMOTE_VM} ${EXEC_SCRIPT}
}
####
exec_remote_zip_cmd
scp_mahmoudimatlab_realtime_closedloop
##scp_realtime_closedloop_vm

