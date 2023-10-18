#!/bin/bash

###########################################################################
## This script is submited to slurm by wrapper for running experiment
###########################################################################

## This will use preexisting dataset from real subjects for experiment

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EXPR_NAME='Initial_dataset'
cd ${SCRIPT_DIR}
SIZE=10
GRIDSIZE=7

function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")][${SCRIPT_NAME}]: Info: ${msg}"
}

####
function generateData() {
    mkdir subjects
    local cmd_line="python -u ${SCRIPT_DIR}/neurolib_simulation.py --mode Dataset --size ${SIZE} --gridsize ${GRIDSIZE}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "neurolib_simulation.py returned code=${rtn_code}"
}
function trainMapping() {
    local cmd_line="python -u ${SCRIPT_DIR}/mapping_model_init.py --size ${SIZE} --gridsize ${GRIDSIZE}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "mapping_model_init.py returned code=${rtn_code}"
}
function trainClassifier() {
    local cmd_line="python -u ${SCRIPT_DIR}/classifier_init.py --size ${SIZE} --gridsize ${GRIDSIZE}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "classifier_init.py returned code=${rtn_code}"
}
function execMain() {
    echo "initial training for mapping model"
    time trainMapping
    echo "initial training for classifier"
    time trainClassifier
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
cp ${SCRIPT_DIR}/*.npz ${WORK_DIR}
cp ${SCRIPT_DIR}/*.keras ${WORK_DIR}
mv ${SCRIPT_DIR}/subjects ${WORK_DIR}
# stdout and error
cp ${SCRIPT_DIR}/*.out ${WORK_DIR}
cp ${SCRIPT_DIR}/*.err ${WORK_DIR}
# Clear previous output
rm ${SCRIPT_DIR}/*.npy
rm ${SCRIPT_DIR}/*.npz
rm ${SCRIPT_DIR}/*.keras
rm ${SCRIPT_DIR}/*.out
rm ${SCRIPT_DIR}/*.err
