#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}

source ./src_settings.sh

####
function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   echo "docker build  --force-rm --no-cache -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} ."
   docker build  --force-rm --no-cache -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} .  || { echo "${image_name} docker image build failed at folder: ${PWD}"; return 1; }
   echo "docker build successfully: ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}"
   docker images | grep ${image_name}
}

function push_image() {
   local image_name=$1
   local image_tag=$2

   ##echo "gcloud auth configure-docker"
   ## gcloud auth configure-docker

   echo "docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}"
   docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} || { echo "push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} at folder: ${PWD}"; return 1; }
}

function build_push_image_tmp() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   build_image ${image_name} ${image_tag} ${docker_file} || { echo " FAILED_DOCKER_BUILD: Failed to build ${image_name} docker image at folder: ${PWD}!!! "; return 1; }
   push_image ${image_name} ${image_tag} || { echo " FAILED_DOCKER_PUSH: Failed to push ${CONTAINER_REGISTRY}/${GOOGLE_PROJECT_ID}/${image_name}:${image_tag} at folder: ${PWD}!!!" ; return 2; }
}

function check_and_get() {
    local folder=$1
    cd ${SCRIPT_DIR}
    if [[ ! -f rt_prepro/${folder}.tar.gz ]]
    then
      echo "rt_prepro/${folder}.tar.gz does not exist"
      cd rt_prepro
      echo "tar -czvf ${folder}.tar.gz ${folder}"
      tar -czvf ${folder}.tar.gz ${folder}
    fi	    
    cd ${SCRIPT_DIR}
}

function get_dependencies(){
    cd ${SCRIPT_DIR}
    ## these libraries should be packed into compiled matlab executable
    # check_and_get CanlabCore
    # check_and_get Neu3CA-RT
    # check_and_get spm12
}

function build_on_cloudypipelines() {
  GCR_PATH=cloudypipelines-com
  echo "Build and push to ${GCR_PATH}"
  time build_push_image ${image_name} ${image_tag} Dockerfile.r2021b
  ##time build_push_image ${image_name} ${image_tag} Dockerfile
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
check_release
get_dependencies
echo "build_image ${IMAGE_NAME} ${IMAGE_TAG} Dockerfile.r2021b"
time build_image ${IMAGE_NAME} ${IMAGE_TAG} Dockerfile.r2021b








