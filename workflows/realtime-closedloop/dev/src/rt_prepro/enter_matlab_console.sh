#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh

echo "matlab -nodisplay -nosplash"
matlab -nodisplay -nosplash

