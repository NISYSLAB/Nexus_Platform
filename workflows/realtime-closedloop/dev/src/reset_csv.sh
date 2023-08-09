#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

file=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/processed_extractions.csv
echo "Remove $file"
rm -rf $file
echo ""

file=/home/yzhu382/dev-synergy-rtcl-app/workflow/mount/wf-rt-closedloop/single-thread/csv/*.csv
echo "Remove $file"
rm -rf $file
echo ""
