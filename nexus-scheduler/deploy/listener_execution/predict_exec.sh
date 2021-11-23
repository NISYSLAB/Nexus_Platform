trainData="$1"
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
    print_info "version=${version}"
    print_info "outputs=${outputs}"
    print_info "savedResults=${savedResults}"

    print_info "ENV: WORKFLOW_ID=${WORKFLOW_ID}"
    print_info "ENV: TASK_CALL_NAME=${TASK_CALL_NAME}"
    print_info "ENV: TASK_CALL_ATTEMPT=${TASK_CALL_ATTEMPT}"
    print_info "ENV: DISK_MOUNTS=${DISK_MOUNTS}"
    print_info "ENV: COPY_RESULTS=${COPY_RESULTS}"
}

function extract_folder_name() {
    local tar_file=$1
    local dir_name=`tar -tzf ${tar_file} | head -1 | cut -f1 -d"/"`
    echo ${dir_name}
}

########## execution starts ##########

##print_info "${TASK} started"
##print_sys_info

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

##print_args
## ./ run_model_training.sh ${trainData} ${testData} ${version} ${outputs}
########## check if work folder exist or not ######
if [[ ! -d "${WORK_DIR}" ]] ; then
  print_error "${WORK_DIR} does not exist"
  exit 1
fi

## get MOUNT folder
process_dir="$(dirname "${trainData}")"
rsync -aqr ${WORK_DIR}/* ${process_dir}/
##cp -arf ${WORK_DIR}/* ${process_dir}/

WORK_DIR=${process_dir}

cd ${WORK_DIR}

########## get folder name from tar ##########
train_folder=$( extract_folder_name ${trainData} )
tar -xf ${trainData} --directory  ${WORK_DIR}/
rm -rf ${trainData}

test_folder=test
## if file ends with .tar.gz
if [[ "$testData" == *.tar.gz ]]
then
    test_folder=$( extract_folder_name ${testData} )
    tar -xf ${testData} --directory ${WORK_DIR}/
    rm -rf ${testData}
else
    mkdir -p ${WORK_DIR}/${test_folder}/single_image
    cp ${testData} ${WORK_DIR}/${test_folder}/single_image
fi

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

rm -rf ${test_folder} ${train_folder}

##print_info "tar -zcvf  ${savedResults}.tar.gz ${savedResults} || tar -zcvf ${savedResults}.tar.gz save_predict || tar -zcvf ${savedResults}.tar.gz save_results"
tar -zcvf  ${savedResults}.tar.gz ${savedResults} || tar -zcvf ${savedResults}.tar.gz save_predict || tar -zcvf ${savedResults}.tar.gz save_results

rtn_code=$?
print_info "${TASK} tar command returned code=${rtn_code}"
if [[ "${rtn_code}" != "0" ]]; then
    print_error "${TASK} tar command threw errors, exit with code 25"
    rm -rf save_predict
    rm -rf ${savedResults}
    rm -rf save_results
    print_info "${TASK} ended"
    exit 25
fi

rm -rf ${savedResults}
rm -rf save_predict
rm -rf save_results

print_info "${TASK} ended"

if [[ "${COPY_RESULTS}" == "Y" ]]; then
  ##print_info "mv /root/work/${savedResults}.tar.gz ${DISK_MOUNTS}/"
  mv ${WORK_DIR}/${savedResults}.tar.gz ${DISK_MOUNTS}/
fi