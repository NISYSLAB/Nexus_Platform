#!/bin/bash

######## Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./conversion_configurations.sh

## Added following two lines to avoid errors:
## failed to solve with frontend dockerfile.v0: failed to create LLB definition:
## failed to authorize: rpc error: code = Unknown desc = failed to fetch anonymous
## token: unexpected status: 401 Unauthorized
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

######## function definition
function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   echo "time docker build  --no-cache --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} . "
   time docker build  --no-cache --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} .  || { echo "${image_name} docker image build failed at folder: ${PWD}"; return 1; }
   docker images |grep ${image_name}
}

function push_image() {
   local image_name=$1
   local image_tag=$2

   ##echo "gcloud auth configure-docker"
   ## gcloud auth configure-docker

   echo "time docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}"
   time docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} || { echo "push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} at folder: ${PWD}"; return 1; }
}

function build_push_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   build_image ${image_name} ${image_tag} ${docker_file} || { echo " FAILED_DOCKER_BUILD: Failed to build ${image_name} docker image at folder: ${PWD}!!! "; return 1; }
   push_image ${image_name} ${image_tag} || { echo " FAILED_DOCKER_PUSH: Failed to push ${CONTAINER_REGISTRY}/${GOOGLE_PROJECT_ID}/${image_name}:${image_tag} at folder: ${PWD}!!!" ; return 2; }
}

######## Execution Starts
##docker login

read -p "Do you like to push docker image to Docker Registry? (y/n): " push_image
echo "You answer: ${push_image}"

if [[ ${push_image} == [nN] ]]; then
   echo "time build_image  ${PYTHON_IMAGE_NAME} ${PYTHON_IMAGE_TAG} ${PYTHON_DOCKERFILE}"
   time build_image  ${PYTHON_IMAGE_NAME} ${PYTHON_IMAGE_TAG} ${PYTHON_DOCKERFILE}
else
   echo "time build_push_image ${PYTHON_IMAGE_NAME} ${PYTHON_IMAGE_TAG} ${PYTHON_DOCKERFILE}"
   time build_push_image ${PYTHON_IMAGE_NAME} ${PYTHON_IMAGE_TAG} ${PYTHON_DOCKERFILE}
fi

docker images | grep ${PYTHON_IMAGE_NAME}
