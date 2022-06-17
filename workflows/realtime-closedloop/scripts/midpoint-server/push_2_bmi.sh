#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

LOCKDIR=/tmp/synergy/bmi_transfer_lock
root_dir=/mnt/drive0/synergyfernsync/synergy_process

cd ${root_dir}
source ./app_settings.sh

LOG_FILE=/mnt/drive0/synergyfernsync/synergy_process/logs/push_2_bmi_$(date -u +"%Y_%m_%d").log

#### Configurations
MAX_NUM=7
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

function copy_and_backup() {
    local file=$1
    local log_file=$2
    local nameonly=$( basename "${file}" )
    local mylock=$( dirname ${LOCKDIR} )/"${nameonly%.*}"_lock
    mkdir "${mylock}" || (print_info "Failed to lock ${mylock}..."; return 1; )
    scp_2_bmi "$file" >> "${log_file}" 2>&1
    move_2_completed "$file" >> "${log_file}" 2>&1
    rmdir "${mylock}" || ( print_info "Failed to  remove lock ${mylock}" >&2; )
}

function exec_main_v1() {
    local workdir=${root_dir}/DATA_TO_BMI
    cd ${workdir}
    
    local actnum=$( find . -type f -name '*.dcm' | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && print_info "No dicom files available, skip this run" && return 0

    local files="$( find . -type f -name '*.dcm' | sort | head -n $MAX_NUM )"
    print_info "transfer files: ${files}"
    for FILE in $files
    do 
        copy_and_backup "${FILE}" "${LOG_FILE}" &
    done
}
function scp_2_bmi() {
    local file=$1
    print_info "scp $file $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$REMOTE_RECEIVING_DIR/"
    scp "$file" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_RECEIVING_DIR"/
}

function move_2_completed() {
    local complete_dir=${root_dir}/DATA_PUSH_COMPLETED
    local file=$1
    local dir=$( dirname $file )
    dir=${dir#"./"}
    complete_dir=${complete_dir}/$dir
    mkdir -p ${complete_dir}
    print_info "mv $file $complete_dir/"
    mv "$file" "$complete_dir"/
}

function file_copy_check() {
  local file=$1

  local oldsize=$(wc -c <"$file")
  print_info "oldsize=$oldsize"
  sleep 1
  local newsize=$(wc -c <"$file")
  print_info "newsize=$newsize"

  while [ "$oldsize" -lt "$newsize" ]
  do
     print_info "$file growing, still copying ..."
     oldsize=$(wc -c <"$file")
     sleep 1
     newsize=$(wc -c <"$file")
  done

  if [ "$oldsize" -eq "$newsize" ]
  then
     print_info "The copying is done for file: $file!"
  fi

}

function start_loop() {
  for i in {1..55}
  do
    exec_main_v1
    sleep 1
  done
}

function start_main() {
    mkdir ${LOCKDIR} || (print_info "Failed to mkdir ${LOCKDIR}..."; exit 1; )
    start_loop
    rmdir $LOCKDIR || ( print_info "Failed to  remove lock dir $LOCKDIR" >&2; )
}

#### Main starts

start_main
