#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh

echo "139733abE /${PASS}"
#### function definitionss
function zip_file() {
  cd ..
  echo "zip -r ${ZIP_FILE} ${APP_JAR} script/*.sh"
  zip -r ${ZIP_FILE} ${APP_JAR} common_settings.sh script/*.sh
  cd -
  mv ../${ZIP_FILE} ./
}

#### Start
rm -rf ./*.zip
ZIP_FILE=release-${VERSION}.zip
DEST_FILE=/home/pgu6/app/listener/fMri_realtime/${ZIP_FILE}
zip_file
## time scp_to_vm "${ZIP_FILE}" "${DEST_FILE}" "${SYNERGY_1_VM}"
time scp_to_vm "fmri_task_id_rsa.pub" "/home/pgu6/app/listener/fMri_realtime/fmri_task_id_rsa.pub" "${SYNERGY_1_VM}"

