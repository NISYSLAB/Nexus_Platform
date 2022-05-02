#!/usr/bin/env bash

export DOMAIN=cloudypipeline.bmi.emory.edu

## docker images or services release tags
CROMWELL_TAG=59
POSTGRES_TAG=6.1

## exposed ports
## for expose ports
EXPOSE_9555=9555
EXPOSE_9000=9000
EXPOSE_9988=9988
EXPOSE_9005=9005

## internal ports
cromwell_port=9033
postgres_cromwell_port=5488

## for cromwell image/container
prefix=cromwell
cromwell_version=${CROMWELL_TAG}
cromwell_image_tag=${cromwell_version}
cromwell_image_name=yunpipe/${prefix}
cromwell_container_name=${prefix}
cromwell_web_jar=cromwell-${cromwell_version}.jar
cromwell_server_url=http://${cromwell_container_name}:${cromwell_port}
##cromwell_server_url=http://localhost:${cromwell_port}
cromwell_dockerfile=Dockerfile.${prefix}
cromwell_log=/labs/sharmalab/cloudypipelines/cromwell/logs/synergy1/cromwell_${CROMWELL_TAG}_$(date +%Y-%m-%d:%H:%M:%S).log
##cromwell_log=/tmp/app/logs/cromwell_${CROMWELL_TAG}_$(date +%Y-%m-%d:%H:%M:%S).log

## for cromwell postgres
prefix=cromwell-postgres
cromwell_postgres_image_name=yunpipe/${prefix}
cromwell_postgres_image_tag=${POSTGRES_TAG}
cromwell_postgres_container_name=${prefix}
cromwell_postgres_root_pass=cromwellSecret19
cromwell_postgres_database=cromwell
cromwell_postgres_user=cromwell
cromwell_postgres_pass=cromwell
cromwell_postgres_admin=${prefix}_admin
cromwell_postgres_dockerfile=Dockerfile.${prefix}

## local Postgres
db_image_name=yunpipe/postgresdb
db_image_tag=${POSTGRES_TAG}
db_container_name=postgresdb

######################################################
source ./.ssl/.settings.conf

