#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo " SCRIPT_NAME=${SCRIPT_NAME} "
echo " SCRIPT_DIR=${SCRIPT_DIR} "
#############################################################################
cd ${SCRIPT_DIR}

for file in *.wdl ; do
    echo "Valid file: ${file}"
   
    echo "java -jar ${WDLTOOL} validate ${file}"
    java -jar ${WDLTOOL} validate ${file} || { echo "Invalid WDL: ${file}"; return 1; }

    json_output=json_input_template_"${file%%.*}".json
    echo "java -jar ${WDLTOOL} inputs ${file} > ${json_output}"
    java -jar ${WDLTOOL} inputs ${file} > ${json_output}
    echo "json output template: ${json_output}"
done


