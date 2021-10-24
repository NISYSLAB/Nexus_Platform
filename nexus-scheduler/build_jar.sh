#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./common_settings.sh
#### Start
rm -rf "${JAR}"
rm -rf "${APP_JAR}"
mvn clean
mvn package || exit 1
ls -alt "${JAR}"
cp "${JAR}" ./"${APP_JAR}"

echo "${SCRIPT_NAME}: Build VERSION: ${APP_JAR}"
ls -alt "${APP_JAR}"

## mvn spring-boot:run
## gradle bootRun
