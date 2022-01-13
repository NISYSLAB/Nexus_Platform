#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh
log_dir=${log_root}/synergy1

log=$(ls -t ${log_dir}/*.log | head -1)

echo "listener log: ${log}"
tail -f ${log}

