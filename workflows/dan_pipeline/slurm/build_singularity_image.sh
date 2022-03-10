#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####
image_docker=us.gcr.io/cloudypipelines-com/huddleston-ubuntu-20210921:1.1
image_singularity=huddleston-ubuntu-20210921-1_1.sif
repo_sif=/labs/mahmoudilab/synergy_slurm/sif

echo "time singularity pull --name ${image_singularity} docker://${image_docker}"
time singularity pull --name ${image_singularity} docker://${image_docker}
echo "time singularity pull --name ${image_singularity} docker://${image_docker}"

echo "Copy SIF $${image_singularity}  to ${repo_sif}"
if [[ $repo_sif == gs://* ]] # * is used for pattern matching
  gsutil cp ${image_singularity} ${repo_sif}/
  echo "gsutil cp ${image_singularity} ${repo_sif}/"
else
  mv ${image_singularity} ${repo_sif}/
  echo "mv ${image_singularity} ${repo_sif}/"
fi

gsutil cp ./*.sif gs://bmi-gcp-slurm-poc-singularity-image/
