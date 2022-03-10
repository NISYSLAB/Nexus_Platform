#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "13973-AB3 /${PASS} TT-;234049"
################################################

## get zip from /labs/mahmoudilab/slurm-jobs/synergy/dan_fsl
scp_from_vm /labs/mahmoudilab/slurm-jobs/synergy/dan_fsl/dan_fsl.zip ./dan_fsl.zip ${SYNERGY_2_VM}