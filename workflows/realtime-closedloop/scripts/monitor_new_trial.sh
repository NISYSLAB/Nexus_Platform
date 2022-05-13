#!/bin/bash

###########################################################################
## This script is to monitor if a new trial added to a log csv file
## if so, collect the image files in the new trial
## “Cue_1_Onset” is the beginning and “ITI_Offset” is the end of the trial.
##  And round up the numbers. So trial 1 is from 00001.dcm to 00013.dcm.
## Trial 2 is from  dicom file number 15 to 27.

## use cut command to extract fields
##  cat tmp/EEfRT_65_run1.csv | cut -d ',' -f 6,17 | head -n 6 > ~/Downloads/t5.csv

###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### configurations  should be replaced with the real one in TASK server
MONITORING_TRIAL_LOG=$PWD/tmp/EEfRT_65_run1.csv
PROCESSED_TRIAL_LOG=$PWD/tmp/processed_EEfRT_65_run1.csv
EXE_ENTRY_DIR=$PWD
MONITOR_LOG=$PWD/tmp/monitoring_$( basename -- $MONITORING_TRIAL_LOG).log
MAX_PER_RUN=1
PADDINGS=5

FIELDS="subject,effortDelay,run,runStart,trial,Cue1_Onset,Cue2_Onset,CueAll_Onset,CueAll_Offset,response,Reward,Effort,Order,RT,Trigger,ITI_Onset,ITI_Offset,CounterBalance_Order,Epoch1_Press,Epoch1_PressRT,Epoch2_Press,Epoch2_PressRT"
TRIM_COMMA=$(echo $FIELDS | tr ',' ' ')
#### functions
function getUid() {
    echo "$( date +'%m-%d-%Y:%H:%M:%S' )_$((1000 + RANDOM % 9999))"
}

function printInfo() {
  local msg=$1
  echo "${SCRIPT_NAME} [$(date -u +"%m/%d/%Y:%H:%M:%S")]: ${msg}"
}

function padZero() {
  local num=$1
  printf "%0${PADDINGS}d\n" "${num}"
}

function getSeq() {
  local start=$1
  local end=$2
  for i in $(seq "$start" "$end")
  do
     printf "%0${PADDINGS}d\n" "$i"
  done
}

function roundUp()  {
  ## https://unix.stackexchange.com/questions/167058/how-to-round-floating-point-numbers-in-shell
  local num=$1
  printf '%.*f\n' 0 "${num}"
}

function printConfig() {
   printInfo "MONITORING_TRIAL_LOG=$MONITORING_TRIAL_LOG"
   printInfo "PROCESSED_TRIAL_LOG=$PROCESSED_TRIAL_LOG"
   printInfo "MONITOR_LOG=$MONITOR_LOG"
   printInfo "TRIM_COMMA=$TRIM_COMMA"

}
function execMain() {
    while IFS=, read -r ${TRIM_COMMA}
    do
        #3 echo "Cue1_Onset=${Cue1_Onset}, ITI_Offset=${ITI_Offset}"
        local intS=$( roundUp "${Cue1_Onset}" )
        local intE=$( roundUp "${ITI_Offset}" )
        local padS=$( padZero "${intS}" )
        local padE=$( padZero "${intE}" )
        local imageSeq="$( getSeq ${intS} ${intE} )"
        echo "${Cue1_Onset},${ITI_Offset} ==> ${intS}, ${intE} ==> ${padS}, ${padE}"
        echo ${imageSeq}
        ##echo "ITI_Offset=${ITI_Offset}"
    done < "${MONITORING_TRIAL_LOG}"

    ##subject,effortDelay,run,runStart,trial,Cue1_Onset,Cue2_Onset,CueAll_Onset,CueAll_Offset,response,Reward,Effort,Order,RT,Trigger,ITI_Onset,ITI_Offset,CounterBalance_Order,Epoch1_Press,Epoch1_PressRT,Epoch2_Press,Epoch2_PressRT

    return 0
    actnum=$( ls ${MONITORING_TRIAL_LOG}/*.* | wc -l | xargs )
    [[ "$actnum" -eq 0 ]] && echo "No files available in folder: ${MONITORING_TRIAL_LOG}, skip this run" && return 0

    uuid=$( getUid )
    tmplist=${PROCESSED_TRIAL_LOG}/${uuid}
    mkdir -p ${tmplist}
    cd ${MONITORING_TRIAL_LOG}
    ## process a group each time
    local myfile=$( ls -rt | head -n 1 )
    local nameonly=$( basename "$myfile" )
    mv ${myfile} ${tmplist}/${nameonly}

    cd $EXE_ENTRY_DIR
    log=${LOG_DIR}/${uuid}_job.log
    local cmd="./submit_cromwell.sh ${tmplist}/${nameonly}"
    echo "${cmd} > ${log}  2>&1 &"
    ${cmd} > ${log} 2>&1 &
    cd $EXE_ENTRY_DIR
}

#### Main starts
#### for testing
printConfig
execMain
exit 0
for i in {1..56}
do
  echo "loop: $i"
  execMain
  sleep 1
done
