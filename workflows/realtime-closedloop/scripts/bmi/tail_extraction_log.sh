
file=$(ls -t /labs/mahmoudilab/synergy_remote_data1/logs/rtcl/trial_extraction/extraction_monitor*.log | head -n 1)
echo "extraction log: $file"
tail -f $file
