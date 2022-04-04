#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function download_spm12() {
  FILE=spm12.zip
  [[ -f "${FILE}" ]] && return 0
  wget https://www.fil.ion.ucl.ac.uk/spm/download/restricted/eldorado/${FILE}
  unzip ${FILE}
}

function download_canlabcore() {
  CANLABCORE_DIR=CanlabCore
  [[ -d "${CANLABCORE_DIR}" ]] && return 0
  git clone https://github.com/canlab/CanlabCore.git
}

#### Main starts
download_spm12
download_canlabcore

##MCC=/usr/local/MATLAB/R2022a/bin/mcc
MCC=/usr/local/MATLAB/R2021b/bin/mcc
SRC=RT_Preproc

echo "time ${MCC} -m ${SRC}.m -o ${SRC}"
time ${MCC} -m ${SRC}.m -o ${SRC} && chmod a+x ${SRC}
