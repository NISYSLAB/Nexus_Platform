COMP_NAME="rtpreprocess"
CONTAINER_NAME=rt-closedloop-${COMP_NAME}
CONTAINER_NAME_WORKFLOW=rt-closedloop-2comp-${COMP_NAME}-${PROFILE}
HOST_MOUNT="${PWD}/mount_${COMP_NAME}"
CONTAINER_MOUNT="/$( basename ${HOST_MOUNT} )"
IMAGE_NAME=rt-closedloop-2comp-${COMP_NAME}