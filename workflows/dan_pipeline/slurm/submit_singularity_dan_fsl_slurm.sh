#!/bin/bash

####
#SBATCH --partition=beauty-only
#SBATCH -c 8                              # one CPU core per task
#SBATCH --mem=65G                         # total memory per node
#SBATCH -t 30:10:00                       # d-hh:mm:ss
#SBATCH --job-name="Dan_GRAPipeline"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ping.gu@dbmi.emory.edu

#### global settings, functions

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}:[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Info: ${msg}"
}

####
exec_slurm_script=singularity_dan_fsl.slurm
exec_partition=beauty-only

history_log=sbatch_history.log

CMD="sbatch --partition=${exec_partition} ${exec_slurm_script}"
echo "${CMD}"
print_info "${CMD}  - - - - - - - - - - - - - - - - - "  >> ${history_log}
sbatch --partition=${exec_partition} ${exec_slurm_script}

print_info ""  >> ${history_log}

echo "./add_log.sh jobId"



