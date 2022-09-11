#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh

IMAGE_NAME=dicom2nii
IMAGE_TAG=4.0
dockerfile=Dockerfile.dicom2nii

####
function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   echo "docker build  --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} ."
   docker build  --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} .  || { echo "${image_name} docker image build failed at folder: ${PWD}"; return 1; }
   echo "docker build successfully: ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}"
   docker images | grep ${image_name}
}

function check_release() {
    img=${image_name}:${image_tag}
    tarball=$( basename ${img} )
    tarball=$( echo "${tarball/':'/'-'}" )

    target=${RELEASE_DIR}/${tarball}.tar.gz
    if [ -f "$target" ]
    then
        echo "${target} is found, you must chnage 'image_tag' setting"
	      exit 1
    else
        echo "${target} not found, OK to proceed "
    fi
}

#### Main starts
echo "build_image ${IMAGE_NAME} ${IMAGE_TAG} ${dockerfile}"
time build_image ${IMAGE_NAME} ${IMAGE_TAG} ${dockerfile}








