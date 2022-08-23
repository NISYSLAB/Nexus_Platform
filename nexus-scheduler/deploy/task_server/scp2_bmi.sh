#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
tmp_dir=/tmp/synergy
## remote settings
export REMOTE_BMI_USER=synergysync
export REMOTE_BMI_HOST=datalink.bmi.emory.edu
export REMOTE_RECEIVING_CSV_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv
export REMOTE_RECEIVING_IMAGE_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image

#### functions
function timeStamp() {
    date +'%Y%m%d_%H_%M_%S'
}

function scp_2_bmi_common() {
    local FILE=$1
    local REMOTE_DEST=$2
    echo "scp $FILE $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$REMOTE_DEST/"
    scp "$FILE" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_DEST"/
}

function scp_image_2_bmi() {
    local FILE=$1
    scp_2_bmi_common "$FILE" "$REMOTE_RECEIVING_IMAGE_DIR"
    local rtCode=$?
    exit $rtCode
}

function scp_csv_2_bmi() {
    local FILE=$1
    mkdir -p ${tmp_dir}
    local nameonly=$( basename "$FILE" )
    cp ${FILE} ${tmp_dir}/${nameonly}
    cd ${tmp_dir}
    local tmpzip=${nameonly}_$( timeStamp ).zip
    zip "$tmpzip" ${nameonly}
    scp_2_bmi_common "$tmpzip" "$REMOTE_RECEIVING_CSV_DIR"
    local rtCode=$?
    rm -rf "$tmpzip"
    cd -
    exit $rtCode
}

function scp2_bmi_not_used() {
    mkdir -p ${tmp_dir}

    local file=$1
    local nameonly=$( basename "$file" )
    cp ${file} ${tmp_dir}/${nameonly}
    cd ${tmp_dir}
    local tmpzip=${nameonly}_$( timeStamp ).zip
    zip "$tmpzip" ${nameonly}
    echo "scp $tmpzip $REMOTE_BMI_USER@$REMOTE_BMI_HOST:$REMOTE_RECEIVING_CSV_DIR/"
    scp "$tmpzip" "$REMOTE_BMI_USER"@"$REMOTE_BMI_HOST":"$REMOTE_RECEIVING_CSV_DIR"/
    local rtCode=$?
    rm -rf "$tmpzip"
    cd -
    return $rtCode
}

#### Main starts
file=$1
echo "${SCRIPT_NAME}: Received $file"
cd ${SCRIPT_DIR}
[[ $file == *csv ]] && scp_csv_2_bmi "${file}"
[[ $file == *txt ]] && scp_csv_2_bmi "${file}"
[[ $file == *log ]] && scp_csv_2_bmi "${file}"
[[ $file == *conf ]] && scp_csv_2_bmi "${file}"
[[ $file == *dcm ]] && scp_image_2_bmi "${file}"
[[ $file == *nii ]] && scp_image_2_bmi "${file}"


