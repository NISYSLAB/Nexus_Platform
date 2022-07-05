#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
####
source ../../common_settings.sh
echo "VERSION=$VERSION"
echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "SCRIPT_NAME=$SCRIPT_NAME"

remote_dest=/labs/mahmoudilab/synergy_remote_data1/midpointserver
exec_script=${SCRIPT_DIR}/scp2_midpoint_server.sh

#### Main starts
cd ${SCRIPT_DIR}
./deploy2_s1.sh
exec_on_vm ${BMI_SYNERGY_1_VM} ${exec_script}


