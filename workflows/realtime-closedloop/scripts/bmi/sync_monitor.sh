#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
TO_LOG=/labs/mahmoudilab/synergy-wf-executions/logs/rt-closedloop
PROCESS_LOG=/labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop/single-thread
FROM_EXEC=/labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop
TO_EXEC=/labs/mahmoudilab/synergy-wf-executions/runtime/rt-closedloop
LOCKDIR=/tmp/synergy/sync_copy_lock
####
function sync_log() {
    echo "cp ${PROCESS_LOG}/*.log ${TO_LOG}/"
    cp ${PROCESS_LOG}/*.log ${TO_LOG}/
}

function sync_exe() {
   echo "cp -rf ${FROM_EXEC}/* ${TO_EXEC}/"
   cp -rf ${FROM_EXEC}/* ${TO_EXEC}/
}

function remove_old() {
    ## we want to delete files that were modified at least 5 days ago.
    ##find . -name "*.log" -type f -mtime +5
    ##find . -name "access*.log" -type f -mtime +5 -delete

    find ${FROM_EXEC} -type d -ctime +2 -exec rm -rf {} \;
    ## find /path/to/base/dir/* -type d -ctime +10 -exec rm -rf {} \;
}

function start_main() {
   sync_log
   sync_exe
   remove_old
}

#### Main starts
mkdir ${LOCKDIR} || exit 1

for i in {1..10}
do
  start_main
  sleep 5
done
rmdir $LOCKDIR || print_info "Failed to  remove lock dir $LOCKDIR" >&2





