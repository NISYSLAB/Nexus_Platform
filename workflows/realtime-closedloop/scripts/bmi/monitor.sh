#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

EXEC_DIR=/labs/mahmoudilab/synergy_rtcl_app
#### Main start
cd ${EXEC_DIR}
ps -eaf | grep extraction_monitor.sh | grep bash
process_id=$( ps -eaf | grep extraction_monitor.sh | grep bash | awk '{print $2}' )
kill -9 ${process_id} || echo "extraction_monitor.sh is not running, ok to proceed"
sleep 2
./release_lock.sh > /dev/null
./extraction_monitor.sh > /dev/null 2>&1 &

