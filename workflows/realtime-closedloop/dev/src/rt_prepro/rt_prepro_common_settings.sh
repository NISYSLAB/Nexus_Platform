#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh
echo "PROFILE=${PROFILE}"

#### Do Not  modify below!!!
MATLAB_VER=R2021b
MCRROOT=/usr/local/MATLAB/${MATLAB_VER}


