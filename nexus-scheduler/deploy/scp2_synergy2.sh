#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "139733abE /${PASS} 445577"
#### function definitionss
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

#### Start

## scp
time scp_to_vm /Users/anniegu/workspace/fMRI_Biomarker.zip /home/pgu6/fMRI_Biomarker.zip "${SYNERGY_2_VM}"


