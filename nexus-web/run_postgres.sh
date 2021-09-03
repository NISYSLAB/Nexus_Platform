#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}"
source ./.common_configurations.sh

PGPORT=${db_port}

##########################################################################################
function cleanup() {
  docker stop "${db_container_name}" || (echo "${db_container_name} not existing or running ...")
  docker rm -f -v "${db_container_name}" || (echo "${db_container_name} not existing or running ...")
}

function stopCloudSQLProxy() {
  process_id=$(ps -eaf | grep cloud_sql_proxy | awk '{print $2}')
  echo "cloudSQL proxy process_id=$process_id, kill it"
  kill -9 "${process_id}" || echo "cloudSQL proxy process does not exist, OK to move on ..."
 }

function start_container() {
    docker run -d \
    --name "${db_container_name}"  \
    -p "${PGPORT}":"${PGPORT}" \
    -e PGPORT="${PGPORT}" \
    -e POSTGRES_DB="${db_name}"  \
    -e POSTGRES_USER="${db_user}"  \
    -e POSTGRES_PASSWORD="${db_pass}"  \
    -v "${volumes_dir}":/var/lib/postgresql/data  \
    -t "${db_image_name}":"${db_image_tag}"
}

#########################################################################################
volumes_dir=$PWD/postgres/volume
mkdir -p "${volumes_dir}" || echo "Ok, the volumes folder ${volumes_dir} already exist"
clear
## confirm rebuild docker?
read -p "Re build docker image? (y/n): " build_docker
echo "You answer: ${build_docker}"
[[ ${build_docker} == [yY] ]] && (time ./build_push_postgres_docker.sh || exit 1;)
## end of confirm rebuild docker?

docker images
sleep 2

echo "cleanup"
cleanup

echo "Must stop stopCloudSQLProxy!!!"
stopCloudSQLProxy

start_container
sleep 3
docker ps
echo "Enter psql(${db_user}/${db_pass}): docker exec -it ${db_container_name} psql -U ${db_user} -w"

