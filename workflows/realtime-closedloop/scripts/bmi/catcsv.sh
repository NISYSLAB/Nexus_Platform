
csv=/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/csv/optimizer_out.csv

cat $csv
echo "Entries: $(cat $csv | wc -l)"
