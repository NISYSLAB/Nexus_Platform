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
LOCK_FILE=/tmp/synergy/pipeline_lock
LOCKDIR=/tmp/synergy/singleton_lock

#### functions
function get_uid() {
    echo "$( date +'%Y-%m-%d-%H-%M-%S' )_$((1000 + RANDOM % 9999))"
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
    uuid="single-thread"
    tmplist=${PROCESSED_DIR}/${uuid}/$(get_uid)
    log=${LOG_DIR}/submission_${uuid}_$( date +'%Y-%m-%d' ).log
    mkdir -p ${tmplist}
    mv ${dicom_input} ${tmplist}/${dicom_input_nameonly}

    cd $EXE_ENTRY_DIR
    print_info "Files under ${tmplist}/ "
    ls ${tmplist}/

    local cmd="./${SUBMISSION_SCRIPT} ${tmplist}/${dicom_input_nameonly}"
    print_info "${cmd} >> ${log}  2>&1"
    ${cmd} >> ${log} 2>&1
}

#### Main starts
msg="Calling: ${SCRIPT_NAME} $@"
print_info "$msg"
dicom_input=$1
dicom_input_nameonly=$( basename "$dicom_input" )
exec_main_single_thread

