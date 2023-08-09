#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

file=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/processed_extractions.csv
echo "Remove $file"
rm -rf $file
echo ""

COMP_NAME=bayes_opt_simple
source ./container_settings_${COMP_NAME}.sh
source ./${COMP_NAME}_SETTINGS.conf
file=./mount_${COMP_NAME}/${TASK_CALL_NAME}/single-thread/csv/*.csv
echo "Remove $file"
rm -rf $file
echo ""
