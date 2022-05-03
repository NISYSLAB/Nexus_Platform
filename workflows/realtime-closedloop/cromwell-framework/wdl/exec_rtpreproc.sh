#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Main starts
## ./exec_rtpreproc.sh ${matlabScript} ${matlab_ver} ${niiInut} ${result}
currDir=$PWD
echo "currDir=$currDir"
runScript="run_RT_Preproc.sh"
appDir="/home/pgu6/realtime-closedloop"
argCt=4
echo "Calling: ${SCRIPT_NAME} $@"
if [[ "$#" -ne ${argCt} ]]; then
    echo "Invalid command line arguments, expecting $argCt"
    exit 1
fi

matlabScript=$1
matlab_ver=$2
niiInut=$3
result=$4

cp ${matlabScript} ./${runScript}
cp ${niiInut} ./input.tar.gz
tar -xzf input.tar.gz && rm -f input.tar.gz
ls ./*
echo "Calling: time ./${runScript} ${matlab_ver} $PWD/nii"
time ./${runScript} ${matlab_ver} $PWD/nii

## TODO: where is the output??
echo "Waiting working matlab code ..." > ${result}
