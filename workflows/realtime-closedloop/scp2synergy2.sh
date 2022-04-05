#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh

echo "$(random8) ${PASS} $(random10)"
#### functions

function scp_synergy2() {
  local src=realtime-closedloop.zip
  local dest=/home/pgu6/dockers/realtime-closedloop/${src}
  local dest_vm=${BMI_SYNERGY_2_VM}
  rm -rf ${src}
  zip -r ${src} ./*.m ./run*.sh ./compile_matlab.sh ./build_push_matlab.sh ./Dockerfil* ./.ssl/* ./dicom/*.*
  time scp_to_vm ${src} ${dest} ${dest_vm}
}

function zip_file() {
  cd ..
  ## for GRAPipeline
  ## cp "$HOME"/workspace/GRAPipeline/start_container_batch.sh ./script/gra/gra_start_container_batch.sh
  ## cp "$HOME"/workspace/GRAPipeline/app_scripts/call_run_everything.sh ./script/gra/gra_call_run_everything.sh

  echo "zip -r ${ZIP_FILE} ${APP_JAR} script/*.sh"
  zip -r "${ZIP_FILE}" "${APP_JAR}" common_settings.sh script/*.sh
  cd -
  mv ../"${ZIP_FILE}" ./
}

#### Main starts
scp_synergy2
ssh_to_vm ${BMI_SYNERGY_2_VM}

exit 0
## scp
time scp_to_vm ~/workspace/GRAPipeline/CR0343.tar.gz /labs/mahmoudilab/synergy_slurm/dataset/CR0343.tar.gz "${SYNERGY_2_VM}"
## time scp_to_vm /Users/anniegu/workspace/fMRI_Biomarker.zip /home/pgu6/fMRI_Biomarker.zip "${SYNERGY_2_VM}"


