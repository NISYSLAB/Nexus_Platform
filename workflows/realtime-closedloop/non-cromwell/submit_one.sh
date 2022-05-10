
#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#############################################################################

wdl_file=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl/one.wdl
json_input=/home/pgu6/app/listener/fMri_realtime/listener_execution/wdl/one_input.json

curl -X POST "http://localhost:9033/api/workflows/v1" \
    -H "accept: application/json" \
    -H "Content-Type: multipart/form-data" \
    -F "workflowSource=@${wdl_file}" \
    -F "workflowInputs=@${json_input};type=application/json"


## return: {"id":"ae0dde76-e0d8-4cc1-ad5c-27c995d346cc","status":"Submitted"}
## output: /home/pgu6/app/cromwell/cromwell-executions/wf_realtime_v1/ae0dde76-e0d8-4cc1-ad5c-27c995d346cc/call-run/execution/dummy_test.csv