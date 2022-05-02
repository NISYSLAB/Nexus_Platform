#!/bin/bash

source ./common_settings.sh
logdir="$(dirname "$cromwell_log")"
log=$(ls -t ${logdir}/*.log | head -1)

echo "cromwell log: ${log}"
tail -f ${log}
