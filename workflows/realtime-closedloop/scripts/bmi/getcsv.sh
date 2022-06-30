#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

dir=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/csv
ls $dir/*.csv