#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ./rt_prepro_common_settings.sh

echo "Host: MATLAB_VER=${MATLAB_VER}"
echo "Host: MCRROOT=${MCRROOT}"

D4_dcm2nii=$PWD/nii/D4_dcm2nii.nii
pre_nii=$PWD/pre_nii/4D_pre.nii
subject_mask_nii=$PWD/subject_mask_nii/subject_mask.nii
csv_out=$PWD/csv/average_Reward_sig.csv

cmd_line="./run_RT_Preproc.sh ${MCRROOT} ${D4_dcm2nii} ${pre_nii} ${subject_mask_nii} ${csv_out}"

echo "Calling: ${cmd_line}"
time ${cmd_line}


