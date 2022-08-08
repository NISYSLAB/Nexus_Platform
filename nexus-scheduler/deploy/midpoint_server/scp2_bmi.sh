#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

## remote settings
export REMOTE_BMI_USER=synergysync
export REMOTE_BMI_HOST=datalink.bmi.emory.edu
export REMOTE_RECEIVING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image
export REMOTE_CONFIG_RECEIVING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv

#### functions
function timeStamp() {
    date +'%Y%m%d_%H_%M_%S'
}

function file_ready_check() {
  local file=$1
  echo "file_ready_check: $file"
  local oldsize=$( wc -c <"$file" | awk '{print $1}' )
  echo "oldsize=$oldsize"
  sleep 1
  local newsize=$( wc -c <"$file" | awk '{print $1}' )
  echo "newsize=$newsize"

  ## while [[ "$oldsize" -lt "$newsize" ]]
  while [[ "$oldsize" -ne "$newsize" ]]
  do
     echo "$file is changing ..."
     oldsize=$( wc -c <"$file" | awk '{print $1}' )
     sleep 1
     newsize=$( wc -c <"$file" | awk '{print $1}' )
  done

  if [ "$oldsize" -eq "$newsize" ]
  then
     echo "The file size is final: $file!"
  fi
}

function get_file_extention() {
  local filepath=$1
  local filename=$( basename "$filepath" )
  echo "${filename##*.}"
}

function get_remote_dest() {
    local file=$1
    local ext=$( get_file_extention "$file" )
    if [ "$ext" == "dcm" ]; then
      echo $REMOTE_RECEIVING_DIR
    else
      echo $REMOTE_CONFIG_RECEIVING_DIR
  fi
}

function scp2_bmi() {
    local file=$1
    local remote_dest=$( get_remote_dest "$file" )
    echo "scp $file $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$remote_dest/"
    scp "$file" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$remote_dest"/
}

#### Main starts
file=$1
file_ready_check "${file}"
scp2_bmi "${file}"

