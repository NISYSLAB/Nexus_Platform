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
time scp_to_vm  \
    /Users/anniegu/workspace/dicom2nifti/dicom2nifti_python/dicom2nifti_app.zip \
    /home/pgu6/app/listener/fMri_realtime/listener_execution/dicom2nifti/dicom2nifti_app.zip \
     "${SYNERGY_1_VM}"

exit 0

## scp
## time scp_to_vm /Users/anniegu/workspace/GRAPipeline/CR0343.zip /labs/mahmoudilab/synergy_remote_data1/gra/gra_file_in_dir.backup/CR0343.zip "${SYNERGY_1_VM}"
## exit 0

rm -rf ./*.zip
ZIP_FILE=release-${VERSION}.zip
DEST_FILE=/home/pgu6/app/listener/"${ZIP_FILE}"
zip_file
time scp_to_vm "${ZIP_FILE}" "${DEST_FILE}" "${SYNERGY_1_VM}"
## time scp_to_vm "fmri_task_id_rsa.pub" "/home/pgu6/app/listener/fMri_realtime/fmri_task_id_rsa.pub" "${SYNERGY_1_VM}"
echo "${ZIP_FILE} was SCP to ${SYNERGY_1_VM}:${DEST_FILE}"
