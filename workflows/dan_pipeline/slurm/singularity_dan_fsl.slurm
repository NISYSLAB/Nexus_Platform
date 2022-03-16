#!/bin/bash

####
#SBATCH --partition=beauty-only
#SBATCH -c 10                            # one CPU core per task
#SBATCH --mem=65G                         # total memory per node
#SBATCH -t 30:10:00                      # d-hh:mm:ss
#SBATCH --job-name="Dan_GRAPipeline"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ping.gu@dbmi.emory.edu
####

volumn_mapping_root=/labs/mahmoudilab/synergy_slurm
mnt_dataset=${volumn_mapping_root}/dataset
mnt_sif=${volumn_mapping_root}/sif
## mnt_dataset=/labs/mahmoudilab/slurm-jobs/DATASETS
## mnt_sif=/opt/ssd-data/pgu6/slurm-jobs/SIF

#### workflow
wf_uuid=$(uuidgen)
dataset_used=CR0343.tar.gz
dataset_dir=${mnt_dataset}
wf_dir=${volumn_mapping_root}/execution/${wf_uuid}

bind_opt="--bind ${wf_dir},${PWD},${volumn_mapping_root},/opt/ssd-data/pgu6/slurm-jobs,/labs/mahmoudilab/slurm-jobs,/tmp"

#### gra pipeline run everything
run_script=${PWD}/gra_call_run_everything.sh

## inside container
HOME_DIR=/home/nonroot
USER=nonroot

input_dataset=${dataset_dir}/${dataset_used}
data_path=${input_dataset}
data_name=$(basename ${input_dataset})
sif_image=${mnt_sif}/huddleston-ubuntu-20210921-1_1.sif
cmd_inputs="${data_path} ${wf_uuid} ${wf_dir}"
exec_cmd="${sif_image} ${run_script} ${cmd_inputs}"
## ??  todo: data_output=${wf_dir}/training/trainings.tar.gz 

#### functions
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: [$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

function file_copy_check() {
  local file=$1

  local oldsize=$(wc -c <"$file")
  print_info "oldsize=$oldsize"
  sleep 3
  local newsize=$(wc -c <"$file")
  print_info "newsize=$newsize"

  while [ "$oldsize" -lt "$newsize" ]
  do
     print_info "$file growing, still copying ..."
     oldsize=$(wc -c <"$file")
     sleep 3
     newsize=$(wc -c <"$file")
  done

  if [ "$oldsize" -eq "$newsize" ]
  then
     print_info "The copying is done for file: $file!"
  fi
}

function run_gra_everything() {
    print_info "run_gra_everything(): time singularity exec ${bind_opt} ${exec_cmd}"
    time singularity exec ${bind_opt} ${exec_cmd}
}

function run_main() {
  print_app_info
  sleep 3
  file_copy_check ${data_path}

  sleep 3
  mkdir -p ${wf_dir}
  cd ${wf_dir}
  run_gra_everything

}

function print_app_info(){
    print_info "volumn_mapping_root=$volumn_mapping_root"
    print_info "mnt_dataset=$mnt_dataset"
    print_info "mnt_sif=$mnt_sif"
    print_info "dataset_used=$dataset_used"
    print_info "dataset_dir=$dataset_dir"
    print_info "data_name=$data_name"
    print_info "data_path=$data_path"
    print_info "wf_uuid=$wf_uuid"
    print_info "wf_dir=$wf_dir"
    print_info "mnt_sif=$mnt_sif"
    print_info "bind_opt=$bind_opt"
    print_info "run_script=$run_script"
    print_info "Inside container: HOME_DIR=$HOME_DIR"
    print_info "Inside container: USER=$USER"
}

#### end of functions

##module load singularity/3.8.3
## You can bind multiple directories in a single command with this syntax:
## singularity shell --bind /opt,/data:/mnt my_container.sif
## If dest is not given, it is set equal to src

time run_main
