
log=sbatch_history.log
jobid=$1

echo "[$(date -u +"%m/%d/%Y:%H:%M:%S")]: Submitted Job: ${jobid}" >> ${log}

