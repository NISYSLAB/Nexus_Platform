#!/bin/bash

#### Do not modify below!!!
SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${SCRIPT_DIR}"
source ./src_common_settings.sh

####

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ./${SCRIPT_NAME} docker-image"
    echo "  e.g: ./${SCRIPT_NAME} gcr.io/cloudypipelines-com/rt-closedloop:3.0"
    exit 1
fi

img=$1
tarball=$( basename ${img} )
tarball=$( echo "${tarball/':'/'-'}" )

target=${RELEASE_DIR}/${tarball}.tar.gz
if [ -f "$target" ]
then
    echo "${target} is found, action reject!!!"
else
    echo "${target} not found, start processing... "
    echo "docker save ${img} | gzip > ${target}"
    time docker save ${img} | gzip > ${target}
fi
