
#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#############################################################################

wdl_file=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl/closed-loop.wdl
json_input=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl/input_closed-loop.json

curl -X POST "http://localhost:9033/api/workflows/v1" \
    -H "accept: application/json" \
    -H "Content-Type: multipart/form-data" \
    -F "workflowSource=@${wdl_file}" \
    -F "workflowInputs=@${json_input};type=application/json"