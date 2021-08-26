#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}" && source ./.common_configurations.sh

#### Starts
time build_push_image "${db_image_name}" "${db_image_tag}" "${db_dockerfile}"
docker images


