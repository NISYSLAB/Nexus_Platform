#!/bin/bash

source ./common_settings.sh

export CROMWELL_PORT=${cromwell_port}
echo "CROMWELL_PORT=${cromwell_port}"
export log_file=${cromwell_log}
mkdir -p "$(dirname "$cromwell_log")"

export CONFIG_FILE=/home/pgu6/app/cromwell/.config/local_backend_local_filesystems.conf

###########################################################################
clear
echo "log_file=${log_file}
echo "##################### Started Cromwell Engine on: $(date +%Y-%m-%d:%H:%M:%S) ############" 

#### which mode
## read -p "Use Slurm? (y/n): " use_slurm
## echo "You answer: ${use_slurm}"
## [[ ${use_slurm} == [yY] ]] &&  CONFIG_FILE=local_backend_slurm.conf 

export CONFIG_FILE=${CONFIG_FILE}
echo "CONFIG_FILE=${CONFIG_FILE}"
#### end of which mode

#### kill running cromwell instance
./kill_cromwell_instance.sh

sleep 2

touch ${log_file}
./start_cromwell_basic.sh  > ${log_file} 2>&1 &

echo "logfile: ${log_file}"
echo "tail -f ${log_file}"

