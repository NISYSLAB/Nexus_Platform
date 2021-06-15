#!/bin/bash
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

########## Predefined variables ##########
TASK=modelTraining
WORK_DIR="/root/work"
DRIVER="python model_train.py"

######## Inputs from GCP buckets #########
trainData=""
testData=""
version=""
outputs=""
savedResults=""

########## function definitions##########
function filenameonly() {
    local path=$1
    local filename=$(basename -- "$path")
    echo ${filename}
}

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
    print_info "trainData=${trainData}"
    print_info "testData=${testData}"
    print_info "version=${version}"
    print_info "outputs=${outputs}"
    print_info "savedResults=${savedResults}"

    print_info "ENV: WORKFLOW_ID=${WORKFLOW_ID}"
    print_info "ENV: TASK_CALL_NAME=${TASK_CALL_NAME}"
    print_info "ENV: TASK_CALL_ATTEMPT=${TASK_CALL_ATTEMPT}"
    print_info "ENV: DISK_MOUNTS=${DISK_MOUNTS}"
    print_info "ENV: COPY_RESULTS=${COPY_RESULTS}"

    print_info "size of $( filenameonly ${trainData} ):"
    ls -alt ${trainData}
    print_info "checksum of $( filenameonly ${trainData} ):"
    cksum ${trainData}

    print_info "size of $( filenameonly ${testData} ):"
    ls -alt ${testData}
    print_info "checksum of $( filenameonly ${testData} ):"
    cksum ${testData}
}

function extract_folder_name() {
    local tar_file=$1
    local dir_name=`tar -tzf ${tar_file} | head -1 | cut -f1 -d"/"`
    echo ${dir_name}
}

########## execution starts ##########
print_info "SCRIPT_NAME=${SCRIPT_NAME}"
print_info "SCRIPT_DIR=${SCRIPT_DIR}"
print_info "LOCAL_USER=$(whoami)"
print_info "WORK_DIR=${WORK_DIR}"

print_info "${TASK} started"
print_sys_info

########## check arguments ##########
msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"

argCount=5
if [[ "$#" -ne ${argCount} ]]; then
    print_error "Invalid arguments: expecting ${argCount}, actually passing: $#"
    exit 1
fi

########## Collect inputs ##########
## ./run_model_training.sh ${trainData} ${testData} ${version} ${outputs}
trainData="$1"
testData="$2"
version="$3"
outputs="$4"
savedResults="$5"

print_args

########## check if work folder exist or not ######
if [[ ! -d "${WORK_DIR}" ]] ; then
  print_error "${WORK_DIR} does not exist"
  exit 1
fi

print_info "${WORK_DIR} exists"

cp ${trainData} ${WORK_DIR}/train_data.tar.gz
print_info "after copy, run: rm -rf ${trainData}"
rm -rf ${trainData}

cp ${testData} ${WORK_DIR}/test_data.tar.gz
print_info "after copy, run: rm -rf ${testData}"
rm -rf ${testData}

mkdir -p ${WORK_DIR}/${outputs}
cd ${WORK_DIR}

########## get folder name from tar ##########
train_folder=$( extract_folder_name train_data.tar.gz )
print_info "train_data.tar.gz expand_folder: ${train_folder}"

test_folder=$( extract_folder_name test_data.tar.gz )
print_info "test_data.tar.gz expand_folder: ${test_folder}"

########## prepare data##########
tar -xf train_data.tar.gz
rm -rf train_data.tar.gz

tar -xf test_data.tar.gz
rm -rf test_data.tar.gz

print_info "Directory: ${WORK_DIR} info:"
ls ${WORK_DIR}

CMD="${DRIVER} --train_path $PWD/${train_folder}/ --test_path $PWD/${test_folder}/ --trained_model $PWD/${outputs}/ --save_dir $PWD/${savedResults}/ --version ${version}"
## python model_train.py --train_path /path_to/data_binary/train/ --test_path /path_to/data_binary/test/ --trained_model /path_to_SAVE_trained_model/ --save_dir /path_to_SAVE_save_results/ --version 1
print_info "time ${CMD}"
time ${CMD}

rtn_code=$?
print_info "${TASK} command returned code=${rtn_code}"
if [[ "${rtn_code}" != "0" ]]; then
    print_error "${TASK} user's coding threw errors, exit with code 25"
    print_info "${TASK} ended"
    exit 25
fi

ls

print_info "after finish ${CMD}"
print_info "rm -rf ${train_folder} ${test_folder}"
rm -rf ${train_folder} ${test_folder}

print_info "tar -czf ${outputs}.tar.gz ${outputs} || tar -czf ${outputs}.tar.gz save_results"
tar -czf ${outputs}.tar.gz ${outputs} || tar -czf ${outputs}.tar.gz save_results

rtn_code=$?
print_info "${TASK} tar command returned code=${rtn_code}"
if [[ "${rtn_code}" != "0" ]]; then
    print_error "${TASK} tar command threw errors, exit with code 25"
    print_info "${TASK} ended"
    exit 25
fi

print_info "Delete ${outputs}"
rm -rf ${outputs}

print_info "tar -czf ${savedResults}.tar.gz ${savedResults}"
tar -czf ${savedResults}.tar.gz ${savedResults}

rtn_code=$?
print_info "${TASK} tar command returned code=${rtn_code}"
if [[ "${rtn_code}" != "0" ]]; then
    print_error "${TASK} tar command threw errors, exit with code 25"
    print_info "${TASK} ended"
    exit 25
fi

print_info "Delete ${savedResults}"
rm -rf ${savedResults}

print_info "${TASK} output size:"
ls -alt *.tar.gz
print_info "${TASK} ended"

if [[ "${COPY_RESULTS}" == "Y" ]]; then
  print_info "mv /root/work/${outputs}.tar.gz ${DISK_MOUNTS}/"
  mv /root/work/${outputs}.tar.gz ${DISK_MOUNTS}/

  print_info "mv /root/work/${savedResults}.tar.gz ${DISK_MOUNTS}/"
  mv /root/work/${savedResults}.tar.gz ${DISK_MOUNTS}/

  ls -alt ${DISK_MOUNTS}/
fi
