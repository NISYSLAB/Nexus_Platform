#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ./.ssl/.settings.sh

echo "234RT12  ${PASS} / 138Dept%%22"

echo "ssh  ${USER}@${HOST_IP}"
ssh  ${USER}@${HOST_IP}

