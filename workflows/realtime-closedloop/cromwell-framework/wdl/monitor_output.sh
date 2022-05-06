#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### configurations
MONITORING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir
PROCESSED_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed
EXE_ENTRY_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl
LOG_DIR=/labs/mahmoudilab/synergy_remote_data1/logs
CROMWELL_EXEC_DIR=/home/pgu6/app/cromwell/cromwell-executions/wf_realtime_v1
MAX_PER_RUN=1
MAX_PUSH=5
OUTPUT_LOG=${LOG_DIR}/monitor_push_$(date -I).log

## for scp
REMOTE_USER=Synergy
REMOTE_HOST_IP=10.44.80.242
REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/synergy_process/DATA_FROM_BMI

#### functions
function get_uid() {
    echo "$( date +'%m-%d-%Y:%H:%M:%S' )_$((1000 + RANDOM % 9999))"
}

function scp2remote() {
   local src=$1
   local dest=$2
   echo "scp ${src} ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/${dest}"
   scp "${src}" ${REMOTE_USER}@${REMOTE_HOST_IP}:${REMOTE_TASK_RECEIVING_DIR}/"${dest}"
}

function pushAndPostprocess() {
  local pushingfile=$1
  local csvfile=$2
  local shortname=$(basename "${csvfile}" )
  echo "pushingfile=$pushingfile"
  echo "csvfile=$csvfile"
  echo "shortname=$shortname"
  scp2remote "${pushingfile}" "${shortname}" || echo "Failed to push ${pushingfile}" && mv "${pushingfile}" "${csvfile}" && return 1
  mv "${pushingfile}" "${csvfile}.pushed"
  echo "$csvfile pushed, ${csvfile}.pushed "
}

function exec_main() {
    local processnum=$( ps -eaf | grep monitor_output.sh | wc -l | xargs )
    [[ "$processnum" -gt ${MAX_PUSH} ]] && echo "More than ${MAX_PUSH} of processes ${SCRIPT_NAME} are running, skip this run" && return 0

    actnum=$(find  ${CROMWELL_EXEC_DIR} -type f -name '*.csv' -print | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && echo "No csv available in folder: ${CROMWELL_EXEC_DIR}, skip this run" && return 0

    local csvfile=$( find  ${CROMWELL_EXEC_DIR} -type f -name '*.csv' -print | head -n 1 )
    local pushingfile=${csvfile}.pushing
    mv "${csvfile}" "${pushingfile}"
    ## put to background
    ## pushAndPostprocess "${pushingfile}" "${csvfile}" >> ${OUTPUT_LOG} 2>&1 &
    pushAndPostprocess "${pushingfile}" "${csvfile}" >> ${OUTPUT_LOG} 2>&1
}

#### Main starts
## for testing
echo "OUTPUT_LOG=$OUTPUT_LOG"
exec_main >> ${OUTPUT_LOG} 2>&1

exit 0

for i in {1..56}
do
  echo "loop: $i"
  exec_main >> ${OUTPUT_LOG} 2>&1
  sleep 1
done