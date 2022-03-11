#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "13973-AB3 /${PASS} TT-;234049"
################################################

function scp_realtime_closedloop_vm() {
  ## get zip from pgu6@synergy1:/home/pgu6/app/listener/fMri_realtime/listener_execution/gra/gra.zip
  scp_from_vm /home/pgu6/app/listener/fMri_realtime/listener_execution/realtime_closedloop.zip ./vm/realtime_closedloop.zip ${SYNERGY_1_VM}

  echo "./vm/gra.zip transferred"
  ls -alt ./vm/realtime_closedloop.zip
}
####

scp_realtime_closedloop_vm

