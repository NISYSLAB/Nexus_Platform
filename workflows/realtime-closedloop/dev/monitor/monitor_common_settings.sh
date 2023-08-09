#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${SCRIPT_DIR}
source ../common_settings.sh

echo "PROFILE=${PROFILE}"

MONITOR_APP_JAR=rtcl-directory-monitor-${PROFILE}-${MONITOR_VERSION}.jar
MONITOR_APP_LOG=/labs/mahmoudilab/synergy_remote_data1/logs/rtcl-directory-monitor-${PROFILE}-$(date -u +"%Y-%m-%d").log

####### ENV
export monitoring_directory=/labs/mahmoudilab/synergy_remote_data1/${PROFILE}-emory_siemens_scanner_in_dir/csv
mkdir -p ${monitoring_directory}
export event_on_file_change=true
export event_on_file_delete=false
export event_on_file_create=true
export execution_script=/home/yzhu382/dev-synergy-rtcl-app/workflow/parse_and_submit.sh
export execution_folder=/tmp/synergy/executions

## Make sure only one thread
## The corePoolSize is the minimum number of workers to keep alive without timing out
export executor_core_pool_size=1
## The maxPoolSize defines the maximum number of threads that can ever be created.
## To clarify, maxPoolSize depends on queueCapacity in that ThreadPoolTaskExecutor
## will only create a new thread if the number of items in its queue exceeds queueCapacity.
export executor_max_pool_size=2
## Set the capacity of the queue.
## An unbounded capacity does not increase the pool and therefore ignores maxPoolSize.
export executor_queue_capacity=50000
## The amount of time in miliseconds to wait between checks of the file system
export executor_check_interval=1000


