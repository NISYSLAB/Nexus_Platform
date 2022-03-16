#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### workflow
wf_uuid=$(uuidgen)
dataset_dir=/labs/mahmoudilab/synergy_slurm/dataset
sif_repo_dir=/labs/mahmoudilab/synergy_slurm/sif
wf_dir=/labs/mahmoudilab/synergy_slurm/output/${wf_uuid}

## training
train_model=train_model.py
train_dataset=${dataset_dir}/100_training_dataset.tar.gz
##train_dataset=100_training_dataset.tar.gz
training_sif_image=python-classifier-2021_1.0-slurm.sif
training_exec_script=./stepTraining_python_r_julie_injection_command.sh
training_cmd_inputs="${train_dataset} ${train_model} ${train_model} ${train_model} ${wf_dir}/training python"
training_command="${training_sif_image} ${training_exec_script} ${training_cmd_inputs}"
training_output=${wf_dir}/training/trainings.tar.gz

## testing
test_model=test_model.py
test_dataset=${dataset_dir}/100_training_dataset.tar.gz
testing_sif_image=python-classifier-2021_1.0-slurm.sif
testing_exec_script=./stepTesting_python_r_julie_injection_command.sh
testing_cmd_inputs="${test_dataset} ${test_model} ${test_model} ${test_model} ${wf_dir}/testing ${training_output} python"
testing_command="${testing_sif_image} ${testing_exec_script} ${testing_cmd_inputs}"
testing_output=${wf_dir}/testing/predictions.tar.gz

## scoring
eval_model=evaluate_model.py
eval_helper_code=helper_code.py
eval_input_label=${dataset_dir}/100_training_dataset.tar.gz
eval_input_csv=${dataset_dir}/Mapping_N_Weights.tar.gz
scoring_sif_image=python3_2.0_slurm.sif
scoring_exec_script=./stepScoring_all_langs_injection_command.sh
scoring_cmd_inputs="${eval_model} ${testing_output} ${eval_input_label} ${wf_dir}/scoring ${eval_input_csv} ${eval_helper_code}"
scoring_command="${scoring_sif_image} ${scoring_exec_script} ${scoring_cmd_inputs}"
scoring_output=${wf_dir}/scoring/scores.psv

####
##module load singularity/3.8.3
bind_opt="--bind ${dataset_dir}:${dataset_dir}"

singularity exec ${bind_opt} ${training_command} && \
singularity exec ${bind_opt} ${testing_command} && \
singularity exec ${bind_opt} ${scoring_command}


echo "output=${wf_dir}/scoring/scores.psv"




