#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

#### function definitionss

function scp_matlab_with_userinput() {
  local src=realtime-closedloop.zip
  local dest=/home/pgu6/realtime-closedloop/${src}

  local dest_vm=${BMI_MATLAB_SYNERGY_VM}
  rm -rf ${src}
  zip -r ${src} "${user_files}"

  time scp_to_vm ${src} ${dest} ${dest_vm}
}

#### Main starts
user_files=$1
scp_matlab_with_userinput
## scp_matlab
./sshmatlab.sh
