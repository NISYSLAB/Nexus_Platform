#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}" && source ./.common_configurations.sh

#### Function Definitions
function build_web_jar() {
    ##export GOOGLE_APPLICATION_CREDENTIALS="${PWD}/ssl/physionet-challenge-12lead-ecg-d875b52d05f9.json"
    rm -rf "${web_jar}"
    mvn clean && mvn package
    ls -alt "${web_jar}"
}

function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3
   echo "Build ${image_name}:${image_tag} docker image ..."
   docker build  -f "${docker_file}" -t "${image_name}":"${image_tag}" . || { echo "${image_name}:${image_tag} docker image build failed" ; exit 1; }
   docker images |grep "${image_name}"
}

function push_image() {
   local image_name=$1
   local image_tag=$2
   echo "Push ${image_name}:${image_tag}  to docker hub"
   docker push "${image_name}:${image_tag}" || { echo "Push ${image_name}:${image_tag} to Docker Hub failed" ; exit 1; }
}

function build_push_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3
   build_image "${image_name}" "${image_tag}" "${docker_file}"
   push_image "${image_name}" "${image_tag}"
}
#### End of Function Definitions
#### Starts
time build_web_jar
time build_push_image "${docker_image_name}" "${docker_image_tag}" "${dockerfile}"


