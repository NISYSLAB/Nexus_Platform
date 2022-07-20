#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh

function get_log() {
    local log_dir=/labs/mahmoudilab/synergy_rtcl_app/mount/wf-rt-closedloop/single-thread
    ls -t "${log_dir}"/proce*.log | head -1
}

#### Main starts
get_log

