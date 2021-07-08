
bucket_url=gs://cloudypipelines-com/nexus/dicom2nifti/scripts
########

function push_to_bucket() {
    local file=$1
    echo "gsutil cp ${file} ${bucket_url}/"
    time gsutil cp ${file} ${bucket_url}/

}
#### starts
push_to_bucket run_dicom2nifti_convertion.sh
push_to_bucket siemens_fmri_classic_001.tar.gz

gsutil ls -l ${bucket_url}/*.*
