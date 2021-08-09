#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

######## ENV
export mount_disk=${PWD}/mount/outputs

## for fmri_biomarker_m: training/predict/featureActivationMap
export start_fmri_biomarker_model_training_script=${PWD}/script/run_training.sh
export start_fmri_biomarker_predict_script=${PWD}/script/run_predict.sh
export start_fmri_biomarker_feature_activation_map_script=${PWD}/script/run_feature_activation_map.sh
export fmri_biomarker_model_trained_dataset=$HOME/workspace/cloudypipelines/nexus-scheduler/mount/inputs/model_trained/trained_model.tar.gz

## for dicom2nifiti
export start_dicom2nifti_script=${PWD}/script/run_dicom2nifti_conversion.sh

## every 2 second
export nexusMonitoring_cron="*/2 * * * * *"

## every 5 seconds
export fmri_biomarker_model_train_cron="*/5 * * * * *"

## monitoring listener folder
export fmri_biomarker_model_train_dataset_listener_folder="${PWD}/mount/inputs/train_data"
export fmri_biomarker_test_dataset_listener_folder="${PWD}/mount/inputs/test_data"
export dicom2nifti_dicom_image_listener_folder="${PWD}/mount/inputs/dicom_file"

########

JAR=./target/nexus-scheduler-0.0.1-SNAPSHOT.jar
rm -rf ${JAR}
mvn clean
mvn package
ls -alt ${JAR}

java -jar ${JAR}

## mvn spring-boot:run
## gradle bootRun
echo "nexus passnexus"

echo "h2 db console: http://localhost:8080/h2-console"