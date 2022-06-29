#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

logdir=/Users/Synergy/synergy_process/logs

echo "logdir=$logdir"
ls -alt $logdir
