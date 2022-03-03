#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
OUTPUT_DIR=/labs/mahmoudilab/synergy_remote_data1/gra/gra_file_out_dir

####
image_tag=1.1
os_ver=ubuntu-20210921
#### for non-fsl
image_name=us.gcr.io/cloudypipelines-com/huddleston-${os_ver}

########
data_dir=/tmp
script_dir=/home/pgu6/app/listener/fMri_realtime/listener_execution/gra
run_script=${script_dir}/gra_call_run_everything.sh

## inside container
HOME_DIR=/home/nonroot
USER=nonroot

#### function definitions
function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME} [$( date +"%m/%d/%Y:%H:%M:%S" )]: ${msg}"
}

function extract_folder_name_from_tar() {
    local tar_file=$1
    local dir_name=`tar -tzf ${tar_file} | head -1 | cut -f1 -d"/"`
    echo ${dir_name}
}

function extract_folder_name_from_zip() {
    local zip_file=$1
    local dir_name=$(unzip -qql ${zip_file} | head -n1 | awk '{print $4}' | cut -f1 -d"/" )
    echo ${dir_name}
}
function interactiveRun() {
    local UUID=$(uuidgen)
    local CMD="${HOME_DIR}/app_scripts/gra_call_run_everything.sh"
    print_info "Command=${CMD}"
    container_id="huddleston-${UUID}"
    print_info "container_id=${container_id}"

    ## make output accessible
    mkdir -p "${PWD}"/${data_in_folder_name}_out
    chmod -R 777 "${PWD}"/${data_in_folder_name}_out

## -v "$PWD"/app_scripts/:${HOME_DIR}/app_scripts/ \
    docker run --rm -t \
        --name "${container_id}" \
        -e JOBID="${UUID}" \
        -e data_in_folder_name="${data_in_folder_name}" \
        -v "${PWD}"/${data_in_folder_name}/:"${data_dir}"/raw-data/${data_in_folder_name}/ \
        -v "${PWD}"/${data_in_folder_name}_out/:"${HOME_DIR}"/processed-data/ \
        -v "$PWD"/app_scripts/:${HOME_DIR}/app_scripts/ \
        -v "${script_dir}"/:"${script_dir}"/ \
        "${image_name}":"${image_tag}" \
        /bin/bash "${CMD}" > docker_run.log 2>&1
}

function file_copy_check() {
  local file=$1

  local oldsize=$(wc -c <"$file")
  print_info "oldsize=$oldsize"
  sleep 2
  local newsize=$(wc -c <"$file")
  print_info "newsize=$newsize"

  while [ "$oldsize" -lt "$newsize" ]
  do
     print_info "$file growing, still copying ..."
     oldsize=$(wc -c <"$file")
     sleep 2
     newsize=$(wc -c <"$file")
  done

  if [ "$oldsize" -eq "$newsize" ]
  then
     print_info "The copying is done for file: $file!"
  fi

}
function pre_run() {
    ## sometime the file is large, put to sleep to make sure it is ready
    ## unzip input files
    cp ${data_path} ./${data_name}
    data_in_folder_name=$( extract_folder_name_from_zip "${data_name}" )

    time unzip ${data_name}
    sleep 2
    print_info "rm -rf ${data_name}"
    rm -rf ${data_name}
    rm -rf ${data_path}

    ## app script
    mkdir -p app_scripts
    cp ${run_script} ./app_scripts/

}

function push_output() {
    cd ${data_in_folder_name}_out
    zip -r ${data_in_folder_name}_outputs.zip ${data_in_folder_name}/outputs
    print_info "move  ${data_in_folder_name}_outputs.zip to  ${OUTPUT_DIR}/"
    mv ${data_in_folder_name}_outputs.zip ${OUTPUT_DIR}/
    cd -
}

###############################
#### Main entry
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

data_name=$1
data_path=$2
print_info "data_name=$data_name"
print_info "data_path=$data_path"
data_in_folder_name=""

sleep 5
file_copy_check ${data_path}

sleep 3
pre_run
print_info "data_in_folder_name=$data_in_folder_name"
time interactiveRun
print_info "docker interactiveRun completed!"

time push_output
print_info "push_output completed!"

print_info "Delete ./${data_in_folder_name}"
rm -rf ./${data_in_folder_name}

