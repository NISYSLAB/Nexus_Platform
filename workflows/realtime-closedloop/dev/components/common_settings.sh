export PROFILE=DEV
whichhost=$(hostname)
[[ ${whichhost} != "mahmoudilab-dev.priv.bmi.emory.edu" ]] && { echo ""; echo "Run ${PROFILE} Service is Prohibited in ${whichhost}!!!"; echo ""; exit 1; }

export PROFILE=DEV

#### Set IMAGE_TAG to new value for each new changes!!!
export IMAGE_TAG=1.0
export MONITOR_VERSION=2.1

####
export RELEASE_DIR=/labs/mahmoudilab/synergy-rtcl-app-release/docker-image
export CONTAINER_REGISTRY=gcr.io
export GCR_PATH=cloudypipelines-com
export CONTAINER_HOME=/home/yzhu382/dev-synergy-rtcl-app/src/rt_prepro
export EXEC_SCRIPT=exec_one.sh

