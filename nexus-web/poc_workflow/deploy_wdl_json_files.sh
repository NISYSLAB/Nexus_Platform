#!/bin/bash

#### This script was auto-generated, do not modify !!! ####
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

clear
echo "SCRIPT_NAME=${SCRIPT_NAME}"
echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "USER=${USER}"
echo "LOCAL_USER=$(whoami)"

WEB_CLIENT_URL=https://cloudypipeline.bmi.emory.edu/nexus
LOCAL_WEB_CLIENT_URL=http://localhost:8899/nexus
##################################################################################
function submit() {
  local file=$1
  local fileName=$2
  local fileType=$3
  curl -k --include -H "Accept: application/json" \
          -H "Content-Type: multipart/form-data" \
          -F "file=@${file}" \
          -F "fileName=${fileName}" \
          -F "fileType=${fileType}" \
          -F "editor=${ADMIN_EDITOR}" \
          -X POST "${WEB_CLIENT_URL}/api/admin/files"

 echo "" && echo "Added or updated fileName=${fileName}, file=${file}, fileType=${fileType}"

}
##################################################################################

#### Starts
cd ${SCRIPT_DIR}
file_root=$PWD

## APP_ENV confirm
read -p "Submit to: BMI Cluster? (y/n): " is_production
echo "You answer: ${is_production}"
[[ ${is_production} == [nN] ]] && WEB_CLIENT_URL="${LOCAL_WEB_CLIENT_URL}"
## end APP_ENV confirm

echo "WEB_CLIENT_URL=${WEB_CLIENT_URL}"

##############################################################################
## taskA.wdl
file=${file_root}/taskA.wdl
submit ${file} "poc_taskA_wdl" "WDL"

## taskB.wdl
file=${file_root}/taskB.wdl
submit ${file} "poc_taskB_wdl" "WDL"

## taskC.wdl
file=${file_root}/taskC.wdl
submit ${file} "poc_taskC_wdl" "WDL"

## taskA.json
file=${file_root}/taskA.json
submit ${file} "poc_taskA_json" "JSON"

## taskB.json
file=${file_root}/taskB.json
submit ${file} "poc_taskB_json" "JSON"

## taskC.json
file=${file_root}/taskC.json
submit ${file} "poc_taskC_json" "JSON"

