#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}

####
function parse() {
    local filename=$1
    IFS="="
    while read -r name value
    do
      [[ $name =~ ^#.* ]] && continue
      [[ $name = RTCP* ]] && echo "export $name=$value" >> ${out_config_file}
    done < "$filename"
}

#### Main start
config_file=$1
out_config_file=$2
echo "###############################################################"  > ${out_config_file}
echo "## Do not modify this file !!!" >> ${out_config_file}
echo "## Auto script created on $(date +'%m/%d/%Y:%H:%M:%S')" >> ${out_config_file}
echo "###############################################################" >> ${out_config_file}
echo "" >> ${out_config_file}

nameonly=$( basename $config_file )
tmp_dir=/tmp/$(uuidgen)
mkdir -p ${tmp_dir}
cp ${config_file} ${tmp_dir}/${nameonly}
cd ${tmp_dir}
unzip ${nameonly} || tar -xzvf ${nameonly}
rm -rf *.zip || rm -rf *.tar.gz
for FILE in *.*;
do
  parse "${FILE}"
done
cd ${SCRIPT_DIR}
rm -rf ${tmp_dir}






