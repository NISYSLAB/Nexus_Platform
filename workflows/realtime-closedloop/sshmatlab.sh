#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "$(random8) / ${PASS} $(random10)"
echo "ssh -J ${USER}@${JUMP_ODDJOBS} ${USER}@${MATLAB_VM}"
ssh -J ${USER}@${JUMP_ODDJOBS} ${USER}@${MATLAB_VM}
