## release version

## 20220630_IO_monitor
VERSION=2.0

## 20220106_dan_pipeline
## VERSION=1.3

## onFileChange=onFileNew
## VERSION=1.2

JAR=./target/nexus-scheduler-0.0.1-SNAPSHOT.jar
APP_JAR=nexus-scheduler-"${VERSION}".jar

####### ENV
export monitoring_directory=/Users/anniegu/workspace/Nexus_Platform/nexus-scheduler/mount/inputs/csv
export event_on_file_change=true
export event_on_file_delete=false
export event_on_file_create=true
export execution_script=/Users/anniegu/workspace/Nexus_Platform/nexus-scheduler/deploy/task_push_2_bmi.sh
export execution_folder=${PWD}/mount/outputs

## Executor settings
## By setting corePoolSize and maximumPoolSize the same, you create a fixed-size thread pool
export executor_core_pool_size=1
export executor_max_pool_size=1
export executor_queue_capacity=1
## The amount of time in miliseconds to wait between checks of the file system
export executor_check_interval=1000


