#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REMOTE_DIR=/home/pgu6/app/cromwell
REMOTE_ZIP=remote_cromwell-framework.zip

#### Main starts
exec_on_vm ${BMI_SYNERGY_1_VM} $PWD/zip_remote.sh
scp_from_vm ${REMOTE_DIR}/${REMOTE_ZIP} ${PWD}/${REMOTE_ZIP} ${BMI_SYNERGY_1_VM}
echo "Downloaded ${REMOTE_ZIP}"