
args_count=1
if [[ $# -lt ${args_count} ]]
then
  echo "./tail_job_out.sh jobId"
  exit 1;
fi
job_id=$1

echo "tail -f slurm-${job_id}.out -f"
tail -f slurm-${job_id}.out -f

