#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SPM_DIR=$PWD/spm12

function make_spm() {
  cd ${SPM_DIR}/src
  make distclean
  make && make install
  make external-distclean
  make external && make external-install
}

echo "scl enable devtoolset-9 bash"
echo "scl enable gcc-toolset-10 'bash' "
echo ""

