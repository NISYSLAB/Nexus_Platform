#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MCC=/usr/local/MATLAB/R2021b/bin/mcc
SRC=RT_Preproc

echo "time ${MCC} -m ${SRC}.m -o ${SRC}"
time ${MCC} -m ${SRC}.m -o ${SRC} && chmod a+x ${SRC}
