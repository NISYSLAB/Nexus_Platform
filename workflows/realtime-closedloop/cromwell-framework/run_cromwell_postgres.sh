#!/bin/bash

source ./common_settings.sh

export PGPORT=${postgres_cromwell_port}
echo "PGPORT=${postgres_cromwell_port}"

#######################################################

volumes_dir=$PWD/postgres-synergy1
##mkdir -p ${volumes_dir} || echo "Ok, the volumes folder ${volumes_dir} alredy exist"

function cleanup() {
  docker stop ${cromwell_postgres_container_name} || (echo "${cromwell_postgres_container_name} not existing or running ...")
  docker rm -f -v ${cromwell_postgres_container_name}|| (echo "${cromwell_postgres_container_name} not existing or running ...")
  ##docker ps |grep ${db_container_name}
}

function stopCloudSQLProxy() {
  process_id=$(ps -eaf |grep cloud_sql_proxy | awk '{print $2}')
  echo "cloudSQL proxy process_id=$process_id"
  kill -9 ${process_id} || echo "cloudSQL proxy process does not exist, OK to move on ..."
 }

echo "cleanup"
cleanup

echo "Must stop stopCloudSQLProxy!!!"
stopCloudSQLProxy

docker run -d  \
  --name ${cromwell_postgres_container_name} \
  -p ${PGPORT}:${PGPORT} \
  -e POSTGRES_DB="${cromwell_postgres_database}"  \
  -e POSTGRES_USER="${cromwell_postgres_user}"  \
  -e POSTGRES_PASSWORD="${cromwell_postgres_pass}"  \
  -e PGPORT="${PGPORT}" \
  -v ${volumes_dir}:/var/lib/postgresql/data  \
  -t ${cromwell_postgres_image_name}:${cromwell_postgres_image_tag}

sleep 5
docker ps

echo "docker exec -it ${cromwell_postgres_container_name} psql -U ${cromwell_postgres_user} -w"
echo "docker logs ${cromwell_postgres_container_name} -f"

## docker exec -it ${cromwell_postgres_container_name} psql -U ${cromwell_postgres_user} -w
## docker exec -it cromwell-postgres psql -U cromwell -w

