#!/bin/bash

###########################################################################
## This script is submited to slurm by wrapper for running experiment
###########################################################################

## We use loop in this workflow without file monitor systems that integrate with main platform

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EXPR_NAME='Bayesian_optimization'
NUM_TRIALS=14
NUM_NEWSUBJECT=20
cd ${SCRIPT_DIR}


function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")][${SCRIPT_NAME}]: Info: ${msg}"
}

function selectStimulus(){
    expr_name=$1
    script_name="fMRI_Bayesian_optimization.py"
    trial=$3
    ## feed the response to the classifier and get the best one and corresponding stimulus
    local cmd_line="python -u ${SCRIPT_DIR}/${script_name} --subject ${expr_name}-${subject_id} --savename results.csv --objectivename trial_${trial}.npz"
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
    local cmd_line="python -u ${SCRIPT_DIR}/simple_gaussian.py --mode ${expr_name} --subject ${expr_name}-${subject_id} --stimuli next_stimulus.npz"
    print_info "Calling: time ${cmd_line}"
    time ${cmd_line}
    rtn_code=$?
    print_info "simple_gaussian.py returned code=${rtn_code}"
}

function subjectFlow(){
    expr_name=$1
    subject_id=$2
    mkdir -p ${SCRIPT_DIR}/subjects/${expr_name}-${subject_id}
    # generateSubject ${expr_name} ${subject_id}
    ## we generate the same subject for all 3 experiments and copy the generaged subjects instead
    for i in $(seq 0 ${NUM_TRIALS}); do
        selectStimulus ${expr_name} ${subject_id} ${i}
        generateTrial ${expr_name} ${subject_id}
    done
    selectStimulus ${expr_name} ${subject_id} ${NUM_TRIALS}
}

function execMain() {
    exprs="bump dent"
    for expr_name in ${exprs}; do
        for subject_id in $(seq 1 ${NUM_NEWSUBJECT}); do
            subjectFlow ${expr_name} ${subject_id}
        done
    done
}
timeStart="$(date +'%Y%m%d:%H:%M:%S')"
WORK_DIR=./${EXPR_NAME}-${timeStart}
SUBJECT_DIR=./subjects
mkdir -p ${WORK_DIR}
mkdir -p ${SUBJECT_DIR}
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
