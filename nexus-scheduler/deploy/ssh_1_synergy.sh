#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "${PASS} / 138Dept%%22"
set -x
##ssh -i "${SSH_ID_FILE}" -J "${USER}@${JUMP_NEBULA}" "${USER}@${SYNERGY_1_VM}"

ssh -i "${SSH_ID_FILE}" -J "${USER}@${JUMP_NEBULA}" "${USER}@${SYNERGY_1_VM}"
