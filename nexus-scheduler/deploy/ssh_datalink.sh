#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "Dep;#13973 /${PASS}"
set -x
ssh  "${USER}@${DATALINK}"
##ssh -i "${SSH_ID_FILE}" "${USER}@${DATALINK}"
