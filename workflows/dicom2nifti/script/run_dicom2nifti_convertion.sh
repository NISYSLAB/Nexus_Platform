#!/bin/bash
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

########## Predefined variables ##########
WORK_DIR="/app"
OUTPUT_DIR=result_nifti
DRIVER="dicom2nifti"

######## Inputs from GCP buckets #########
input=""
result=""
cmd_options=""

########## function definitions##########
function print_sys_info() {
  print_info "System Specs: $( uname -a )"
  print_info $(cat /etc/os-release )
}

function print_error() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Error: ${msg}"
}

function print_info() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function print_warning() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Warning: ${msg}"
}

function print_args() {
    print_info "input=${input}"
    print_info "result=${result}"
    print_info "cmd_options=${cmd_options}"
    print_info "size of $(filenameonly ${input} ):"
    ls -alt ${input}
}

function filenameonly() {
    local path=$1
    local filename=$(basename -- "$path")
    echo ${filename}
}

function extract_folder_name() {
    local tar_file=$1
    local dir_name=`tar -tzf ${tar_file} | head -1 | cut -f1 -d"/"`
    echo ${dir_name}
}

########## execution starts ##########
print_info "SCRIPT_NAME=${SCRIPT_NAME} "
print_info "SCRIPT_DIR=${SCRIPT_DIR}"
print_info "LOCAL_USER=$(whoami)"
print_info "WORK_DIR=${WORK_DIR}"
print_info "OUTPUT_DIR=${OUTPUT_DIR}"
print_info "DRIVER=${DRIVER}"
print_sys_info
print_info "${SCRIPT_NAME} started at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"


########## check arguments ##########
msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"

echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: user process started"
echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: user process started" >> /dev/stderr

if [[ "$#" -ne 3 ]]; then
    print_error "Invalid arguments"
    exit 1
fi

########## Collect inputs ##########
input="$1"
result="$2"
cmd_options="$3"
print_args

########## check if /app exist or not ######
if [[ ! -d "${WORK_DIR}" ]] ; then
  print_error "${WORK_DIR} does not exist"
  exit 1
fi

print_info "WORK_DIR exist: ${WORK_DIR}"

cp ${input} ${WORK_DIR}/input_dicom_images.tar.gz

print_info "after copy, run: rm -rf ${input}"
rm -rf ${input}

mkdir -p ${WORK_DIR}/${OUTPUT_DIR}
cd ${WORK_DIR}
########## get folder name from tar ##########
input_folder=$( extract_folder_name input_dicom_images.tar.gz )
print_info "input_dicom_images.tar.gz input_folder: ${input_folder}"

tar -xf input_dicom_images.tar.gz
rm -rf input_dicom_images.tar.gz

print_info "Current directory: $(pwd) info:"
ls

print_info "Calling: time ${DRIVER} ${cmd_options} ${input_folder} ${OUTPUT_DIR}"
time ${DRIVER} ${cmd_options} ${input_folder} ${OUTPUT_DIR}

rtn_code=$?
print_info "${DRIVER} command returned code=${rtn_code} from command: ${DRIVER} ${cmd_options} ${input_folder} ${OUTPUT_DIR} "
if [[ "${rtn_code}" != "0" ]]; then
    print_error "${DRIVER} user's coding threw errors, exit with code 25"
    print_info "${DRIVER} ended at $(date +"%m/%d/%Y:%R")"
    exit 25
fi

print_info "after command: ${DRIVER}, run: rm -rf ${input_folder}"
rm -rf ${input_folder}

print_info "Calling: tar -czf ${result}.tar.gz ${OUTPUT_DIR}"
tar -czf ${result}.tar.gz ${OUTPUT_DIR}

rtn_code=$?
print_info "tar command returned code=${rtn_code} from command: tar -czf ${result}.tar.gz ${OUTPUT_DIR}"
if [[ "${rtn_code}" != "0" ]]; then
    print_error "tar result threw errors, exit with code 25"
    print_info "${SCRIPT_NAME} ended at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"
    exit 25
fi

[[ $(ls -A ${OUTPUT_DIR}) ]] || print_warning "result directory=${OUTPUT_DIR} is empty"
print_info "${OUTPUT_DIR}:"
ls -alt ${${OUTPUT_DIR}}

print_info "${PWD} info:"
ls

print_info "result:"
ls -alt ${result}.tar.gz
print_info "${SCRIPT_NAME} ended at [$(date -u +"%m/%d/%Y:%H:%M:%S")]"