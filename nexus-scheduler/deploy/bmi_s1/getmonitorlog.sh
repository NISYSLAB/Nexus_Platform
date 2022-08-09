#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh

function get_log() {
    local log_dir=$(dirname "${APP_LOG}" )
    ls -t "${log_dir}"/*rtcl-directory-monitor*.log | head -1
}

#### Main starts
get_log

