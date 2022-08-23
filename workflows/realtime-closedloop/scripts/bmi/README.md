## BMI 

### Prerequisites

* A Unix-based operating system (including Mac!)
* A Java 8 or higher runtime environment
* User ```synergysync``` with admin/sudo privilege

### Configurations & Environments

* Hosts: 
  *  ```datalink.bmi.emory.edu``` 
  *  ```synergy1.priv.bmi.emory.edu```
* Working directories: 
  * ```/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl``` at ```synergy1.priv.bmi.emory.edu```, considering move to ```/labs/mahmoudilab/...```
  
* Monitoring Incoming Images Folder: ```/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image```
  
* Monitoring Incoming Log CSV Folder: ```/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv```

* Monitoring Script: ```synergy1.priv.bmi.emory.edu:/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl/start_monitor.sh```

### Events 

If the monitoring process detects any following events, it will transfer the file(s) to the location ```/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv``` in BMI network:

* Any new csv file added to ```Monitoring Folder or its subfolders```
  
* Any content changes in existing csv files in ```Monitoring Folder or its subfolders```

### Scripts

Go to directory ```synergy1.priv.bmi.emory.edu:/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl```

#### To start or re-start monitor

```./start_monitor.sh```

#### To stop monitor

```./stop_monitor.sh```

#### To get processId for the running monitor

```./getpid.sh```

#### To start docker containers

```./start_container.sh```

#### To stop and remove docker containers

```./stop_and_remove_container.sh```

### Optimizer CSV File Path

The Optimizer csv output is located at 

```/labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow/single-thread/csv/optimizer_out.csv```

which is the softlink to 

```/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/csv/optimizer_out.csv```

At the end of the workflow pipeline, this file is pushed to Task Server 

```/Users/Synergy/synergy_process/DATA_FROM_BMI/optimizer_out.csv```

### Inputs/Outputs 

The incoming dicom files, generated nii and csv outputs in the workflow pipelines for each trial are saved as 
```saved_outputs_<datetime>.tar.gz``` in directory
```/labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow/single-thread```

which is the softlink to 
```/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread```

### Monitoring Logs

The logs are located in folders

* Monitor or Listener logs 

```/labs/mahmoudilab/synergy_remote_data1/logs/monitor-<datetime>.log```

* Parsing & Submission logs 

```/labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow/worker_<uuid>.log```

* Workflow logs 

```/labs/mahmoudilab/synergy_remote_data1/logs/rtcl/workflow/single-thread/process_<datatime>.log```

which is actually a softlink to 
```/home/pgu6/app/listener/fMri_realtime/listener_execution/mount/wf-rt-closedloop/single-thread/process_<datetime>.log```


### Docker 
$ docker ps
CONTAINER ID   IMAGE                                          COMMAND       CREATED       STATUS       PORTS                                       NAMES
73c2e0b7a6cd   gcr.io/cloudypipelines-com/rt-closedloop:2.1   "/bin/bash"   4 weeks ago   Up 4 weeks   0.0.0.0:9666->8080/tcp, :::9666->8080/tcp   realtime-closedloop-prod