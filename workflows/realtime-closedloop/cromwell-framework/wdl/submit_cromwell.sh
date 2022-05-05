#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### pre-defined
apiUrl=http://localhost:9033/api/workflows/v1
wdlFileBase=base_wdl.wdl
inputFileBase=base_input.json
tmpDir=./tmp/$(uuidgen)

wdl_file=${tmpDir}/loop.wdl
json_input=${tmpDir}/input.json

#### functions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}
function print_error() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Error: ${msg}"
}

function print_warning() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Warning: ${msg}"
}

function gen_wdl_and_input() {
    mkdir -p ${tmpDir}
    cp ${wdlFileBase} ${tmpDir}/loop.wdl
    sed "s|wf_realtime_v1.dicomFileInput_TOBEREPLACED|${imagePath}|g" ${inputFileBase} > ${tmpDir}/j1.json
    sed "s|wf_realtime_v1.csvFileName_TOBEREPLACED|${csvfilename}|g" ${tmpDir}/j1.json > ${json_input}
    print_info "jsonInput=${json_input}"
}

function delete_tmp_dir(){
  rm -rf ${tmpDir}
}

function get_id() {
  local key=$1
  local text=$2
  echo "${text}" | jq -r ".${key}"
}

function submit_job(){
  curl -X POST "${apiUrl}" \
      -H "accept: application/json" \
      -H "Content-Type: multipart/form-data" \
      -F "workflowSource=@${wdl_file}" \
      -F "workflowInputs=@${json_input};type=application/json"
}

## cmd="./submit_cromwell.sh ${tmplist}/${nameonly}"
#### Main starts
msg="Calling: ${SCRIPT_NAME} $@"
print_info "${msg}"
print_info "user process started"

noArg=1
if [[ "$#" -ne ${noArg} ]]; then
    print_error "Invalid command line arguments, expecting ${noArg}"
    exit 1
fi

imagePath=$1
nameonly=$(basename -- "$imagePath")
csvfilename="${nameonly%.*}"
csvfilename="${csvfilename%.*}".csv
print_info "imagePath=${imagePath}"
print_info "nameonly=${nameonly}"
print_info "csvfilename=${csvfilename}"
gen_wdl_and_input
response=$(submit_job)
cromwellId=$(get_id "id" "${response}")
print_info "jobId=${cromwellId}"
delete_tmp_dir
## return: {"id":"ae0dde76-e0d8-4cc1-ad5c-27c995d346cc","status":"Submitted"}
## output: /home/pgu6/app/cromwell/cromwell-executions/wf_realtime_v1/ae0dde76-e0d8-4cc1-ad5c-27c995d346cc/call-run/execution/dummy_test.csv