## Do not modify this file, it is created by other scripts

## release version
VERSION=2.1

APP_JAR=midpoint-directory-monitor-${VERSION}.jar
APP_LOG=/mnt/drive0/synergyfernsync/synergy_process/logs/monitor-$(date -u +"%Y-%m-%d").log

####### ENV
export monitoring_directory=/mnt/drive0/synergyfernsync/synergy_process/DATA_TO_BMI
export event_on_file_change=true
export event_on_file_delete=false
export event_on_file_create=true
export execution_script=/mnt/drive0/synergyfernsync/synergy_process/scp2_bmi.sh
export execution_folder=/tmp/synergy/executions

## By setting corePoolSize and maximumPoolSize the same, you create a fixed-size thread pool
## The corePoolSize is the minimum number of workers to keep alive without timing out
export executor_core_pool_size=10
## The maxPoolSize defines the maximum number of threads that can ever be created.
## To clarify, maxPoolSize depends on queueCapacity in that ThreadPoolTaskExecutor
## will only create a new thread if the number of items in its queue exceeds queueCapacity.
export executor_max_pool_size=50
export executor_queue_capacity=5000
## The amount of time in miliseconds to wait between checks of the file system
export executor_check_interval=1000

##
export check_file_stable=true


