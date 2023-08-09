#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./monitor_common_settings.sh

#### Main starts
dir="$( dirname "${MONITOR_APP_LOG}" )"
echo "Monitor Log Directory: ${dir}"
alllogs=$( ls -t ${dir}/rtcl-directory-monitor-${PROFILE}*.log )
whichone=$( ls -t ${dir}/rtcl-directory-monitor-${PROFILE}*.log | head -1 )
echo "All logs: ${alllogs}"
echo "Latest Monitor Log: ${whichone}"
echo "Run: tail -f ${whichone}"

