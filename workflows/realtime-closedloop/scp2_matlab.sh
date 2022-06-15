#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### function definitionss
zipfile=realtime-closedloop.zip
exclude="-x ./scp_from_vm.sh -x ./sshmatlab.sh -x ./scp_dicom_synergy1.sh -x ./get_zip.sh -x ./run_docker_container.sh -x ./scp2_matlab.sh -x ./scp2synergy2.sh"
files="./common_settings.sh ./compile_matlab.sh ./make_spm12.sh ./command_line.sh"
function zip_local() {
  rm -rf ${zipfile}
  zip -r ${zipfile} ${files} ./*.txt ./*.m ./*.nii ${exclude}

}
function scp_matlab() {
  local src=${zipfile}
  local dest=/home/pgu6/realtime-closedloop/${src}
  time scp_to_vm ${src} ${dest} ${BMI_MATLAB_SYNERGY_VM}
  echo "Remote=${BMI_MATLAB_SYNERGY_VM}:${dest}"
  rm -rf ${zipfile}
}

function scp_data() {
  local src=rt_FMRI_SH.zip
  local dest=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/$src
  time scp_to_vm $PWD/${src} ${dest} ${BMI_SYNERGY_1_VM}
  echo "Remote=${BMI_SYNERGY_1_VM}:${dest}"
}

#### Main starts
cd ${SCRIPT_DIR}
zip_local
scp_matlab
##scp_data

