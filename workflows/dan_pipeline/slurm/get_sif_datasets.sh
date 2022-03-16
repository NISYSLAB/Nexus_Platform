data_dir=/labs/mahmoudilab/slurm-jobs/DATASETS
sif_dir=/labs/mahmoudilab/slurm-jobs/SIF
time gsutil cp gs://bmi-gcp-slurm-poc-dataset/*.tar.gz ${data_dir}/
time gsutil cp gs://bmi-gcp-slurm-poc-singularity-image/*.sif .
cp ./*.sif ${sif_dir}/
