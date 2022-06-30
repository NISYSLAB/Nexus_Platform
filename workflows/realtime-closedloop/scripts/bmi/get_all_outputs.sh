#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "csv outputs: "
ls -t /home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/csv/*.csv
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo "saved outputs: "
ls -t /home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/saved_out*.tar.gz
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo "scripts logs:"
ls -t /labs/mahmoudilab/synergy-wf-executions/logs/rt-closedloop/*.log
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo "pipeline logs:"
ls -t /home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/*.log
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - -"

echo ""