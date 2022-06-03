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
##PIPELINE_LISTENER_DIR=/labs/mahmoudilab/synergy_remote_data1/rtcl_data_in_dir

## Dev
MONITORING_CSV_DIR=$PWD/tmp
MONITORING_PROCESSED_DIR=$PWD/processed
PIPELINE_LISTENER_DIR=$PWD/rtcl_data_in_dir
PADDING_ZEROS=5

## common
PROCESS_ID=$( uuidgen )
WORK_DIR=$PWD/tmp/worker_${PROCESS_ID}
PROCESSED_EXTRACTION_LOG=${MONITORING_CSV_DIR}/processed_extractions.csv
TMP_CSV=$MONITORING_CSV_DIR/tmp_${PROCESS_ID}.txt
PROCESS_HEADER='hash,start,end,datetime,raw'
TRIM_COMMA=$( echo $PROCESS_HEADER | tr ',' ' ')
HASH_CMD=md5sum
RAW_HEADER="subject,effortDelay,run,runStart,trial,Cue1_Onset,Cue2_Onset,CueAll_Onset,CueAll_Offset,response,Reward,Effort,Order,RT,Trigger,ITI_Onset,ITI_Offset,CounterBalance_Order,Epoch1_Press,Epoch1_PressRT,Epoch2_Press,Epoch2_PressRT,"
RAW_HEADER_TRIM=$( echo $RAW_HEADER | tr ',' ' ')
#### functions
function timeStamp() {
    date +'%Y%m%d:%H:%M:%S'
}

function whichHashCmd() {
  which md5sum && HASH_CMD=md5sum && echo "md5sum is available"
  which md5 && HASH_CMD=md5 && echo "md5 is available"
  printInfo "HASH_CMD=$HASH_CMD"
}

function preProcess() {
    whichHashCmd
    
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
    local TMP_CSV=$1
    ##find "${MONITORING_CSV_DIR}" -type f -name '*.csv' ! -name '*processed_extractions.csv*' > "${TMP_CSV}"
    find "${MONITORING_CSV_DIR}" -type f -name '*.zip' > "${TMP_CSV}"
    find "${MONITORING_CSV_DIR}" -type f -name '*.tar.gz' >> "${TMP_CSV}"
}

function cksumFile() {
    local file=$1
    local ck=$(cksum "$file" | cut -d' ' -f1-2 | tr " " "-" | xargs )
    echo ${ck}
}

