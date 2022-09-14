#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./src_common_settings.sh

time ./build_push_docker.sh > build_push_docker.log 2>&1 &
echo "Log file: build_push_docker.log"
echo "tail -f build_push_docker.log"