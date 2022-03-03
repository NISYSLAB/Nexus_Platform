#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd /home/pgu6/synergy_process
source ./app_settings.sh
history_log=data_push_history.log

#### function definition
function get_now() {
  echo $(date -u +"%m/%d/%Y:%H:%M:%S")
}

function scp_2_bmi() {
    local file=$1
    scp "$file" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_RECEIVING_DIR"/
}

function log_history() {
    local file=$1
    local now=$(get_now)
    echo "[$now]: pushing file: $file to BMI remote" >> "$history_log"
}

function move_2_completed() {
    local file=$1
    mv "$file" "$LOCAL_DATA_PUSH_COMPLETED_DIR"/
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

function exec_main() {
    ##cd "$SCRIPT_DIR"
    for entry in "$LOCAL_DATA_PUSH_DIR"/*.*
    do
      file_copy_check "$entry"
      scp_2_bmi "$entry"
      log_history "$entry"
      move_2_completed "$entry"
    done

    echo "####################################" >> "$history_log"
}

#### Main starts
exec_main
