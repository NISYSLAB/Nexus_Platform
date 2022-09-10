#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./monitor_common_settings.sh

function kill_monitor_instance() {
    echo "ps -eaf | grep rtcl-directory-monitor-DEV | grep java | grep jar"
    ps -eaf | grep rtcl-directory-monitor-DEV | grep java | grep jar
    process_id=$( ps -eaf | grep rtcl-directory-monitor-DEV | grep java | grep jar | awk '{print $2}' )
    echo "current  monitor instance process_id=$process_id"
    [[ ! -z "$process_id" ]] && echo "process_id Not empty, kill it" && kill -9 "${process_id}"
}

#### Main starts
mkdir -p "${execution_folder}"
kill_monitor_instance
java -jar "${MONITOR_APP_JAR}" > "${MONITOR_APP_LOG}" 2>&1 &
echo "LOG: ${MONITOR_APP_LOG}"
