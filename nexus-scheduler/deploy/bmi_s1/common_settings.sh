## Do not modify this file, it is created by other scripts

## release version
VERSION=2.1

APP_JAR=rtcl-directory-monitor-${VERSION}.jar
APP_LOG=/labs/mahmoudilab/synergy_remote_data1/logs/rtcl-directory-monitor-$(date -u +"%Y-%m-%d").log

####### ENV
export monitoring_directory=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv
export event_on_file_change=true
export event_on_file_delete=false
export event_on_file_create=true
export execution_script=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl/parse_and_submit.sh
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


