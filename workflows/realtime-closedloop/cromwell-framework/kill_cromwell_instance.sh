#!/bin/bash

source ./common_settings.sh

function kill_previous_pid() {
  process_id=$(ps -eaf | grep java | grep server | grep "cromwell-" |grep " -jar " |head -n 1 | awk '{print $2}')
  echo "There is cromwell instance running, process_id=${process_id}, kill it"
  echo "kill -9 ${process_id}"
  kill -9 ${process_id}

}

#### start
ps -eaf |grep java |grep jar |grep cromw
sleep 2
echo "Make sure kill cromwell instance!!!"
kill_previous_pid
sleep 3
ps -eaf |grep jar |grep java |grep cromwell
