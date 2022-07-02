#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./common_settings.sh

function kill_monitor_instance() {
    echo "ps -eaf | grep midpoint-directory-monitor | grep java | grep jar"
    ps -eaf | grep midpoint-directory-monitor | grep java | grep jar
    process_id=$( ps -eaf | grep midpoint-directory-monitor | grep java | grep jar | awk '{print $2}' )
    echo "current  monitor instance process_id=$process_id"
    [[ ! -z "$process_id" ]] && echo "process_id Not empty, kill it" && kill -9 "${process_id}"
}

#### Main starts
kill_monitor_instance
java -jar "${APP_JAR}" > "${APP_LOG}" 2>&1 &
echo "LOG: ${APP_LOG}"
