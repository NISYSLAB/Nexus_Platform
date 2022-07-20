#!/bin/bash

###########################################################################
## This script is to monitor any new csv file added to the folder or subfolders
## or any changes to the existing csv files
###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./common_settings.sh

#### configurations  should be replaced with the real one in TASK server
## BMI

MONITORING_IMAGE_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image
MONITORING_PROCESSED_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir_processed
PIPELINE_LISTENER_DIR=/labs/mahmoudilab/synergy_remote_data1/rtcl_data_in_dir
TMP_DIR=${MONITORING_PROCESSED_DIR}/rtcl_call
WF_LOG_DIR=/labs/mahmoudilab/synergy_remote_data1/logs/rtcl
EXE_ENTRY_DIR=/labs/mahmoudilab/synergy_rtcl_app
RUN_RTCP_PIPELINE_SCRIPT=submit_non_cromwell.sh

## interval in seconds 60 seconds = 1 minutes
interval=1

## common
PROCESS_ID=$( uuidgen )
WORK_DIR=${TMP_DIR}/submit_and_run_${PROCESS_ID}
PROCESSED_EXTRACTION_LOG=${MONITORING_PROCESSED_DIR}/processed_extractions.csv
TMP_CSV=${MONITORING_PROCESSED_DIR}/tmp_${PROCESS_ID}.txt
PROCESS_HEADER='hash,imgStart,imgEnd,parseTime,wfStart,wfEnd,raw'
TRIM_COMMA=$( echo $PROCESS_HEADER | tr ',' ' ')
HASH_CMD=md5sum
RAW_HEADER="subject,effortDelay,run,runStart,trial,Cue1_Onset,Cue2_Onset,CueAll_Onset,CueAll_Offset,response,Reward,Effort,Order,RT,Trigger,ITI_Onset,ITI_Offset,CounterBalance_Order,Epoch1_Press,Epoch1_PressRT,Epoch2_Press,Epoch2_PressRT,"
RAW_HEADER_TRIM=$( echo $RAW_HEADER | tr ',' ' ')

## sample: 001_000003_000001.dcm
PADDING_ZEROS=6
NAME_PART1=001
NAME_PART2=000003

#### functions
function timeStamp() {
    date +'%Y%m%d:%H:%M:%S'
}

function getUid() {
    echo "$( date +'%Y-%m-%d-%H-%M-%S' )_$((1000 + RANDOM % 9999))"
}

function whichHashCmd() {
  which md5sum && HASH_CMD=md5sum && echo "md5sum is available"
  which md5 && HASH_CMD=md5 && echo "md5 is available"
  printInfo "HASH_CMD=$HASH_CMD"
}

