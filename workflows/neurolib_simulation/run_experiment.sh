#!/bin/bash

###########################################################################
## This script is submited to slurm by wrapper for running experiment
###########################################################################

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EXPR_NAME='BabySteps'
cd ${SCRIPT_DIR}

####
function generateData() {
    python -u ${SCRIPT_DIR}/neurolib_simulation.py
}
function activeLearn() {
    python -u ${SCRIPT_DIR}/active_learner.py
}
function execMain() {
    echo "generating dataset"
    time generateData
    echo "performing active learning analysis"
    time activeLearn
}
timeStart="$(date +'%Y%m%d:%H:%M:%S')"
WORK_DIR=/labs/mahmoudilab/Nexus_simulation_yusen/${EXPR_NAME}-${timeStart}
mkdir -p ${WORK_DIR}
echo "Main workflow started"
time execMain
echo "Main workflow completed"
# Back up expr scripts
cp ${SCRIPT_DIR}/*.sh ${WORK_DIR}
cp ${SCRIPT_DIR}/*.py ${WORK_DIR}
# Data backup - all data are stored in .npy in script directory because lazy
cp ${SCRIPT_DIR}/*.npy ${WORK_DIR}
# stdout and error
cp ${SCRIPT_DIR}/*.out ${WORK_DIR}
cp ${SCRIPT_DIR}/*.err ${WORK_DIR}
rm ${SCRIPT_DIR}/*.out
rm ${SCRIPT_DIR}/*.err
