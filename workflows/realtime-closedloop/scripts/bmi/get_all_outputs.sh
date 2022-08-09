#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "csv outputs: "
ls -t /labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop/single-thread/csv/*.csv
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo "saved outputs: "
ls -t /labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop/single-thread/saved_out*.tar.gz
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo "monitor logs:"
ls -t /labs/mahmoudilab/synergy_remote_data1/logs/rtcl-directory-monitor*.log
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo "pipeline process logs:"
ls -t /labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop/single-thread/*.log
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo ""

