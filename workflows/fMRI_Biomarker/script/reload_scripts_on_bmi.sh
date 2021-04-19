 bucket_url=gs://cloudypipelines-com/nexus/fMRI_Image_classification-Binary-and-Multiclass/scripts

bmi_url=/labs/sharmalab/cloudypipelines/scripts/fmri_biomarker
########
function copy() {
   echo "gsutil cp ${bucket_url}/*.sh ${bmi_url}/"
   gsutil cp ${bucket_url}/*.sh ${bmi_url}/
}

copy
