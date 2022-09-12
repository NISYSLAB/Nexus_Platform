#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh

name=dicom2nii-DEV
echo ""
echo "docker stop ${name}"
docker stop ${name}

docker ps -a
echo ""