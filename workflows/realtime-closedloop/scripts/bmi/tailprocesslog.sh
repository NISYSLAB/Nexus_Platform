#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function get_log() {
    local log_dir=/labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop/single-thread
    ls -t "${log_dir}"/proce*.log | head -1
}

#### Main starts
log=$(get_log)
echo "process log: $log"
tail -f "${log}"

