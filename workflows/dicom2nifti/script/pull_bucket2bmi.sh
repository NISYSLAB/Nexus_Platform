bucket_url=gs://cloudypipelines-com/nexus/dicom2nifti/scripts

bmi_script_url=/labs/sharmalab/cloudypipelines/scripts/dicom2nifti
bmi_data_url=/labs/mahmoudilab/dicom2nifti/input_dicom
########
function copy() {
   echo "gsutil cp ${bucket_url}/*.sh ${bmi_script_url}/"
   gsutil cp ${bucket_url}/*.sh ${bmi_script_url}/

   echo "gsutil cp ${bucket_url}/*.tar.gz ${bmi_data_url}/"
   gsutil cp ${bucket_url}/*.tar.gz ${bmi_data_url}/
}

mkdir -p ${bmi_script_url}
mkdir -p ${bmi_data_url}
copy

ls -alt ${bmi_script_url}

ls -alt ${bmi_data_url}