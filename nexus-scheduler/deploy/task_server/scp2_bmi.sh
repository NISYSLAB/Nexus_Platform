#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
tmp_dir=/tmp/synergy
## remote settings
export REMOTE_BMI_USER=synergysync
export REMOTE_BMI_HOST=datalink.bmi.emory.edu
export REMOTE_RECEIVING_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv

#### functions
function timeStamp() {
    date +'%Y%m%d_%H_%M_%S'
}

function scp2_bmi() {
    mkdir -p ${tmp_dir}

    local file=$1
    local nameonly=$( basename "$file" )
    cp ${file} ${tmp_dir}/${nameonly}
    cd ${tmp_dir}
    local tmpzip=${nameonly}_$( timeStamp ).zip
    zip "$tmpzip" ${nameonly}
    echo "scp $tmpzip $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$REMOTE_RECEIVING_DIR/"
    scp "$tmpzip" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_RECEIVING_DIR"/
    local rtCode=$?
    rm -rf "$tmpzip"
    cd -
    return $rtCode
}

#### Main starts
#### Main starts
file=$1
echo "Received $file"
allow=1
[[ $file == *csv ]] && allow=0
[[ $file == *txt ]] && allow=0
[[ $file == *log ]] && allow=0
[[ $allow == 0 ]] && scp2_bmi "${file}"

