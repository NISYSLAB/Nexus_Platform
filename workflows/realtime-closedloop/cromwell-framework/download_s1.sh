#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REMOTE_DIR=/home/pgu6/app/cromwell
REMOTE_ZIP=remote_cromwell-framework.zip
LOCAL_DIR=/workspace/Nexus_Platform/workflows/realtime-closedloop/cromwell-framework

#### Main starts
exec_on_vm ${BMI_SYNERGY_1_VM} $PWD/zip_remote.sh
scp_from_vm ${REMOTE_DIR}/${REMOTE_ZIP} ${LOCAL_DIR}/${REMOTE_ZIP} ${BMI_SYNERGY_1_VM}
echo "Downloaded ${LOCAL_DIR}/${REMOTE_ZIP}"