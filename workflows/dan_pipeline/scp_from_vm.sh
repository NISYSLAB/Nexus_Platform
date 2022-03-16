#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "13973-AB3 /${PASS} TT-;234049"
################################################

function scp_dan_fsl_slurm() {
  ## get zip from /labs/mahmoudilab/slurm-jobs/synergy/dan_fsl
  scp_from_vm /labs/mahmoudilab/slurm-jobs/synergy/dan_fsl/dan_fsl.zip ./slurm/dan_fsl.zip ${SYNERGY_2_VM}

  echo "./slurm/dan_fsl.zip transferred"
  ls -alt ./slurm/dan_fsl.zip
}

function scp_dan_fsl_vm() {
  ## get zip from pgu6@synergy1:/home/pgu6/app/listener/fMri_realtime/listener_execution/gra/gra.zip
  scp_from_vm /home/pgu6/app/listener/fMri_realtime/listener_execution/gra/gra.zip ./vm/gra.zip ${SYNERGY_1_VM}

  echo "./vm/gra.zip transferred"
  ls -alt ./vm/gra.zip
}
####

scp_dan_fsl_slurm
scp_dan_fsl_vm

