#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REMOTE_DIR=/home/pgu6/app/cromwell
REMOTE_WDL_DIR=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl
REMOTE_ZIP=remote_cromwell-framework.zip

cd ${REMOTE_DIR}
echo "Working Dir"
ls

rm -rf ${REMOTE_ZIP}
cp -rf ${REMOTE_WDL_DIR} ./wdl
zip -r ${REMOTE_ZIP} ./*.sh ./.ssl/.settings.conf ./wdl ${REMOTE_DIR}/.config/local_backend_local_filesystems.conf
rm -rf ./wdl
