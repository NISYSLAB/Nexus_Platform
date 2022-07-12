#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

root_dir=/Users/Synergy/synergy_process

cd ${root_dir}
history_log=data_push_history.log

#### Configurations
MAX_NUM=11
MAX_WAIT_SECONDS=10
UUID=$(uuidgen)
TMPDIR=tmp_${UUID}
ZIPFILE=dcm_${UUID}.zip

#### function definition
function get_now() {
  echo $(date -u +"%m/%d/%Y:%H:%M:%S")
}
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function exec_main_v1() {
    local workdir=${root_dir}/DATA_TO_BMI
    cd ${workdir}
    
    local actnum=$( ls *.dcm | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && print_info "No dicom files available, skip this run" && return 0

    local files="$( ls -t *.dcm | head -n $MAX_NUM )"
    for FILE in $files
    do 
        scp_2_bmi $FILE
        move_2_completed $FILE
    done
    echo  "[$( get_now )]: pushed ${files} to BMI" >> ${root_dir}/${history_log}
}

function scp_2_bmi() {
    local file=$1
    ##print_info "scp $file $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$REMOTE_RECEIVING_DIR/"
    scp "$file" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_RECEIVING_DIR"/
}

function log_history() {
    local file=$1
    local now=$(get_now)
    echo "[${now}]: pushed $file to BMI remote" >> "$history_log"
}

function move_2_completed() {
    local complete_dir=${root_dir}/DATA_PUSH_COMPLETED
    local file=$1
    ##print_info "mv $file $complete_dir/"
    mv "$file" "$complete_dir"/
}
function file_copy_check() {
  local file=$1

  local oldsize=$(wc -c <"$file")
  print_info "oldsize=$oldsize"
  sleep 2
  local newsize=$(wc -c <"$file")
  print_info "newsize=$newsize"

  while [ "$oldsize" -lt "$newsize" ]
  do
     print_info "$file growing, still copying ..."
     oldsize=$(wc -c <"$file")
     sleep 2
     newsize=$(wc -c <"$file")
  done

  if [ "$oldsize" -eq "$newsize" ]
  then
     print_info "The copying is done for file: $file!"
  fi

}

#### Main starts
for i in {1..58}
do
  ##print_info "loop: $i"
  exec_main_v1
  sleep 1
done
