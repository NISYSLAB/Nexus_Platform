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

function test_submit() {
  echo "Test csubmit_non_cromwell.sh ${now}"
  local tmpfile=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed/single-thread/2022-06-30-14-41-20_1874/76-91-dicom-b7e993b4-5cf7-4feb-8397-a1157b512412.tar.gz
  echo "./submit_non_cromwell.sh ${tmpfile}"
  ./submit_non_cromwell.sh ${tmpfile}

}


## Main starts
test_submit
