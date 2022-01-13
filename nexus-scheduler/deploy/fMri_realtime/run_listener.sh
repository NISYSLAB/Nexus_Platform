#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ./common_settings.sh
app_log=${log_root}/synergy1/synergy1_${VERSION}_$(date +%Y-%m-%d:%H:%M:%S).log

mkdir -p ${log_root}/synergy1

#### Starts
java -jar "${APP_JAR}" > ${app_log} 2>&1 &

echo "logFile=${app_log}"

echo "tail -f ${app_log}"

sleep 3
tail -f ${app_log}
