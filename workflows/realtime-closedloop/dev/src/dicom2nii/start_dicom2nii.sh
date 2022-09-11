#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../../common_settings.sh

IMAGE_NAME=dicom2nii
IMAGE_TAG=4.0
CONTAINER_NAME=dicom2nii-${PROFILE}
IMAGE=gcr.io/cloudypipelines-com/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_MOUNT="/synergy-rtcl-app"
#### functions
function cleanup() {
  echo "Stop running instance ..."
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}

function create_container() {
  mkdir -p dicom && mkdir -p nii
  chmod a+rwx dicom && chmod a+rwx nii
  echo "Creating container: ${CONTAINER_NAME}"
  docker run --entrypoint /bin/bash \
         -v "${PWD}/dicom":"${CONTAINER_MOUNT}/dicom" \
         -v "${PWD}/nii":"${CONTAINER_MOUNT}/nii" \
         --name ${CONTAINER_NAME}  \
         -e containerName=${CONTAINER_NAME} \
         -itd "${IMAGE}"
}

#### Main starts
cleanup
time create_container
sleep 2
docker ps -a
echo ""
echo "Enter container: docker exec -it ${CONTAINER_NAME} /bin/bash"
echo ""