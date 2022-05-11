#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### configurations
MONITORING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir
PROCESSED_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed
EXE_ENTRY_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
LOG_DIR=/labs/mahmoudilab/synergy_remote_data1/logs
MAX_PER_RUN=1
MAX_PROC=10
SUBMISSION_SCRIPT=submit_non_cromwell.sh

#### functions
function get_uid() {
    echo "$( date +'%m-%d-%Y:%H:%M:%S' )_$((1000 + RANDOM % 9999))"
}

function exec_main() {
    local actnum=$( ls ${MONITORING_DIR}/*.* | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && echo "No files available in folder: ${MONITORING_DIR}, skip this run" && return 0

    local procnum=$( ps -eaf | grep submit_non_cromwell | wc -l | xargs )
    [[ "$procnum" -gt $MAX_PROC ]] && echo "Reach max running processes, wait and skip this run" && return 0

    uuid=$( get_uid )
    tmplist=${PROCESSED_DIR}/${uuid}
    mkdir -p ${tmplist}
    cd ${MONITORING_DIR}
    ## process a group each time
    local myfile=$( ls -rt | head -n 1 )
    local nameonly=$( basename "$myfile" )
    mv ${myfile} ${tmplist}/${nameonly}

    cd $EXE_ENTRY_DIR
    log=${LOG_DIR}/${uuid}_job.log
    local cmd="./${SUBMISSION_SCRIPT} ${tmplist}/${nameonly}"
    echo "${cmd} > ${log}  2>&1 &"
    ${cmd} > ${log} 2>&1 &
}

#### Main starts
for i in {1..56}
do
  echo "loop: $i"
  exec_main
  sleep 1
done