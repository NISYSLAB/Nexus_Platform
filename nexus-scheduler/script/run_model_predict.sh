#!/bin/bash
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

########## Predefined variables ##########
TASK=modelPredict
WORK_DIR="/root/work"
DRIVER="python model_predict.py"

######## Inputs from GCP buckets #########
## ./run_model_predict.sh ${trainedModelData} ${testData} ${version} ${outputs}
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
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")][${SCRIPT_NAME}]: Info: ${msg}"
}

function print_warning() {
    local msg=$1
    echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Warning: ${msg}"
}

function print_args() {
    print_info "trainData=${trainData}"
    print_info "testData=${testData}"
    print_info "testDataFileName=$testDataFileName"
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
## ./run_model_predict.sh ${trainedModelData} ${testData} ${version} ${outputs}
trainData="$1"
testData="$2"
version="$3"
outputs="$4"
savedResults="$5"

testDataFileName="$(basename "${testData}" )"

print_args
## ./ run_model_training.sh ${trainData} ${testData} ${version} ${outputs}
########## check if work folder exist or not ######
if [[ ! -d "${WORK_DIR}" ]] ; then
  print_error "${WORK_DIR} does not exist"
  exit 1
fi

print_info "${WORK_DIR} exists"

cp ${trainData} ${WORK_DIR}/train_data.tar.gz
print_info "after copy, run: rm -rf ${trainData}"
rm -rf ${trainData}

cp "${testData}" ${WORK_DIR}/"${testDataFileName}"
print_info "after copy, run: rm -rf ${testData}"
rm -rf "${testData}"

cd ${WORK_DIR}

########## get folder name from tar ##########
train_folder=$( extract_folder_name train_data.tar.gz )
print_info "train_data.tar.gz expand_folder: ${train_folder}"
tar -xf train_data.tar.gz
rm -rf train_data.tar.gz

test_folder="test"
if [[ "${testDataFileName}" == *tar.gz ]]
then
    test_folder=$( extract_folder_name test_data.tar.gz )
    print_info "test_data.tar.gz expand_folder: ${test_folder}"
    tar -xf test_data.tar.gz
    rm -rf test_data.tar.gz
else
    test_folder="test"
    mkdir -p ${test_folder}
    mv "${testDataFileName}" "${test_folder}"/
fi

########
print_info "Directory: ${WORK_DIR} info:"
ls ${WORK_DIR}

CMD="${DRIVER} --test_path $PWD/${test_folder}/ --trained_model $PWD/${train_folder}/trained_model/ --save_predict $PWD/${savedResults}/ --version ${version}"
## python model_predict.py --test_path /path_to/data_binary/test/ --trained_model /path_to/trained_model/ --save_predict /path_to_SAVE_prediction_results/ --version 1
print_info "time ${CMD}"
time ${CMD}

rtn_code=$?
print_info "${TASK} command returned code=${rtn_code}"
if [[ "${rtn_code}" != "0" ]]; then
    print_error "${TASK} user's coding threw errors, exit with code 25"
    print_info "${TASK} ended"
    exit 25
fi

print_info "rm -rf ${test_folder} ${train_folder}"
rm -rf "${test_folder}" "${train_folder}"

print_info "tar -zcvf  ${savedResults}.tar.gz ${savedResults} || tar -zcvf ${savedResults}.tar.gz save_predict || tar -zcvf ${savedResults}.tar.gz save_results"
tar -zcvf  ${savedResults}.tar.gz ${savedResults} || tar -zcvf ${savedResults}.tar.gz save_predict || tar -zcvf ${savedResults}.tar.gz save_results

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
  print_info "mv /root/work/${savedResults}.tar.gz ${DISK_MOUNTS}/"
  mv /root/work/${savedResults}.tar.gz ${DISK_MOUNTS}/

  ls -alt ${DISK_MOUNTS}/
fi
