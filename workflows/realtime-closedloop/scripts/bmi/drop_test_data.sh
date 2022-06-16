srcDir=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/dcm
destDir=/labs/mahmoudilab/synergy_remote_data1/rtcl_data_in_dir

cp ${srcDir}/dcm_1_5-6-2022.tar.gz ${destDir}/
sleep 1 
cp ${srcDir}/dcm_2_5-6-2022.tar.gz ${destDir}/
sleep 1 

echo "log: /labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow"
