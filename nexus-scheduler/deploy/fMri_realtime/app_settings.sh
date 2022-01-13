#### Local data dirs
export LOCAL_DATA_ROOT_DIR=/labs/mahmoudilab/synergy_remote_data1
export LOCAL_RECEIVING_DIR=${LOCAL_DATA_ROOT_DIR}/emory_siemens_scanner_in_dir
export LOCAL_PUSH_DIR=${LOCAL_DATA_ROOT_DIR}/emory_siemens_scanner_out_dir

#### Remote data dirs
## on Task server
export REMOTE_TASK_RECEIVING_DIR=/Users/Synergy/synergy_process/DATA_FROM_BMI
## FERN to remote quasi rtfMRI remote server (IP: 170.140.32.177, synergyfernsync/michael123) (Michael/Kate)
##export REMOTE_TASK_RECEIVING_DIR=/mnt/drive0/synergyfernsync/synergy_process/DATA_FROM_BMI

source ./.ssl/.settings.sh
