#!/bin/bash

###########################################################################
## This script is to monitor any new csv file added to the folder or subfolders
## or any changes to the existing csv files
###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### configurations  should be replaced with the real one in TASK server
## Task
MONITORING_CSV_DIR=/Users/Synergy/synergy_process/NOTIFICATION_TO_BMI

## Dev
## MONITORING_CSV_DIR=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/task-server/tmp

## common
PROCESSED_CSV_LOG=${MONITORING_CSV_DIR}/processed_csv_files.csv
PROCESS_HEADER='cksum,filepath,datetime'
PROCESS_ID=$( uuidgen )
TMP_CSV=$MONITORING_CSV_DIR/tmp_${PROCESS_ID}.txt
TRIM_COMMA=$( echo $PROCESS_HEADER | tr ',' ' ')

## remote settings
export REMOTE_BMI_USER=synergysync
export REMOTE_BMI_HOST=datalink.bmi.emory.edu
export REMOTE_RECEIVING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir

#### functions
function timeStamp() {
    date +'%Y%m%d:%H:%M:%S'
}

function preProcess() {
    if [ -s $PROCESSED_CSV_LOG ]
    then
         echo ""  > /dev/null
         ##printInfo "$PROCESSED_CSV_LOG is not empty"
    else
         printInfo "$PROCESSED_CSV_LOG is empty"
         touch ${PROCESSED_CSV_LOG}
         echo $PROCESS_HEADER > ${PROCESSED_CSV_LOG}
    fi
}

function collectFiles() {
    find ${MONITORING_CSV_DIR} -type f -name '*.csv' ! -name 'processed_csv_files.csv*' > "${TMP_CSV}"
}

function cksumFile() {
    local file=$1
    local ck=$(cksum "$file" | cut -d' ' -f1-2 | tr " " "-" | xargs )
    echo ${ck}
}

function printInfo() {
  local msg=$1
  echo "${SCRIPT_NAME} [$(date -u +"%m/%d/%Y:%H:%M:%S")]: ${msg}"
}

function printConfig() {
   printInfo "MONITORING_TRIAL_LOG=$MONITORING_TRIAL_LOG"
   printInfo "PROCESSED_TRIAL_LOG=$PROCESSED_TRIAL_LOG"
   printInfo "MONITOR_LOG=$MONITOR_LOG"
   printInfo "TRIM_COMMA=$TRIM_COMMA"
}

function pushOrIgnore() {
    local csvFile=$1
    ## printInfo "Processing: $csvFile"
    local myCksum=$( cksumFile "$csvFile" )
    ## printInfo "checksum=[$myCksum] for $csvFile"
    ##if grep $myCksum "$PROCESSED_CSV_LOG"; then
    if grep -q $myCksum "$PROCESSED_CSV_LOG"; then
      ##echo "$myCksum found in $PROCESSED_CSV_LOG, $csvFile has not changed yet, skip"
      return 0
    fi
    local row="$myCksum,$csvFile,$( timeStamp )"
    scp2BMI "$csvFile" && echo "$row" >> "$PROCESSED_CSV_LOG" && cp "$PROCESSED_CSV_LOG" "$PROCESSED_CSV_LOG".backup
}

function scp2BMI() {
    local file=$1
    local tmpzip=$MONITORING_CSV_DIR/$( basename "$file" )_$( timeStamp ).zip
    zip "$tmpzip" "$file"
    echo "scp $tmpzip $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$REMOTE_RECEIVING_DIR/"
    scp "$tmpzip" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_RECEIVING_DIR"/
    local rtCode=$?
    rm -rf "$tmpzip"
    return $rtCode
}

function execMain() {
    preProcess
    collectFiles
    while read line; do
      pushOrIgnore "$line"
    done < "${TMP_CSV}"
    rm -rf "${TMP_CSV}"
}

#### Main starts
for i in {1..56}
do
  printInfo "Loop: $i"
  execMain
  sleep 1
done