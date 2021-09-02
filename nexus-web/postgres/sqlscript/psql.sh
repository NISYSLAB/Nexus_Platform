#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}"
source ../../.common_configurations.sh
clear
ps
echo "Enter psql(${db_user}/${db_pass}): docker exec -it ${db_container_name} psql -U ${db_user} -w"
docker exec -it "${db_container_name}" psql -U "${db_user}" -w
