#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

GCR_PATH=cloudypipelines-com
## GCR_PATH=physionetchallenge2022
CONTAINER_REGISTRY=us.gcr.io
image_name=closedloop-preprocess-tools
image_tag=matlab-1.0

container_name=${image_name}-${image_tag}
image_name=${CONTAINER_REGISTRY}/${GCR_PATH}/${image_name}:${image_tag}

#### functions
function stop_docker() {
  docker stop ${container_name} || (echo "${container_name} not existing or running ...")
  docker rm -f -v ${container_name}|| (echo "${container_name} not existing or running ...")
}

function run_docker() {
  docker run -d \
      --name ${container_name}  \
      -v $PWD/dicom:/home/login/dicom \
      -t ${image_name}
}
#### Main starts
sleep 2
docker ps
stop_docker
run_docker
echo "Enter container: ${container_name}"
echo "export PATH=$PATH:/home/login/spm12;/home/login/CanlabCore"
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/login/spm12;/home/login/CanlabCore"
echo "Run: ./RT_Preproc('/home/login/nii')"
echo "./RT_Preproc /home/login/nii"
docker exec -it ${container_name} /bin/bash
