#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

logdir=/labs/mahmoudilab/synergy-wf-executions/logs/rt-closedloop
ls -t $logdir/*.log

processdir=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread
ls -t $processdir/*.log