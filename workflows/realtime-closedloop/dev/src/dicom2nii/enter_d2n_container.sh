#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh
echo "docker exec -it dicom2nii-DEV /bin/bash:sh"
docker exec -it dicom2nii-DEV /bin/bash
echo ""