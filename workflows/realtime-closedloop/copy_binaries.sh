#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
####

function download_Neu3CA_RT() {
    local dir=Neu3CA-RT
    [[ -d "${dir}" ]] && echo "${dir} exists, skip this step" && return 0
    git clone https://github.com/jsheunis/Neu3CA-RT.git
}

function copy_rtcpreproc() {
  local rt_preproc_dir=/labs/mahmoudilab/synergy-rt-preproc
  cp ./CanlabCore.tar.gz ${rt_preproc_dir}/
  cp ./spm12.tar.gz ${rt_preproc_dir}/
  cp ./RT_Preproc ${rt_preproc_dir}/
  cp ./run_RT_Preproc.sh ${rt_preproc_dir}/
  chmod a+x ${rt_preproc_dir}/RT_Preproc
  chmod a+x ${rt_preproc_dir}/run_RT_Preproc.sh
  ls -alt ${rt_preproc_dir}/*
}

#### Main starts
time copy_rtcpreproc
