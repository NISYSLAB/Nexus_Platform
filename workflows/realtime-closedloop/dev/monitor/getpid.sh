#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./monitor_common_settings.sh

####
function get_monitor_instance() {
    echo "ps -eaf | grep rtcl-directory-monitor-DEV | grep java | grep jar"
    ps -eaf | grep rtcl-directory-monitor-DEV | grep java | grep jar
    process_id=$( ps -eaf | grep rtcl-directory-monitor-DEV | grep java | grep jar | awk '{print $2}' )
    [[ -z "$process_id" ]] && { echo "Monitor is not running"; return 0; }
    echo "Monitor is running, process_id=$process_id"
}

#### Main starts
get_monitor_instance

