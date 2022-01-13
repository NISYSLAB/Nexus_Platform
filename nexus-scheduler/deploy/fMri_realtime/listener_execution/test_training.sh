
###### local test which will be invoked in backend
trainDataIn=$HOME/workspace/cloudypipelines/nexus-scheduler/mount/inputs/train_data.tar.gz
testDataIn=$HOME/workspace/cloudypipelines/nexus-scheduler/mount/inputs/test_data.tar.gz

time ./run_training.sh "${trainDataIn}" "${testDataIn}"

