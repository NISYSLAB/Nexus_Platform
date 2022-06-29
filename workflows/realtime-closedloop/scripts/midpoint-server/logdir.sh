#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

logdir=/mnt/drive0/synergyfernsync/synergy_process/logs

echo "logdir=$logdir"
cd $logdir
