#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

EXEC_DIR=/Users/Synergy/synergy_process
#### Main start
cd ${EXEC_DIR}
ps -eaf | grep monitor_new_trial.sh | grep bash
process_id=$( ps -eaf | grep monitor_new_trial.sh | grep bash | awk '{print $2}' )
kill -9 ${process_id} || echo "monitor_new_trial.sh is not running, ok to proceed"
sleep 2
./release_lock.sh > /dev/null
./monitor_new_trial.sh > /dev/null 2>&1 &

