#!/usr/bin/env bash

######## common settings
PYTHON_IMAGE_NAME=fmri_conversion
PYTHON_IMAGE_TAG=1.0
PYTHON_DOCKERFILE=Dockerfile.fmri_conversion
CONTAINER_NAME=${PYTHON_IMAGE_NAME}-${PYTHON_IMAGE_TAG}

GCR_PATH=cloudypipelines-com
## Import Notes: gcr.io is private, us.gcr.io is public
##CONTAINER_REGISTRY=us.gcr.io
CONTAINER_REGISTRY=gcr.io
