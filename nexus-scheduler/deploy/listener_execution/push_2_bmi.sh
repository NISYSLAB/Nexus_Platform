#!/bin/bash

## this is cron job running at Task server
## ## run every minute
#* * * * * cd /Users/Synergy/synergy_process && ./push_2_bmi.sh > /dev/null 2>&1

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
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
function log_history() {
    local file=$1
    local now=$(get_now)
    echo "[$now]: pushing file: $file to BMI remote" >> "$history_log"
}

function move_2_completed() {
    local file=$1
    mv "$file" "$LOCAL_DATA_PUSH_COMPLETED_DIR"/
}

function exec_main() {
    ##cd "$SCRIPT_DIR"
    for entry in "$LOCAL_DATA_PUSH_DIR"/*.*
    do
      echo "Pushing "$entry" to BMI remote"
      log_history "$entry"
      scp_2_bmi "$entry"
      move_2_completed "$entry"
    done

    echo "####################################" >> "$history_log"
}

####
for i in {1..58}
do
  echo "loop: $i"
  exec_main
  sleep 1
done
