#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh

#### function
function kill_scheduler_java_process() {
  process_id=$(ps -eaf | grep ".jar" | grep nexus-scheduler | awk '{print $2}')
  echo "java nexus-scheduler process_id=$process_id"
  kill -9 ${process_id} || echo "java nexus-scheduler does not exist,, OK to move on ..."
}

#### Starts
kill_scheduler_java_process

ps -eaf | grep ".jar" | grep nexus-scheduler
