#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}"
source ./.common_configurations.sh
##########################################################################################
function cleanup() {
    docker stop "${web_container_name} "|| (echo "${web_container_name} not existing or running ...")
    docker rm -f -v "${web_container_name}"  || (echo "${web_container_name} not existing or running ...")
    docker ps | grep "${web_container_name}"
}

function start_container() {
    docker run -d \
    -p "${SWAGGER_PORT}":"${SWAGGER_PORT}" \
    --name "${web_container_name}"  \
    -v `pwd`/poc_workflow/:`pwd`/poc_workflow/ \
    -e cloudypipelines_url="${cloudypipelines_url}" \
    -e AUTH_TOKEN="${AUTH_TOKEN}"  \
    -e server.port="${SWAGGER_PORT}"  \
    -e SERVER_SERVLET_CONTEXT_PATH="${SERVER_SERVLET_CONTEXT_PATH}" \
    -e SWAGGER_HOST="${SWAGGER_HOST}"  \
    -e CONFIG_EDITOR="${CONFIG_EDITOR}"  \
    -e APP_ENV="${APP_ENV}"  \
    -t "${web_image_name}":"${web_image_tag}"
}

function start_container_with_db_docker() {
    local db_url="jdbc:postgresql://${db_container_name}:${db_port}/${db_name}"

    docker run -d \
    -p "${SWAGGER_PORT}":"${SWAGGER_PORT}" \
    --name "${web_container_name}"  \
    --link "${db_container_name}":"${db_container_name}" \
    -v `pwd`/.ssl/:`pwd`/.ssl/ \
    -v `pwd`/poc_workflow/:`pwd`/poc_workflow/ \
    -e AUTH_TOKEN="${AUTH_TOKEN}"  \
    -e server.port="${SWAGGER_PORT}"  \
    -e SERVER_SERVLET_CONTEXT_PATH="${SERVER_SERVLET_CONTEXT_PATH}" \
    -e SWAGGER_HOST="${SWAGGER_HOST}"  \
    -e cloudypipelines_url="${cloudypipelines_url}" \
    -e db_connection_name="${db_connection_name}"  \
    -e db_name="${db_name}"  \
    -e db_user="${db_user}"  \
    -e db_pass="${db_pass}"  \
    -e db_port="${db_port}"  \
    -e db_url="${db_url}"  \
    -e CONFIG_EDITOR="${CONFIG_EDITOR}"  \
    -e APP_ENV="${APP_ENV}"  \
    -t "${web_image_name}":"${web_image_tag}"
}
#########################################################################################
clear
## confirm rebuild docker?
read -p "Re build docker image? (y/n): " build_docker
echo "You answer: ${build_docker}"
[[ ${build_docker} == [yY] ]] && (time ./build_push_web_docker.sh || exit 1;)
## end of confirm rebuild docker?

docker images
## echo "start container connnecting to Cloud Postgresql" && start_container
##start_container
cleanup
start_container_with_db_docker
sleep 3
docker ps
tmp_url="http://${SWAGGER_HOST}:${SWAGGER_PORT}/${SERVER_SERVLET_CONTEXT_PATH}"
echo "   Spring OpenAPI Docs: https://github.com/springdoc/springdoc-openapi"
echo "Spring OpenAPI UI Docs: https://search.maven.org/search?q=g:org.springdoc%20AND%20a:springdoc-openapi-ui&core=gav"
echo " Swagger UI Properties: https://springdoc.org/#swagger-ui-properties"
echo "Swagger-ui configuration: https://swagger.io/docs/open-source-tools/swagger-ui/usage/configuration/"
echo "     To test: curl ${tmp_url}/greeting"
echo "     OpenAPI: ${tmp_url}/v3/api-docs/"
echo "    SwaggerUI: ${tmp_url}/swagger-ui.html"
echo "To view logs: docker logs ${docker_container_name} -f "

docker logs "${web_container_name}" -f


