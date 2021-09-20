#!/bin/bash

WEB_RELEASE_TAG=1.2
UTILS_RELEASE_TAG=1.0
DB_RELEASE_TAG=13.2

#### functions
function set_java_env() {
  /usr/libexec/java_home -V
  export JAVA_HOME=$(/usr/libexec/java_home -v 11.0.12)
  echo "JAVA_HOME=$JAVA_HOME"
  export PATH=$JAVA_HOME/bin:$PATH
  java -version
}

function build_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3
   echo "docker rmi -f ${image_name}:${image_tag}"
   docker rmi -f "${image_name}":"${image_tag}" || echo "${image_name}:${image_tag} not existing, build it!"
   echo "Build ${image_name}:${image_tag} docker image ..."
   docker build  -f "${docker_file}" -t "${image_name}":"${image_tag}" . || { echo "${image_name}:${image_tag} docker image build failed" ; exit 1; }
   docker images |grep "${image_name}"
}

function push_image() {
   local image_name=$1
   local image_tag=$2
   echo "Push ${image_name}:${image_tag}  to docker hub"
   docker push "${image_name}:${image_tag}" || { echo "Push ${image_name}:${image_tag} to Docker Hub failed" ; exit 1; }
}

function build_push_image() {
   local image_name=$1
   local image_tag=$2
   local docker_file=$3
   build_image "${image_name}" "${image_tag}" "${docker_file}"
   push_image "${image_name}" "${image_tag}"
}
####
export cloudypipelines_url=https://pipelineapi.org:9000

#### docker image/container
export web_image_name="us.gcr.io/cloudypipelines-com/nexus-web"
export web_image_tag=${WEB_RELEASE_TAG}
export web_dockerfile=Dockerfile.web
export web_container_name=nexus-web
export web_jar="target/nexusweb-0.0.1-SNAPSHOT.jar"
export SERVER_SERVLET_CONTEXT_PATH=/nexus

#### postgres local
export db_project=physionetchallenge2021
export db_ip=34.86.132.185
export db_instance=physionetchallenge-clone-20210304
export db_region=us-east4
export db_name=postgres
export db_pass=xxxxxxxxxx
export db_connection_name=${db_project}:${db_region}:${db_instance}
export db_user=postgres

## cloud
##export db_url="jdbc:postgresql://google/postgres?socketFactory=com.google.cloud.sql.postgres.SocketFactory&cloudSqlInstance=${db_project}:${db_region}:${db_instance}"

## utils
utils_image_name="us.gcr.io/cloudypipelines-com/nexus-utils"
utils_image_tag=${UTILS_RELEASE_TAG}
utils_dockerfile=Dockerfile.utils

## postgresql local docker:
export db_port=5489
export POSTGRES_PORT=$db_port
export db_version=${DB_RELEASE_TAG}
export db_container_name=nexus-postgres${db_version}
export db_image_name="us.gcr.io/cloudypipelines-com/${db_container_name}"
export db_image_tag=1.0
export db_dockerfile=Dockerfile.postgres
export db_url="jdbc:postgresql://localhost:${db_port}/${db_name}"


#### postgres PROD year 2021
## export db_project=physionetchallenge2021
## export db_ip=35.245.184.47
## export db_instance=physionetchallenge
## export db_region=us-east4
## export db_name=postgres
## export db_pass=xxxxxxxxxx
## export db_connection_name=${db_project}:${db_region}:${db_instance}
## export db_url="jdbc:postgresql://google/postgres?socketFactory=com.google.cloud.sql.postgres.SocketFactory&cloudSqlInstance=${db_project}:${db_region}:${db_instance}"
## export db_user=postgres

####
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/.ssl/sa-auto-build-client-physionetchallenge2021-ceedcfd39a4f.json"
export BUILD_VM_NAME=annie-local-docker:physionet-auto-build
export CONFIG_EDITOR=ping.gu@dbmi.emory.edu

###################################################################
export GITHUBREPO_PULL_CMD=pull_build_docker.sh
export BATCH_BUILD_ROOT_DIR=/tmp/web-client/docker-build
export SUBMISSION_ROOT_DIR=/tmp/web-client/submission
##export API_HOST=http://localhost:9000
export API_HOST=https://pipelineapi.org:9000
export PHYSIONET_SUBMISSION_URI="${API_HOST}/api/physionet/workflows/v1?workflowType=WDL"
export PHYSIONET_SUBMISSION_OPTIONS_URI="${API_HOST}/api/physionet/workflows/v1.1?workflowType=WDL"
export AUTH_TOKEN=${AUTH_TOKEN}
export APP_ENV=localhost
###################################################################

## swagger
export SWAGGER_PORT=8899
export SWAGGER_HOST=localhost

source ./.ssl/.settings.conf
