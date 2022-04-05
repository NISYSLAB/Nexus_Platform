#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "$(random8) ${PASS} $(random10)"
#### function definitionss
function scp_matlab() {
  local src=realtime-closedloop.zip
  local dest=/home/pgu6/realtime-closedloop/${src}
  ##local dest_vm=${BMI_MATLAB_VM}
  local dest_vm=${BMI_MATLAB_SYNERGY_VM}
  rm -rf ${src}
  zip -r ${src} ./*.m ./run*.sh ./compile_matlab.sh \
      ./build_push_matlab.sh ./Dockerfil* ./.ssl/*  \
      ./dicom/*.* ./nii/*.* ./local_test.sh \
      ./make*.sh

  time scp_to_vm ${src} ${dest} ${dest_vm}
}

#### Main starts
scp_matlab
./sshmatlab.sh
