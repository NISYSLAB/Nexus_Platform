#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./monitor_common_settings.sh

#### Main starts
dir="$( dirname "${MONITOR_APP_LOG}" )"
echo "Monitor Log Directory: ${dir}"
whichone=$( ls -t ${dir}/rtcl-directory-monitor-${PROFILE}*.log )
echo "Latest Log: ${whichone}"
echo "Run: tail -f ${whichone}"

