
#### Set IMAGE_TAG to new value for each new changes!!!
IMAGE_TAG=4.0

RELEASE_DIR=/labs/mahmoudilab/synergy-rtcl-app-release/docker-image

## Import Notes: gcr.io is private, us.gcr.io is public
CONTAINER_REGISTRY=gcr.io
## CONTAINER_REGISTRY=us.gcr.io
GCR_PATH=cloudypipelines-com

IMAGE_NAME=rt-closedloop
rt_preproc_dir=/labs/mahmoudilab/synergy-rt-preproc

