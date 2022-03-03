#### common app configurations

## release version
## 20220106_dan_pipeline
VERSION=1.3

##VERSION=1.2
##VERSION=1.0

JAR=./target/nexus-scheduler-0.0.1-SNAPSHOT.jar
APP_JAR=nexus-scheduler-"${VERSION}".jar

####### ENV
##export mount_disk=${PWD}/mount/outputs
export mount_disk=${PWD}/listener_execution/mount/outputs

## for fmri_biomarker_m: training/predict/featureActivationMap
export start_fmri_biomarker_model_training_script=${PWD}/listener_execution/run_training.sh

#### predict scripts
export start_fmri_biomarker_predict_script=${PWD}/listener_execution/run_predict.sh
export predict_exec_script=${PWD}/listener_execution/predict_exec.sh

#### feature_activation_matp scripts
export start_fmri_biomarker_feature_activation_map_script=${PWD}/listener_execution/run_feature_activation_map.sh
export actmap_exec_script=${PWD}/listener_execution/actmap_exec_script.sh

####
export fmri_biomarker_model_trained_dataset=/labs/mahmoudilab/synergy_remote_data1/trained_model_dir/trained_model.tar.gz

## every 2 second
export nexusMonitoring_cron="*/2 * * * * *"

## every 5 seconds
export fmri_biomarker_model_train_cron="*/5 * * * * *"

## monitoring listener folder
export fmri_biomarker_model_train_dataset_listener_folder="${PWD}/listener_execution/mount/inputs/train_data"
export fmri_biomarker_test_dataset_listener_folder="${PWD}/listener_execution/mount/inputs/test_data"
export dicom2nifti_dicom_image_listener_folder="${PWD}/listener_execution/mount/inputs/dicom_file"


#### log
log_root=/labs/sharmalab/cloudypipelines/logs

#### executor settings
## By setting corePoolSize and maximumPoolSize the same, you create a fixed-size thread pool
export executor_core_pool_size=1
export executor_max_pool_size=1
export executor_queue_capacity=300
## The amount of time in miliseconds to wait between checks of the file system
executor_check_interval=1000

## for GRAPipeline
export gra_container_start_script=/home/pgu6/app/listener/fMri_realtime/listener_execution/gra/gra_start_container_batch.sh
export gra_pipeline_listener_folder=/labs/mahmoudilab/synergy_remote_data1/gra/gra_file_in_dir
export gra_core_pool_size=5
export gra_max_pool_size=10
export ra_queue_capacity=100
## The amount of time in miliseconds to wait between checks of the file system
export gra_check_interval=5000


