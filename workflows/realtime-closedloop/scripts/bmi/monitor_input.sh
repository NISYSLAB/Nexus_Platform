#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### configurations
MONITORING_DIR=/labs/mahmoudilab/synergy_remote_data1/rtcl_data_in_dir
##MONITORING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir
PROCESSED_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed
EXE_ENTRY_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
LOG_DIR=/labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow
MAX_PER_RUN=1
MAX_PROC=1
SUBMISSION_SCRIPT=submit_non_cromwell.sh

IN_PROCESS=N
LOCK_FILE=${PROCESSED_DIR}/rtcl_proc.lock

#### functions
function get_uid() {
    echo "$( date +'%m-%d-%Y-%H-%M-%S' )_$((1000 + RANDOM % 9999))"
}

function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function file_copy_check() {
  local file=$1
  print_info "file_copy_check: $file"
  local oldsize=$( wc -c <"$file" | awk '{print $1}' )
  print_info "oldsize=$oldsize"
  sleep 1
  local newsize=$( wc -c <"$file" | awk '{print $1}' )
  print_info "newsize=$newsize"

  while [[ "$oldsize" -lt "$newsize" ]]
  do
     print_info "$file growing, still copying ..."
     oldsize=$( wc -c <"$file" | awk '{print $1}' )
     sleep 1
     newsize=$( wc -c <"$file" | awk '{print $1}' )
  done

  if [ "$oldsize" -eq "$newsize" ]
  then
     print_info "The copying is done for file: $file!"
  fi
}

function exec_main() {
    local procnum=$( ps -eaf | grep submit_non_cromwell | wc -l | xargs )
    [[ "$procnum" -gt $MAX_PROC ]]  && return 0
    ##[[ "$procnum" -gt $MAX_PROC ]] && print_info "Reach max running processes, wait and skip this run" && return 0

    local actnum=$( find "${MONITORING_DIR}" -type f -name '*.*'  | wc -l | xargs )
    ##local actnum=$( ls ${MONITORING_DIR}/*.* | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && return 0
    ##[[ "$actnum" -eq 0 ]] && print_info "No files available in folder: ${MONITORING_DIR}, skip this run" && return 0

    ## double check
    procnum=$( ps -eaf | grep submit_non_cromwell | wc -l | xargs )
    [[ "$procnum" -gt $MAX_PROC ]]  && return 0

    uuid=$( get_uid )
    [[ "$MAX_PROC" == 1 ]] && uuid="single-thread"
    tmplist=${PROCESSED_DIR}/${uuid}
    mkdir -p ${tmplist}
    cd ${MONITORING_DIR}
    ## process a group each time
    local myfile=$( ls -rt | head -n 1 )
    local nameonly=$( basename "$myfile" )
    file_copy_check ${myfile}
    mv ${myfile} ${tmplist}/${nameonly} || return 0

    cd $EXE_ENTRY_DIR
    local cmd="./${SUBMISSION_SCRIPT} ${tmplist}/${nameonly}"
    log=${LOG_DIR}/submission_${uuid}.log
    if [[ "$MAX_PROC" == 1 ]]; then
        log=${LOG_DIR}/submission_${uuid}_$( date +'%m-%d-%Y' ).log
        print_info "${cmd} >> ${log}  2>&1"
        ${cmd} >> ${log} 2>&1
    else
         print_info "${cmd} > ${log}  2>&1 &"
         ${cmd} > ${log} 2>&1 &
    fi
}

function exec_main_single_thread() {
    single_instance

    local actnum=$( find "${MONITORING_DIR}" -type f -name '*.*'  | wc -l | xargs )
    ##local actnum=$( ls ${MONITORING_DIR}/*.* | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && return 0
    ##[[ "$actnum" -eq 0 ]] && print_info "No files available in folder: ${MONITORING_DIR}, skip this run" && return 0

    uuid="single-thread"
    tmplist=${PROCESSED_DIR}/${uuid}/$(get_uid)
    log=${LOG_DIR}/submission_${uuid}_$( date +'%m-%d-%Y' ).log
    mkdir -p ${tmplist}
    mv ${MONITORING_DIR}/*.* ${tmplist}/ || return 0

    cd $EXE_ENTRY_DIR
    echo "Y" > $LOCK_FILE
    print_info "Set LOCK .............................."
    print_info "Files under ${tmplist}/ "
    ls ${tmplist}/
    for FILE in $( ls -rt ${tmplist}/*.*)
    do
      ##print_info "Submit $FILE"
      ##echo "Y" > $LOCK_FILE
      local cmd="./${SUBMISSION_SCRIPT} ${FILE}"
      print_info "${cmd} >> ${log}  2>&1"
      ${cmd} >> ${log} 2>&1
    done
    echo "N"> $LOCK_FILE
    print_info "Release LOCK ............................"
}

function single_instance() {
    # Check if another instance of this script is running
    pidof -o %PPID -x $0 >/dev/null && print_info "Script $0 already running, skip this run" && return 0

    ##IN_PROCESS=$( cat $LOCK_FILE )
    ##[[ $IN_PROCESS == "Y" ]]  && exit 0

    local procnum=$( ps -eaf | grep submit_non_cromwell | wc -l | xargs )
    [[ "$procnum" -gt $MAX_PROC ]]  && return 0
    ##[[ "$procnum" -gt $MAX_PROC ]] && print_info "Reach max running processes, wait and skip this run" && return 0
}

#### Main starts
test -f $LOCK_FILE || touch $LOCK_FILE
IN_PROCESS=$( cat $LOCK_FILE )
cd "$SCRIPT_DIR"
for i in {1..30}
do
  ##print_info "loop: $i"
  ##exec_main
  exec_main_single_thread
  sleep 2
done
