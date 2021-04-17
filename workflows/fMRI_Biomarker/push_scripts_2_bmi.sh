
bucket_url=/labs/sharmalab/cloudypipelines/scripts/fmri_biomarker
##/labs/sharmalab/cloudypipelines/scripts/fmri_biomarker/
########

JUMPBOX=oddjobs.bmi.emory.edu
BMI_VM=physionet2020.priv.bmi.emory.edu
USER=${BMI_VM_USER}

PASS=${BMI_VM_PASS}
echo "1397 ${PASS}"
################################################
function push_to_bmi() {
  local from=$1
  local dest=$2
  echo "scp -o ProxyCommand="ssh -W %h:%p ${USER}@${JUMPBOX}" "${from}" ${USER}@${BMI_VM}:${dest}"
  scp -o ProxyCommand="ssh -W %h:%p ${USER}@${JUMPBOX}" "${from}" ${USER}@${BMI_VM}:${dest}
}

push_to_bmi "run_model_training.sh" ${bucket_url}/run_model_training.sh
push_to_bmi "run_model_predict.sh" ${bucket_url}/run_model_predict.sh
push_to_bmi "run_model_feature_activation_map.sh" ${bucket_url}/run_model_feature_activation_map.sh
push_to_bmi "usage_monitor.sh" ${bucket_url}/usage_monitor.sh