function preProcess() {
    whichHashCmd
    mkdir -p ${MONITORING_PROCESSED_DIR}
    
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

function cksumFile() {
    local file=$1
    local ck=$(cksum "$file" | cut -d' ' -f1-2 | tr " " "-" | xargs )
    echo ${ck}
}

function hashCode() {
    local str=$1
    local hash=1234567890
    [[ "$HASH_CMD" == "md5sum" ]] && hash=$(echo -n $str | ${HASH_CMD} | cut -d " " -f1 | xargs )
    [[ "$HASH_CMD" == "md5" ]] && hash=$(echo $str | ${HASH_CMD} | xargs )
    echo ${hash}
}

function printInfo() {
  local msg=$1
  echo $msg
  ##echo "${SCRIPT_NAME} [$(date -u +"%m/%d/%Y:%H:%M:%S")]: ${msg}"
}

function printConfig() {
   printInfo "SCRIPT_DIR=$SCRIPT_DIR"
   printInfo "MONITORING_IMAGE_DIR=$MONITORING_IMAGE_DIR"
   printInfo "MONITORING_PROCESSED_DIR=$MONITORING_PROCESSED_DIR"
   printInfo "PIPELINE_LISTENER_DIR=$PIPELINE_LISTENER_DIR"
}

## appendFile "${notefile}" "${allRecordsFile}"
function appendFile() {
    local rawFile=$1
    local tmpCSVFile=$2
    local tmpDir=${WORK_DIR}/tmp/app_$PROCESS_ID
    local fileName=$( basename "${rawFile}" )
    mkdir -p "${tmpDir}"
    cp "${rawFile}" "${tmpDir}/${fileName}"

    cd "${tmpDir}"
    rm -rf ./*.csv
    [[ $fileName == *zip ]] && unzip "${fileName}" &&  mv $fileName "${MONITORING_PROCESSED_DIR}"/
    [[ $fileName == *tar.gz ]] && tar -xf "${fileName}" &&  mv $fileName "${MONITORING_PROCESSED_DIR}"/

    ##for csvFile in *.csv
    for csvFile in $( find . -type f -name '*.csv' )
    do
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
      [[ ${line} != *","* ]] && echo "Not a valid row: no comma" && continue

      local hash=$( hashCode $line )
      ## comment out following lines to allow process no matter processed or not
      ##if grep -q $hash "$PROCESSED_EXTRACTION_LOG"; then
        ##echo "Hash: $hash found in $PROCESSED_EXTRACTION_LOG, skip this record"
        ##continue
      ##fi
      ## PROCESS_HEADER='hash,imgStart,imgEnd,parseTime,wfStart,wfEnd,raw'
      local row="$hash,'imgStartTBD','imgEndTBD',$( timeStamp ),'wfStartTBD','wfEndTBD',\"$line\""
      echo "$row" >> "$PROCESSED_EXTRACTION_LOG"
      ## TODO: add hash code to this file, to serve as index
      ## interested in last line
      echo $line > ${newRecFile}
      ##echo $line >> ${newRecFile}
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

## submit2Pipeline ${ceilStart} ${ceilEnd}
## cd ${dicomDir} && tar -xvf ${shortname}
function submit2Pipeline() {
    local ceilStart=$1
    local ceilEnd=$2
    [[ -z "$ceilStart" ]] && return 0
    [[ -z "$ceilEnd" ]] && return 0
    local tmpName=${ceilStart}-${ceilEnd}-dicom-${PROCESS_ID}
    mkdir -p ${tmpName}
    local x=${ceilStart}
    while [ $x -le ${ceilEnd} ]
    do
      local dicomfile=${NAME_PART1}_${NAME_PART2}_$(padding ${x}).dcm
      echo "Copy dicom file:${dicomfile}"
      ## TODO: might wait until images are availabe
      cp ${MONITORING_IMAGE_DIR}/${dicomfile} ${tmpName}/
      ##mv ${MONITORING_IMAGE_DIR}/${dicomfile} ${tmpName}/
      x=$(( $x + 1 ))
    done

    local actnum=$( ls ${tmpName}/*.dcm | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && rm -rf ${tmpName} && echo "No dicom files [$(padding ${ceilStart}).dcm - $(padding ${ceilEnd}).dcm] available, skip this run" && return 1

    cd ${tmpName}
    tar -czf ${tmpName}.tar.gz *.dcm
    mv ${tmpName}.tar.gz ${WORK_DIR}/
    cd -
    rm -rf ${tmpName}
    printInfo "Files under WORK_DIR folder: ${WORK_DIR}"
    ls "${WORK_DIR}"

    local log=${WF_LOG_DIR}/submit_and_run_${PROCESS_ID}.log

    cd "${EXE_ENTRY_DIR}"
    local cmd="./${RUN_RTCP_PIPELINE_SCRIPT} ${WORK_DIR}/${tmpName}.tar.gz"
    printInfo "${cmd} >> ${log}  2>&1"
    ${cmd} 2>&1 | tee "${log}"
}

function execMain() {
    local inputFile=$1
    local nameonly=$( basename $inputFile )
    PROCESS_ID=$( uuidgen )
    WORK_DIR=${TMP_DIR}/submit_and_run_${PROCESS_ID}
    mkdir -p ${WORK_DIR}
    local allRecordsFile=${WORK_DIR}/all.csv
    appendFile ${inputFile} ${allRecordsFile}
    local newRecordFile=${WORK_DIR}/new_trial_record.csv
    parseNewRecords "${allRecordsFile}" "${newRecordFile}"
    [[ ! -f $newRecordFile ]] && echo "No new extractions available, skip this run" && return 0
    extractAndSubmit "${newRecordFile}"
}

#### Main starts
msg="Calling: ${SCRIPT_NAME} $@"
echo "${msg}"
argct=1
if [[ "$#" -ne "${argct}" ]]; then
    print_error "Invalid command line arguments, expecting :"${argct}" argument(s)"
    exit 1
fi
file=$1
preProcess
execMain "${file}"



