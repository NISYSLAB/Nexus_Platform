#!/bin/bash

###########################################################################
## This script is to monitor any new csv file added to the folder or subfolders
## or any changes to the existing csv files
###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./rtcp_default_settings.conf
source ./RTCP_RUNTIME_USER_SETTINGS.conf

now=$(date)
uuid=$(uuidgen)

function test_csv_local() {
  local folder=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv
  local tmpfile=EBDM_RT_99_run1.csv_20220728_17_06_20.zip
  echo "mv ${folder}/${tmpfile} /tmp/${tmpfile}"
  cp ${folder}/${tmpfile} /tmp/${uuid}_${tmpfile}
  echo "sleep 2"
  sleep 2
  echo "mv /tmp/${uuid}_${tmpfile} ${folder}/${uuid}_${tmpfile}"
  mv /tmp/${uuid}_${tmpfile} ${folder}/${uuid}_${tmpfile}
}

function test_csv_remote() {
  local REMOTE_USER=Synergy
  local REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/synergy_process/NOTIFICATION_TO_BMI
  local folder=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv
  local tmpfile=EBDM_RT_99_run1.csv_20220728_17_06_20.zip
  mkdir -p /tmp/${uuid}
  cp ${folder}/${tmpfile} /tmp/${uuid}/
  cd /tmp/${uuid}
  unzip ${tmpfile}

  echo "scp ./EBDM_RT_99_run1.csv ${REMOTE_USER}@${RTCP_TASK_SERVER_IP}:${REMOTE_TASK_RECEIVING_DIR}/${uuid}_EBDM_RT_99_run1.csv"
  scp ./EBDM_RT_99_run1.csv ${REMOTE_USER}@${RTCP_TASK_SERVER_IP}:${REMOTE_TASK_RECEIVING_DIR}/${uuid}_EBDM_RT_99_run1.csv
  cd -
  rm -rf /tmp/${uuid}
}

## Main starts
##test_csv_local
test_csv_remote
