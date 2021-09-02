#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}" && source ./.common_configurations.sh

time build_push_image "${filetransfer_image_name}" "${filetransfer_image_tag}" "${filetransfer_dockerfile}"
docker images


