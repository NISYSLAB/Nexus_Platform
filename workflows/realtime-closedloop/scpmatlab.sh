#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "$(random8) / ${PASS} $(random10)"
#### function definitionss
function scp_matlab() {
  rm -rf closedloopmat.zip
  zip -r closedloopmat.zip ./*.m ./compile_matlab.sh ./build_push_matlab.sh ./Dockerfil* ./.ssl/* ./dicom/*.*
  local src=closedloopmat.zip
  local dest=/home/pgu6/realtime-closedloop/closedloopmat.zip
  local dest_vm=${MATLAB_VM}
  time scp_to_vm ${src} ${dest} ${dest_vm}
}

#### Main starts
scp_matlab
./ssh2_matlab.sh
