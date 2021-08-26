#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}" && source ./.common_configurations.sh

#### Function Definitions

function build_web_jar() {
    ##export GOOGLE_APPLICATION_CREDENTIALS="${PWD}/ssl/physionet-challenge-12lead-ecg-d875b52d05f9.json"
    rm -rf "${web_jar}"
    mvn clean && mvn package || exit 1
    ls -alt "${web_jar}"
}
#### End of Function Definitions
#### Starts
set_java_env
time build_web_jar
sleep 2
time build_push_image "${docker_image_name}" "${docker_image_tag}" "${dockerfile}"
docker images


