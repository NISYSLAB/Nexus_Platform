#!/bin/bash

###########################################################################
## This script is submited to slurm by wrapper for running experiment
###########################################################################

## We use loop in this workflow without file monitor systems that integrate with main platform

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EXPR_NAME='Active_learning'
NUM_TRIALS=7
NUM_NEWSUBJECT=20
GRID_SIZE=7
MAPPING_MODEL='resample'
cd ${SCRIPT_DIR}


function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")][${SCRIPT_NAME}]: Info: ${msg}"
}

####
function generateSubject(){
    expr_name=$1
    subject_id=$2
    ## generate the subject with the current model
    local cmd_line="python -u ${SCRIPT_DIR}/neurolib_simulation.py --mode New --subject ${expr_name}-${subject_id} --group random"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "neurolib_simulation.py returned code=${rtn_code}"
}

function copySubject(){
    expr_name=$1
    subject_id=$2
    cp -r ${SCRIPT_DIR}/subjects/${EXPR_NAME}-${subject_id} ${SCRIPT_DIR}/subjects/${expr_name}-${subject_id}
}

function modelResponse(){
    expr_name=$1
    subject_id=$2
    ## generate the stimuli pool, map to the response space and output
    local cmd_line="python -u ${SCRIPT_DIR}/mapping_model_inference.py --gridsize ${GRID_SIZE} --subject ${expr_name}-${subject_id} --model ${MAPPING_MODEL}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "mapping_model_inference.py returned code=${rtn_code}"

}
function selectStimulus(){
    expr_name=$1
    subject_id=$2
    ## feed the response to the classifier and get the best one and corresponding stimulus
    local cmd_line="python -u ${SCRIPT_DIR}/classifier_inference.py --algorithm ${expr_name} --subject ${expr_name}-${subject_id}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "classifier_inference.py returned code=${rtn_code}"

}
function generateTrial() {
    ## generate the neurolib simulation result, would be replaced for real experiment
    expr_name=$1
    subject_id=$2
    ## generate the subject with the current model
    local cmd_line="python -u ${SCRIPT_DIR}/neurolib_simulation.py --mode Trial --subject ${expr_name}-${subject_id} --stimuli next_stimulus.npz"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "neurolib_simulation.py returned code=${rtn_code}"
}
function modelUpdate(){
    ## update the model with the new stimulus and response
    ## also saves intermediate classifier result
    expr_name=$1
    subject_id=$2
    ## classifier update
    local cmd_line="python -u ${SCRIPT_DIR}/classifier_update.py --subject ${expr_name}-${subject_id} --algorithm ${expr_name}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "classifier_update.py returned code=${rtn_code}"
    ## mapping model update
    local cmd_line="python -u ${SCRIPT_DIR}/mapping_model_update.py --subject ${expr_name}-${subject_id} --model ${MAPPING_MODEL}"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "mapping_model_update.py returned code=${rtn_code}"
}

function subjectFlow(){
    expr_name=$1
    subject_id=$2
    # generateSubject ${expr_name} ${subject_id}
    ## we generate the same subject for all 3 experiments and copy the generaged subjects instead
    copySubject ${expr_name} ${subject_id}
    for i in $(seq 1 ${NUM_TRIALS}); do
        modelUpdate ${expr_name} ${subject_id}
        modelResponse ${expr_name} ${subject_id}
        selectStimulus ${expr_name} ${subject_id}
        generateTrial ${expr_name} ${subject_id}
    done
    modelUpdate ${expr_name} ${subject_id}
}

function execMain() {
    acqusition="bnn knn rf logistic random"
    for subject_id in $(seq 1 ${NUM_NEWSUBJECT}); do
        generateSubject ${EXPR_NAME} ${subject_id}
    done
    for subject_id in $(seq 1 ${NUM_NEWSUBJECT}); do
        for expr_name in ${acqusition}; do
            subjectFlow ${expr_name} ${subject_id}
        done
    done
}
timeStart="$(date +'%Y%m%d:%H:%M:%S')"
WORK_DIR=./${EXPR_NAME}-${timeStart}
mkdir -p ${WORK_DIR}
mkdir -p ./subjects
echo "Main workflow started"
time execMain
echo "Main workflow completed"
# # Back up expr scripts
cp ${SCRIPT_DIR}/*.sh ${WORK_DIR}
cp ${SCRIPT_DIR}/*.py ${WORK_DIR}
# Data backup - all data are stored in .npy in script directory because lazy
cp ${SCRIPT_DIR}/*.npy ${WORK_DIR}
cp ${SCRIPT_DIR}/*.npz ${WORK_DIR}
mv ${SCRIPT_DIR}/subjects ${WORK_DIR}
# stdout and error
cp ${SCRIPT_DIR}/*.out ${WORK_DIR}
cp ${SCRIPT_DIR}/*.err ${WORK_DIR}
# Clear previous output
rm ${SCRIPT_DIR}/*.npy
rm ${SCRIPT_DIR}/*.npz
rm ${SCRIPT_DIR}/*.out
rm ${SCRIPT_DIR}/*.err
