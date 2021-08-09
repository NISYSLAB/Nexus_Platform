#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${SCRIPT_DIR}
source ./.common_configurations.sh
##########################################################################################
function build_jar() {
    rm -rf target/physionet-challenge-web-client-0.1.0.jar
    mvn clean && mvn package || { echo "build web-client jar failed" ; exit 1; }
    ## mvn clean && mvn package -Dmaven.test.skip=true || { echo "build web-client jar failed" ; exit 1; }
}
##########################################################################################
function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3
   echo "Build ${image_name}:${image_tag} docker image ..."
   docker build  --no-cache --force-rm -f ${docker_file} -t ${image_name}:${image_tag} . || { echo "${image_name}:${image_tag} docker image build failed" ; exit 1; }
  }
##########################################################################################
function push_image() {
   local image_name=$1
   local image_tag=$2
   echo "docker push ${image_name}:${image_tag}"
   docker push ${image_name}:${image_tag}  \
     || { echo "push ${image_name}:${image_tag} at folder: ${PWD}, failed" ; exit 1; }
}
##########################################################################################
function build_push_docker() {
    echo "Remove ${docker_image_name}:${docker_image_tag}"
    docker rmi --force ${docker_image_name}:${docker_image_tag}
    echo "Build ${docker_image_name}:${docker_image_tag} docker image ..."
    build_jar
    build_image ${docker_image_name} ${docker_image_tag} ${dockerfile}
    push_image ${docker_image_name} ${docker_image_tag}
}
##########################################################################################
function start_container() {
    docker stop ${docker_container_name} || (echo "${docker_container_name} not existing or running ...")
    docker rm -f -v ${docker_container_name}|| (echo "${docker_container_name} not existing or running ...")
    docker ps |grep ${docker_container_name}

    docker run -d \
    -p ${SWAGGER_PORT}:${SWAGGER_PORT} \
    --name ${docker_container_name}  \
    -v `pwd`/.ssl/:`pwd`/.ssl/ \
    -e BUILD_VM_NAME="${BUILD_VM_NAME}" \
    -e GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS}" \
    -e GITHUBREPO_PULL_CMD="${GITHUBREPO_PULL_CMD}" \
    -e BATCH_BUILD_ROOT_DIR="${BATCH_BUILD_ROOT_DIR}"  \
    -e SUBMISSION_ROOT_DIR="${SUBMISSION_ROOT_DIR}" \
    -e API_HOST="${API_HOST}" \
    -e PHYSIONET_SUBMISSION_URI="${PHYSIONET_SUBMISSION_URI}"  \
    -e PHYSIONET_SUBMISSION_OPTIONS_URI="${PHYSIONET_SUBMISSION_OPTIONS_URI}"  \
    -e AUTH_TOKEN="${AUTH_TOKEN}"  \
    -e db_connection_name="${db_connection_name}"  \
    -e db_name="${db_name}"  \
    -e db_user="${db_user}"  \
    -e db_pass="${db_pass}"  \
    -e db_port="${db_port}"  \
    -e db_url="${db_url}"  \
    -e SWAGGER_HOST="${SWAGGER_HOST}"  \
    -e CONFIG_EDITOR="${CONFIG_EDITOR}"  \
    -e SENDGRID_API_KEY="${SENDGRID_API_KEY}"  \
    -e APP_ENV="${APP_ENV}"  \
    -t ${docker_image_name}:${docker_image_tag}
}

function start_container_with_db_docker() {
    local db_url="jdbc:postgresql://${db_container_name}:5432/${db_name}"

    docker stop ${docker_container_name} || (echo "${docker_container_name} not existing or running ...")
    docker rm -f -v ${docker_container_name}|| (echo "${docker_container_name} not existing or running ...")
    docker ps |grep ${docker_container_name}

    docker run -d \
    -p ${SWAGGER_PORT}:${SWAGGER_PORT} \
    --name ${docker_container_name}  \
    --link ${db_container_name}:${db_container_name} \
    -v `pwd`/.ssl/:`pwd`/.ssl/ \
    -e BUILD_VM_NAME="${BUILD_VM_NAME}" \
    -e GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS}" \
    -e GITHUBREPO_PULL_CMD="${GITHUBREPO_PULL_CMD}" \
    -e BATCH_BUILD_ROOT_DIR="${BATCH_BUILD_ROOT_DIR}"  \
    -e SUBMISSION_ROOT_DIR="${SUBMISSION_ROOT_DIR}" \
    -e API_HOST="${API_HOST}" \
    -e PHYSIONET_SUBMISSION_URI="${PHYSIONET_SUBMISSION_URI}"  \
    -e AUTH_TOKEN="${AUTH_TOKEN}"  \
    -e db_connection_name="${db_connection_name}"  \
    -e db_name="${db_name}"  \
    -e db_user="${db_user}"  \
    -e db_pass="${db_pass}"  \
    -e db_port="${db_port}"  \
    -e db_url="${db_url}"  \
    -e SWAGGER_HOST="${SWAGGER_HOST}"  \
    -e CONFIG_EDITOR="${CONFIG_EDITOR}"  \
    -e SENDGRID_API_KEY="${SENDGRID_API_KEY}"  \
    -e APP_ENV="${APP_ENV}"  \
    -t ${docker_image_name}:${docker_image_tag}
}
#########################################################################################
clear
build_push_docker || exit 1;
docker images
## echo "start container connnecting to Cloud Postgresql" && start_container
echo "start container connnecting to local docker Postgresql" && start_container_with_db_docker
sleep 3
docker logs ${docker_container_name} -f

