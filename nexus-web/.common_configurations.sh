#!/bin/bash

RELEASE_TAG=1.0

#### docker image/container
export docker_image_name="us.gcr.io/cloudypipelines-com/nexus-web"
export docker_image_tag=${RELEASE_TAG}
export dockerfile=Dockerfile.web
export docker_container_name=nexus-web
export web_jar="target/nexusweb-0.0.1-SNAPSHOT.jar"

#### postgres local year 2021
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

## local docker:
export db_container_name=postgres-nexus
db_url="jdbc:postgresql://localhost:5432/${db_name}"


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

##source ../.ssl/.ssl_settings.sh
