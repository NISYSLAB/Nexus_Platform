#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

LOCKDIR=/tmp/synergy/bmi_transfer_lock

echo "rmdir $LOCKDIR"
rmdir $LOCKDIR
rmdir $(dirname ${LOCKDIR} )/*
ls $(dirname ${LOCKDIR} )/
