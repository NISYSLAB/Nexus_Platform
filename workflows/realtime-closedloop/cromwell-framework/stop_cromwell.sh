#!/bin/bash

source ./common_settings.sh

function kill_previous_pid() {
  process_id=$(ps -eaf | grep java | grep jar | grep "cromwell-" |head -n 1 | awk '{print $2}')
  echo "There is cromwell instance running, process_id=${process_id}, kill it"
  echo "kill -9 ${process_id}"
  kill -9 ${process_id}

}

###########################################################################
clear
kill_previous_pid
