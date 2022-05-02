#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REMOTE_DIR=/home/pgu6/app/cromwell
REMOTE_ZIP=remote_cromwell-framework.zip

cd ${REMOTE_DIR}
rm -rf ${REMOTE_ZIP}
zip -r ${REMOTE_ZIP} ./*.sh ./.ssl/.settings.conf ${REMOTE_DIR}/.config/local_backend_local_filesystems.conf