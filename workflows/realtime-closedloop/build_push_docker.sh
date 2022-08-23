#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
## Container Registry Path
## sample: us.gcr.io/cloudypipelines-com/python3:1.1

## Import Notes: gcr.io is private, us.gcr.io is public
CONTAINER_REGISTRY=gcr.io
## CONTAINER_REGISTRY=us.gcr.io

image_name=rt-closedloop
image_tag=3.0
##image_tag=2.5

rt_preproc_dir=/labs/mahmoudilab/synergy-rt-preproc

####
function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   echo "docker build  --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} ."
   docker build  --force-rm -f ${docker_file} -t ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} .  || { echo "${image_name} docker image build failed at folder: ${PWD}"; return 1; }
   docker images |grep ${image_name}
}

function push_image() {
   local image_name=$1
   local image_tag=$2

   ##echo "gcloud auth configure-docker"
   ## gcloud auth configure-docker

   echo "docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}"
   docker push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} || { echo "push ${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag} at folder: ${PWD}"; return 1; }
}

function build_push_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3

   build_image ${image_name} ${image_tag} ${docker_file} || { echo " FAILED_DOCKER_BUILD: Failed to build ${image_name} docker image at folder: ${PWD}!!! "; return 1; }
   push_image ${image_name} ${image_tag} || { echo " FAILED_DOCKER_PUSH: Failed to push ${CONTAINER_REGISTRY}/${GOOGLE_PROJECT_ID}/${image_name}:${image_tag} at folder: ${PWD}!!!" ; return 2; }
}

function get_canlabcore(){
  git clone https://github.com/canlab/CanlabCore.git
  zip -r CanlabCore.zip CanlabCore
  rm -rf ./CanlabCore
}

function compile_matlab() {
   ./compile_matlab.sh
}

function build_on_physionet() {
  GCR_PATH=physionetchallenge2022
  echo "Build and push to ${GCR_PATH}"
  [[ ! -f ./CanlabCore.zip ]] && time get_canlabcore
  [[ ! -f ./RT_Preproc ]] && time compile_matlab

  time build_push_image ${image_name} ${image_tag} Dockerfile.r2021b
}
function build_on_cloudypipelines() {
  GCR_PATH=cloudypipelines-com
  echo "Build and push to ${GCR_PATH}"
  time build_push_image ${image_name} ${image_tag} Dockerfile.r2021b
  ##time build_push_image ${image_name} ${image_tag} Dockerfile
}

function copy_rtcpreproc() {
  cp ${rt_preproc_dir}/CanlabCore.tar.gz .
  cp ${rt_preproc_dir}/spm12.tar.gz .
  cp ${rt_preproc_dir}/*RT_Preproc* .

  ##cp ${rt_preproc_dir}/run_RT_Preproc.sh .
  ##cp ${rt_preproc_dir}/RT_Preproc .
}

function remove_rtcpreproc() {
  rm ./CanlabCore.tar.gz
  rm ./spm12.tar.gz
  ##rm ./rtPreprocessing_simple_new
  rm ./*RT_Preproc*

  ##rm ./run_RT_Preproc.sh
  ##rm ./RT_Preproc
}

#### Main starts
copy_rtcpreproc
build_on_cloudypipelines
remove_rtcpreproc
exit 0
read -p "Build and push to PhysionetChallenge2022 ? (y/n): " yesno
echo "You answer: ${yesno}"
[[ ${yesno} == [nN] ]] && build_on_cloudypipelines
[[ ${yesno} == [yY] ]] && build_on_physionet








