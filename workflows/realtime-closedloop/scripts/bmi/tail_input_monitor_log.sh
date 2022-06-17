
file=$(ls -t /labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow/input_moni*.log | head -n 1)
echo "input_monitor log: $file"
tail -f $file
