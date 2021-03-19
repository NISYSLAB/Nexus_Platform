

bucket_url=gs://cloudypipelines-com/nexus/fMRI_Image_classification-Binary-and-Multiclass/scripts
########

function push_to_bucket() {
    local file=$1
    echo "gsutil cp ${file} ${bucket_url}/"
    time gsutil cp ${file} ${bucket_url}/

}

push_to_bucket run_model_training.sh
push_to_bucket run_model_predict.sh
push_to_bucket run_model_feature_activation_map.sh.sh
push_to_bucket usage_monitor.sh

##gsutil cp run_model_training.sh gs://cloudypipelines-com/nexus/fMRI_Image_classification-Binary-and-Multiclass/scripts/run_model_training.sh
