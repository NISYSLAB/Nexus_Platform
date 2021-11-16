#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh

#### Starts
./build_jar.sh && java -jar "${APP_JAR}"

## java -jar "${APP_JAR}"

## mvn spring-boot:run
## gradle bootRun
echo "nexus passnexus"

echo "h2 db console: http://localhost:8080/h2-console"