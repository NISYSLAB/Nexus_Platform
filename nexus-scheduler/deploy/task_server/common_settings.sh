## Do not modify this file, it is created by other scripts

## release version

VERSION=2.0

APP_JAR=taskserver-directory-monitor-${VERSION}.jar
APP_LOG=/Users/Synergy/synergy_process/logs/monitor-$(date -u +"%Y-%m-%d").log

####### ENV
export monitoring_directory=/Users/Synergy/synergy_process/NOTIFICATION_TO_BMI
export event_on_file_change=true
export event_on_file_delete=false
export event_on_file_create=true
export execution_script=/Users/Synergy/synergy_process/scp2_bmi.sh
export execution_folder=/Users/Synergy/synergy_process

## Executor settings
## By setting corePoolSize and maximumPoolSize the same, you create a fixed-size thread pool
export executor_core_pool_size=1
export executor_max_pool_size=1
export executor_queue_capacity=1
## The amount of time in miliseconds to wait between checks of the file system
export executor_check_interval=1000


