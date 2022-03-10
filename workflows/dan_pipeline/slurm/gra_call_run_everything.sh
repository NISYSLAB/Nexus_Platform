#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
HOME_DIR=/home/nonroot
USER=nonroot

####
#### function definitions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}:[$( date +"%m/%d/%Y:%H:%M:%S" )]: ${msg}"
}

function pre_process() {
  local file=$1
  mkdir -p ${HOME_DIR}/raw-data
  rm -rf ${HOME_DIR}/raw-data/*
  local processed_file=processed.tar.gz

  if [[ $file == *zip ]] # * is used for pattern matching
  then
    processed_file=processed.zip
    cp ${file} ${HOME_DIR}/raw-data/${processed_file}
    cd ${HOME_DIR}/raw-data
    unzip ${processed_file}
    rm -rf ${processed_file}
    print_info "After unzip: folder info:"
    ls
    data_in_folder_name=$( ls )
    cd -
  else
    processed_file=processed.tar.gz
    cp ${file} ${HOME_DIR}/raw-data/${processed_file}
    cd ${HOME_DIR}/raw-data
    tar -xf ${processed_file}
    rm -rf ${processed_file}
    print_info "After untar: folder info:"
    ls
    data_in_folder_name=$( ls )
    cd -
  fi

}

#### main starts
args_count=3
if [[ $# -lt ${args_count} ]]
then
  pring_info "Invalid command line arguments, expecting ${args_count}" 
  exit 1;
fi

input_path=$1
wf_uuid=$2
wf_dir=$3
data_in_folder_name=""

mkdir -p ${wf_dir}

runtime_home_dir="/home/$( whoami )"
mkdir -p ${runtime_home_dir}

cp -rf ${HOME_DIR}/* ${runtime_home_dir}/

HOME_DIR=${runtime_home_dir}

pre_process ${input_path}

####
print_info "runtime_user=$( whoami )"
print_info "runtime_home=$HOME"
print_info "input_path=${input_path}"
print_info "wf_uuid=${wf_uuid}"
print_info "wf_dir=${wf_dir}"
print_info "data_in_folder_name=${data_in_folder_name}"
print_info "Current folder: $PWD file listing: "
ls -alt ./ 

print_info "Folder: ${HOME_DIR}/raw-data file listing: "
ls -alt ${HOME_DIR}/raw-data/*

mkdir -p ${HOME_DIR}/GRAPipeline
cd ${HOME_DIR}/GRAPipeline
print_info "${HOME_DIR}/GRAPipeline file listings:"
ls -alt ${HOME_DIR}/GRAPipeline

print_info "wf_uuid=${wf_uuid} started"
print_info "time ./process-run-everything ${HOME_DIR}/raw-data/${data_in_folder_name}"
time ./process-run-everything ${HOME_DIR}/raw-data/${data_in_folder_name}

OUTPUT_DIR=${wf_dir}/${data_in_folder_name}
mkdir -p ${OUTPUT_DIR}
##  ~/processed-data/CR0343/outputs
mv ${HOME_DIR}/processed-data/${data_in_folder_name}/outputs ${OUTPUT_DIR}/ 

print_info "OUTPUT=${OUTPUT_DIR}/outputs"
print_info "wf_uuid=${wf_uuid} completed"