function hashCode() {
    local str=$1
    local hash=$(echo $str | ${HASH_CMD} | xargs )
    echo ${hash}
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

function appendAllRecords() {
    local contentFile=$1
    while read notefile; do
      appendFile ${notefile} ${contentFile}
      mv ${notefile} ${MONITORING_PROCESSED_DIR}/
    done < "${TMP_CSV}"
}

## appendFile "${notefile}" "${allRecordsFile}"
function appendFile() {
    local rawFile=$1
    local tmpCSVFile=$2
    local tmpDir=$PWD/tmp/$( uuidgen )
    local fileName=$( basename "${rawFile}" )
    mkdir -p "${tmpDir}"
    mkdir -p ${MONITORING_PROCESSED_DIR}
    cp "${rawFile}" "${tmpDir}/${fileName}"

    cd "${tmpDir}"
    [[ $fileName == *zip ]] && unzip "${fileName}" &&  mv $fileName "${MONITORING_PROCESSED_DIR}"/
    [[ $fileName == *tar.gz ]] && tar -xf "${fileName}" &&  mv $fileName "${MONITORING_PROCESSED_DIR}"/

    for csvFile in *.csv
    do
      ##printInfo "cat $csvFile >> ${tmpCSVFile}"
      cat $csvFile >> ${tmpCSVFile}
    done
    cd -
    rm -rf "${tmpDir}"
}

function parseNewRecords() {
    local allRecFile=$1
    local newRecFile=$2
    index=0
    while read line; do
      ((index++))
      [[ $line == *"Cue1_Onset"* ]] && continue
      ##printInfo "$index: $line"
      local hash=$( hashCode $line )
      if grep -q $hash "$PROCESSED_EXTRACTION_LOG"; then
        ##echo "$hash found in $PROCESSED_EXTRACTION_LOG, skip this record"
        continue
      fi
      ## PROCESS_HEADER='hash,start,end,datetime,raw'
      local row="$hash,'','',$( timeStamp ),\"$line\""
      echo "$row" >> "$PROCESSED_EXTRACTION_LOG"
      echo $line >> ${newRecFile}
    done <${allRecFile}
}

function getCeil() {
    local fnumber=$1
    perl -w -e "use POSIX; print ceil($fnumber/1.0), qq{\n}"
}

function padding() {
    local num=$1
    printf "%0${PADDING_ZEROS}d\n" $num
}

function extractAndSubmit() {
    local fileToBeRead=$1
    printInfo "RAW_HEADER_TRIM=$RAW_HEADER_TRIM"
    printInfo "RAW_HEADER=$RAW_HEADER"

    [ ! -f $fileToBeRead ] && { echo "$fileToBeRead file not found"; exit 99; }

    while IFS="," read -r $RAW_HEADER_TRIM
    do
      local start=$Cue1_Onset
      local ceilStart=$(getCeil $start)
      local padStart=$(padding $ceilStart)
      local end=$ITI_Onset
      local ceilEnd=$(getCeil $end)
      local padEnd=$(padding $ceilEnd)
      printInfo "start=$start ==> ceil=$ceilStart ==> padding=$padStart"
      printInfo "end=$end ==> ceil=$ceilEnd ==> padding=$padEnd"
      submit2Pipeline ${ceilStart} ${ceilEnd}
    done < $fileToBeRead
}

function processRecord() {
    local file=$1
    mkdir -p $PWD/tmp
    local newRecordFile=${WORK_DIR}/tmp_rec_$( timeStamp ).csv
    parseNewRecords "${file}" "${newRecordFile}"
    [[ ! -f $newRecordFile ]] && printInfo "No new extractions available, skip this run" && return 0
    extractAndSubmit "${newRecordFile}"
}

## submit2Pipeline ${ceilStart} ${ceilEnd}
## cd ${dicomDir} && tar -xvf ${shortname}
function submit2Pipeline() {
    local ceilStart=$1
    local ceilEnd=$2

    local tmpName=${ceilStart}-${ceilEnd}-dicom
    mkdir -p ${tmpName}
    local x=${ceilStart}
    while [ $x -le ${ceilEnd} ]
    do
      local file=$(padding ${x})
      echo "Copy dicom file:${file}.dcm "
      mv ${MONITORING_CSV_DIR}/${file}.dcm ${tmpName}/
      x=$(( $x + 1 ))
    done

    local actnum=$( ls ${tmpName}/*.dcm | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && rm -rf ${tmpName} && echo "No dicom files [$(padding ${ceilStart}).dcm - $(padding ${ceilEnd}).dcm] available, skip this run" && return 1

    cd ${tmpName}
    tar -czf ${tmpName}.tar.gz *.dcm
    mv ${tmpName}.tar.gz ${PIPELINE_LISTENER_DIR}/
    cd -
    rm -rf ${tmpName}
}

function execMain() {
    PROCESS_ID=$( uuidgen )
    TMP_CSV=$MONITORING_CSV_DIR/tmp_${PROCESS_ID}.txt
    collectFiles $TMP_CSV

    local actnum=$( cat ${TMP_CSV} | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && rm -rf $TMP_CSV && echo "No notification trial files available, skip this run" && return 0

    WORK_DIR=$PWD/tmp/worker_${PROCESS_ID}
    mkdir -p ${WORK_DIR}
    local allRecordsFile=${WORK_DIR}/all.csv
    appendAllRecords ${allRecordsFile}
    rm -rf "${TMP_CSV}"
    processRecord ${allRecordsFile}
}

#### Main starts
preProcess

for i in {1..56}
do
  printInfo "Loop: $i"
  execMain
  sleep 1
done
