bucket_url=gs://cloudypipelines-com/nexus/dicom2nifti/scripts

bmi_url=/labs/sharmalab/cloudypipelines/scripts/dicom2nifti
########
function copy() {
   echo "gsutil cp ${bucket_url}/*.sh ${bmi_url}/"
   gsutil cp ${bucket_url}/*.sh ${bmi_url}/

   echo "gsutil cp ${bucket_url}/*.tar.gz ${bmi_url}/"
   gsutil cp ${bucket_url}/*.tar.gz ${bmi_url}/
}

copy
