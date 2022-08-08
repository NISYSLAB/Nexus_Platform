#!/bin/bash

###########################################################################
## This script is to monitor any new csv file added to the folder or subfolders
## or any changes to the existing csv files
###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}

now=$(date)
uuid=$(uuidgen)

function test_config() {
  echo "Test config file ${now}"
  local tmpfile=/tmp/test_config_${uuid}.conf
  local dummy=""
  ##local dummy="dummy_"
  echo "RTCP_TASK_SERVER_IP=${dummy}10.44.121.90" >> ${tmpfile}
  echo "RTCP_IMAGE_NAME_PART1=${dummy}001" >> ${tmpfile}
  echo "RTCP_IMAGE_NAME_PART2=${dummy}000003" >> ${tmpfile}
  echo "RTCP_IMAGE_NAME_PART3_LENGTH=${dummy}6" >> ${tmpfile}
  echo "RTCP_PRE_4D_NII=${dummy}4D_pre.nii" >> ${tmpfile}
  echo "RTCP_SUBJECT_MASK_NII=${dummy}Wager_ACC_cluster8.nii" >> ${tmpfile}
  echo "RTCP_RESET_OPTIMIZER_CSV=${dummy}true" >> ${tmpfile}

  ./parse_and_submit.sh ${tmpfile}
  echo ""
  echo "Generated config  file: RTCP_RUNTIME_USER_SETTINGS.conf"
  echo ""
  rm -rf ${tmpfile}

}

function test_config_zip() {
  echo "Test config file ${now}"
  local tmpfile=/tmp/test_config_${uuid}.conf
  local dummy=""
  echo "RTCP_TASK_SERVER_IP=${dummy}10.44.121.90" >> ${tmpfile}
  echo "RTCP_IMAGE_NAME_PART1=${dummy}001" >> ${tmpfile}
  echo "RTCP_IMAGE_NAME_PART2=${dummy}000003" >> ${tmpfile}
  echo "RTCP_IMAGE_NAME_PART3_LENGTH=${dummy}6" >> ${tmpfile}
  echo "RTCP_PRE_4D_NII=${dummy}4D_pre.nii" >> ${tmpfile}
  echo "RTCP_SUBJECT_MASK_NII=${dummy}Wager_ACC_cluster8.nii" >> ${tmpfile}
  echo "RTCP_RESET_OPTIMIZER_CSV=${dummy}true" >> ${tmpfile}
  cd /tmp
  zip test_config_${uuid}.conf_123.zip test_config_${uuid}.conf
  cd -

  ./parse_and_submit.sh /tmp/test_config_${uuid}.conf_123.zip
  echo ""
  echo "Generated config  file: RTCP_RUNTIME_USER_SETTINGS.conf"
  echo ""
  rm -rf ${tmpfile}
  rm -rf /tmp/test_config_${uuid}.conf_123.zip

}

function test_csv_zip() {
  echo "Test csv file ${now}"
  local tmpfile=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv/EBDM_RT_99_run1.csv_20220728_17_06_20.zip
  ./parse_and_submit.sh ${tmpfile}
  echo ""

}

## Main starts
test_csv_zip
exit 0

test_config_zip
exit 0

#test_config
exit 0
