export PROFILE=DEV
whichhost=$(hostname)
[[ ${whichhost} != "mahmoudilab-dev.priv.bmi.emory.edu" ]] && { echo ""; echo "Run ${PROFILE} Service is Prohibited in ${whichhost}!!!"; echo ""; exit 1; }

#### Set IMAGE_TAG to new value for each new changes!!!
export IMAGE_TAG=4.0
export MONITOR_VERSION=2.1

####
export RELEASE_DIR=/labs/mahmoudilab/synergy-rtcl-app-release/docker-image
export CONTAINER_REGISTRY=gcr.io
export GCR_PATH=cloudypipelines-com
export IMAGE_NAME=rt-closedloop




