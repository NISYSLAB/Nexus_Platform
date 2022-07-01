#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function kill_monitor_instance() {
    echo "ps -eaf | grep taskserver-directory-monitor | grep java | grep jar"
    ps -eaf | grep taskserver-directory-monitor | grep java | grep jar
    process_id=$( ps -eaf | grep taskserver-directory-monitor | grep java | grep jar | awk '{print $2}' )
    echo "current  monitor instance process_id=$process_id"
    [[ ! -z "$process_id" ]] && echo "process_id Not empty, kill it" && kill -9 "${process_id}"
}

#### Main starts
kill_monitor_instance

