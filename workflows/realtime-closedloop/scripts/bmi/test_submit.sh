srcDir=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/dcm
## dcmFile=dcm_1_5-6-2022.tar.gz
dcmFile=dcm_2_5-6-2022.tar.gz
##dcmFile=dcm_3_5-6-2022.tar.gz

./submit_non_cromwell.sh ${srcDir}/dcm_1_5-6-2022.tar.gz > test_submit.log 2>&1 &
tail -f test_submit.log
##./submit_non_cromwell.sh ${srcDir}/dcm_2_5-6-2022.tar.gz
##./submit_non_cromwell.sh${srcDir}/dcm_3_5-6-2022.tar.gz