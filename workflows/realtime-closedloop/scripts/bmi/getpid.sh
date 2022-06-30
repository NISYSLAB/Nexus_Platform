#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

EXEC_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
#### Main start
cd ${EXEC_DIR}
echo "ps -eaf | grep extraction_monitor.sh | grep bash"
ps -eaf | grep extraction_monitor.sh | grep bash
process_id=$( ps -eaf | grep extraction_monitor.sh | grep bash | awk '{print $2}' )
echo "extraction_monitor.sh process_id=$process_id"
