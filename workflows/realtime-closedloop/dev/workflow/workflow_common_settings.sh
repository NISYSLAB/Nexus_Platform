
source ../common_settings.sh

#### global settings
IMAGE=${CONTAINER_REGISTRY}/${GCR_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
CONTAINER_NAME=realtime-closedloop-${PROFILE}
CONTAINER_HOME=/synergy-rtcl-app

HOST_MOUNT="${PWD}/mount"
CONTAINER_MOUNT="/$( basename ${HOST_MOUNT} )"

EXEC_SCRIPT=exec_one.sh