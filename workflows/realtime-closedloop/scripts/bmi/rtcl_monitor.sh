#!/bin/bash

###########################################################################
## This script is to monitor any new csv file added to the folder or subfolders
## or any changes to the existing csv files
###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### configurations  should be replaced with the real one in TASK server
## BMI
## MONITORING_CSV_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir
## MONITORING_PROCESSED_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed

## Dev
MONITORING_CSV_DIR=$PWD/tmp
MONITORING_PROCESSED_DIR=$PWD/processed

## common
PROCESSED_EXTRACTION_LOG=${MONITORING_CSV_DIR}/processed_extractions.csv
PROCESS_HEADER='cksum,start,end,datetime,raw'
PROCESS_ID=$( uuidgen )
TMP_CSV=$MONITORING_CSV_DIR/tmp_${PROCESS_ID}.txt
TRIM_COMMA=$( echo $PROCESS_HEADER | tr ',' ' ')

#### functions
function timeStamp() {
    date +'%Y%m%d:%H:%M:%S'
}

function preProcess() {
    if [ -s "$PROCESSED_EXTRACTION_LOG" ]
    then
         echo ""  > /dev/null
         ##printInfo "$PROCESSED_EXTRACTION_LOG is not empty"
    else
         printInfo "$PROCESSED_EXTRACTION_LOG is empty, adding header"
         touch "${PROCESSED_EXTRACTION_LOG}"
         echo $PROCESS_HEADER > "${PROCESSED_EXTRACTION_LOG}"
    fi
}

function collectFiles() {
    ##find "${MONITORING_CSV_DIR}" -type f -name '*.csv' ! -name '*processed_extractions.csv*' > "${TMP_CSV}"
    find "${MONITORING_CSV_DIR}" -type f -name '*.zip' > "${TMP_CSV}"
    find "${MONITORING_CSV_DIR}" -type f -name '*.tar.gz' >> "${TMP_CSV}"
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

## collectUniqRecords "${notefile}" "${tmpRawUniqRecordsFile}"
function collectUniqRecords() {
    local rawFile=$1
    local tmpCSVFile=$2
    local tmpDir=$PWD/tmp/$( uuidgen )
    local fileName=$( basename "${rawFile}" )
    mkdir -p "${tmpDir}"
    mkdir -p ${MONITORING_PROCESSED_DIR}
    mv "${rawFile}" "${tmpDir}/${fileName}"

    cd "${tmpDir}"
    [[ $fileName == *zip ]] && unzip "${fileName}" &&  mv $fileName "${MONITORING_PROCESSED_DIR}"/
    [[ $fileName == *tar.gz ]] && tar -xf "${fileName}" &&  mv $fileName "${MONITORING_PROCESSED_DIR}"/

    for csvFile in *.csv
    do
      printInfo "cat $csvFile >> ${tmpCSVFile}"
      cat $csvFile >> ${tmpCSVFile}
    done

    cd -
    rm -rf "${tmpDir}"
}

function processNoteFile() {
    local file=$1
    local newRecordFile=tmp_ext_$( timeStamp ).csv
    parseNewRecords "${file}" "${newRecordFile}"
    return 0
    ## printInfo "Processing: $file"
    local myCksum=$( cksumFile "$file" )
    ## printInfo "checksum=[$myCksum] for $csvFile"
    ##if grep $myCksum "$PROCESSED_EXTRACTION_LOG"; then
    if grep -q $myCksum "$PROCESSED_EXTRACTION_LOG"; then
      ##echo "$myCksum found in $PROCESSED_EXTRACTION_LOG, $csvFile has not changed yet, skip"
      return 0
    fi
    local row="$myCksum,$file,$( timeStamp )"
    submit2Pipeline "$csvFile" && echo "$row" >> "$PROCESSED_EXTRACTION_LOG" && cp "$PROCESSED_EXTRACTION_LOG" "$PROCESSED_EXTRACTION_LOG".backup
}

function submit2Pipeline() {
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
    PROCESS_ID=$( uuidgen )
    TMP_CSV=$MONITORING_CSV_DIR/tmp_${PROCESS_ID}.txt
    collectFiles

    local actnum=$( cat ${TMP_CSV} | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && rm -rf $TMP_CSV && echo "No notification trial files available, skip this run" && return 0

    local workerDir=$PWD/tmp/worker_${PROCESS_ID}
    mkdir -p ${workerDir}
    local tmpRawUniqRecordsFile=${workerDir}/uniq.csv
    while read notefile; do
      collectUniqRecords ${notefile} ${workerDir}/all.csv
    done < "${TMP_CSV}"

    rm -rf "${TMP_CSV}"
    cat ${workerDir}/all.csv | sort | uniq > ${tmpRawUniqRecordsFile}
    printInfo "uniqCSV=${tmpRawUniqRecordsFile}"
    ##processNoteFile "$tmpRawUniqRecordsFile"
}

#### Main starts
preProcess
##for i in {1..56}
for i in {1..3}
do
  printInfo "Loop: $i"
  execMain
  sleep 1
done
