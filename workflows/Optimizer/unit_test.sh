#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### global settings
IMAGE=gcr.io/cloudypipelines-com/rt-optimizer:1.0
CONTAINER_NAME=rt-optimizer_1.0
APP_HOME=/home/pgu6/realtime-closedloop

#### functions
function cleanup() {
  docker stop "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
  docker rm -f -v "${CONTAINER_NAME}" || (echo "${CONTAINER_NAME} not existing or running ...")
}
##  -v "${PWD}/csv":${APP_HOME}/csv \
function create_container() {
  echo "Creating container: ${CONTAINER_NAME}"
  docker run --entrypoint /bin/bash \
        -v "${PWD}/csv":${APP_HOME}/csv \
        --name ${CONTAINER_NAME}  \
        -itd "${IMAGE}"
}

#### Main starts
cleanup
time create_container
sleep 2
docker ps -a

echo "Home directory"
docker exec "${CONTAINER_NAME}" pwd

echo "Files in ${APP_HOME}"
docker exec "${CONTAINER_NAME}" bash -c "ls ${APP_HOME}/"

echo "python fMRI_Bayesian_optimization.py --savepath <csv-folder> --savename <csv-filename>.csv"
cmd="mkdir -p ${APP_HOME}/csv && time python fMRI_Bayesian_optimization.py --savepath ${APP_HOME}/csv --savename output.csv "
echo "${cmd}"

docker exec "${CONTAINER_NAME}" bash -c "${cmd}"

##cleanup

echo "csv file: csv/output.csv"