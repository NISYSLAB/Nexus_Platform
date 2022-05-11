#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
## Container Registry Path
## sample: us.gcr.io/cloudypipelines-com/python3:1.1
GCR_PATH=cloudypipelines-com
## Import Notes: gcr.io is private, us.gcr.io is public
CONTAINER_REGISTRY=gcr.io

IMAGE_NAME=rt-optimizer
IMAGE_TAG=1.0
IMAGE_FULL_NAME=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
DOCKERFILE=Dockerfile.python


#### functions
function cleanup(){
  docker rmi ${IMAGE_FULL_NAME} || echo "${IMAGE_FULL_NAME} not existing, ok to proceed"
}

function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   echo "docker build  --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} ."
   docker build  --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} .  || { echo "${image_name} docker image build failed at folder: ${PWD}"; return 1; }
}

function push_image() {
   local image_name=$1
   local image_tag=$2

   ##echo "gcloud auth configure-docker"
   ## gcloud auth configure-docker

   echo "docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}"
   docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} || { echo "push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} at folder: ${PWD}"; return 1; }
}

#### Main starts
cleanup
time build_image ${IMAGE_NAME} ${IMAGE_TAG} ${DOCKERFILE}
docker images