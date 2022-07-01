#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh

function get_pid() {
    echo "ps -eaf | grep taskserver-directory-monitor | grep java | grep jar"
    ps -eaf | grep taskserver-directory-monitor | grep java | grep jar
    process_id=$( ps -eaf | grep taskserver-directory-monitor | grep java | grep jar | awk '{print $2}' )
    echo "current  monitor instance process_id=$process_id"
}

#### Main starts
get_pid

