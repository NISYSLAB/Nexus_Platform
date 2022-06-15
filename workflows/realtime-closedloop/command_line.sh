#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MATLAB_VER=R2021b
MCRROOT=/usr/local/MATLAB/${MATLAB_VER}
MCC=/usr/local/MATLAB/R2021b/bin/mcc
SRC=rtPreprocessing_simple_new
EXEC_DIR=/home/pgu6/realtime-closedloop
RUN_SCRIPT=run_rtPreprocessing_simple_new.sh

nii_file=$EXEC_DIR/nii/20161206_110626mbep2dEffort1s003a001_567.nii
pre_nii=$EXEC_DIR/4D_pre.nii
csv_out=$EXEC_DIR/csv/biomarker.csv
EXEC_CMD="./${RUN_SCRIPT} ${MCRROOT} ${nii_file} ${pre_nii} ${csv_out}"

####
echo "Enter Matlab Console: matlab -nodisplay -nosplash"
echo "cd ${EXEC_DIR}"
echo ">> compile_files"
echo ">> exit"
echo "Run in host: "
echo "cd ${EXEC_DIR}"
echo "$ time ${EXEC_CMD}"

####
cd $EXEC_DIR

time ${EXEC_CMD}

#3./${RUN_SCRIPT} /usr/local/MATLAB/${MATLAB_VER} ~/trial_instance/4D_trial.nii ~/experiment/4D_pre.nii ~/trial_instance/biomarker.csv


