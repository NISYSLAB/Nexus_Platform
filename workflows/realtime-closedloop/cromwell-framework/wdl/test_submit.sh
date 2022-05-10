srcDir=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/dcm
## dcmFile=dcm_1_5-6-2022.tar.gz
dcmFile=dcm_2_5-6-2022.tar.gz
##dcmFile=dcm_3_5-6-2022.tar.gz

input=${srcDir}/${dcmFile}
##input=/home/pgu6/app/listener/fMri_realtime/listener_execution/dicom2nifti/dicom/test_dicom.tar.gz
echo "./submit_cromwell.sh $input"
./submit_cromwell.sh $input