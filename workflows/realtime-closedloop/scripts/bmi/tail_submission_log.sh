
file=$(ls -t /labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow/submission_s*.log | head -n 1)
echo "submission log: $file"
tail -f $file
