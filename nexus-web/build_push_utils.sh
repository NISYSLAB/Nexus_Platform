#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}" && source ./.common_configurations.sh

time build_push_image "${utils_image_name}" "${utils_image_tag}" "${utils_dockerfile}"
docker images

