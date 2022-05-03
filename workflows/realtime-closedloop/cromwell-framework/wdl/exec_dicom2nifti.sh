#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#### Main starts
## ./exec_dicom2nifti.sh ${dicomInput} ${niiOutput}
currDir=$PWD
echo "currDir=$currDir"
dicomDir="dicom"
niiDir="nii"
argCt=2
echo "Calling: ${SCRIPT_NAME} $@"
if [[ "$#" -ne ${argCt} ]]; then
    echo "Invalid command line arguments, expecting $argCt"
    exit 1
fi

dicomInput=$1
niiOutput=$2

mkdir -p ${dicomDir} && mkdir -p ${niiDir} && cp ${dicomInput} ${dicomDir}/input.tar.gz
cd ${dicomDir} && tar -xzf input.tar.gz && rm -f input.tar.gz && cd -
echo "Calling: time python dicom_pypreprocess.py --filepath ${dicomDir} --savepath ${niiDir}"
ls ./*
time python dicom_pypreprocess.py --filepath ${dicomDir} --savepath ${niiDir}
tar -czf ${niiOutput} ${niiDir}
ls ./*