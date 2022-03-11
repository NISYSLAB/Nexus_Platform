
###### local test which will be invoked in backend
trainedModelData=$HOME/workspace/cloudypipelines/nexus-scheduler/mount/outputs/trained_model.tar.gz
testDataIn=$HOME/workspace/cloudypipelines/nexus-scheduler/mount/inputs/test_data.tar.gz

time ./run_predict.sh "${trainedModelData}" "${testDataIn}"

