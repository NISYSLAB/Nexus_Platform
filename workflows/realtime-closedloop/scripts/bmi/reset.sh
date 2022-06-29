#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

file=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/processed_extractions.csv
echo "Remove $file"
rm -rf $file
echo ""

file=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/csv/*.csv
echo "Remove $file"
rm -rf $file
echo ""

LOCKDIR=/tmp/synergy/extraction_lock
rm -rf  $(dirname ${LOCKDIR} )/*lock
echo "Under LOCKDIR: $LOCKDIR"
ls $(dirname ${LOCKDIR} )/

