#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
HOME_DIR=/home/nonroot
USER=nonroot
LOG=run_everything.log

####
#### function definitions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME} [$( date +"%m/%d/%Y:%H:%M:%S" )]: ${msg}"
}
####

####
print_info "JOBID=${JOBID}"
print_info "data_in_folder_name=${data_in_folder_name}"

print_info "Current folder: $PWD"
mkdir -p ${HOME_DIR}/raw-data
rm -rf ${HOME_DIR}/raw-data/*
cp -rf /tmp/raw-data/* ${HOME_DIR}/raw-data/
##rm -rf ${HOME_DIR}/processed-data/*   || echo "OK, No files under ${HOME_DIR}/processed-data/ at startup"

cd ${HOME_DIR}/GRAPipeline
print_info "time ./process-run-everything ${HOME_DIR}/raw-data/${data_in_folder_name} 2>&1"
print_info "JOBID=${JOBID} started" >> run_everything.log
time ./process-run-everything ${HOME_DIR}/raw-data/${data_in_folder_name} >> run_everything.log 2>&1 
print_info "JOBID=${JOBID} completed" >> run_everything.log
cp run_everything.log "${HOME_DIR}"/processed-data/


