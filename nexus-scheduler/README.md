# Synergy Scheduler
Real Time Backend Daemon (Background Process)

## fMRI Closed-Loop Daemon
### Workflow
1. A server at a remote network pushes data to BMI cluster
2. Synergy Scheduler processes data
3. Synergy Scheduler pushes the processed results back to the same remote server

### Remote Task Server Details
* IP: ```10.44.92.68```
* USER: ```Synergy```
* /Users/Synergy/synergy_process/DATA_TO_BMI: the directory that pushes data files to BMI
* /Users/Synergy/synergy_process/DATA_PUSH_COMPLETED: the directory that stores the data files moved from the directory DATA_TO_BMI 
* /Users/Synergy/synergy_process/DATA_FROM_BMI: the directory that receives processed results from BMI

### BMI Server/Network Details
* HOST: ```datalink.bmi.emory.edu```
* USER: ```synergysync```
* Working Folder: ```/labs/mahmoudilab/synergy_remote_data1```

### Setup a Cron Job on Remote Task Server
Logon to the Task server
```angular2html
ssh Synergy@10.44.92.68
```

Add following entry in crontab
```angular2html
* * * * * cd /Users/Synergy/synergy_process && ./push_2_bmi.sh > /dev/null 2>&1
```

### Synergy Listener Daemon at BMI Cluster
There is a daemon called Synergy Listener, is monitoring the directory
```/labs/mahmoudilab/synergy_remote_data/emory_siemens_scanner_in_dir```.
Once it detects any new data files, it launches the pipeline, then pushes the results to 
the directory: ```/Users/Synergy/synergy_process/DATA_FROM_BMI``` at the remote Task sever 

### Performance

#### Prediction process
* Dataset pushed from Task server to BMI: ```1 - 3 seconds```
* Processing on BMI: ```23 - 30 seconds```
* Results pushed back to Task server: ```2 seconds```



