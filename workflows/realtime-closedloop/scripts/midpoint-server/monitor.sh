#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

EXEC_DIR=/mnt/drive0/synergyfernsync/synergy_process
#### Main start
cd ${EXEC_DIR}
ps -eaf | grep push_2_bmi.sh | grep bash
process_id=$( ps -eaf | grep push_2_bmi.sh | grep bash | awk '{print $2}' )
kill -9 ${process_id} || echo "push_2_bmi.sh is not running, ok to proceed"
sleep 2
./release_lock.sh > /dev/null
./push_2_bmi.sh > /dev/null 2>&1 &

