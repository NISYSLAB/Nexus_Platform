

## Matlab script notes:

Compiling the file:

1. Make sure spm12, CanlabCore and Neu3CA-RT library is downloaded and unpacked (You might not have Neu3CA-RT [GitHub link](https://github.com/jsheunis/Neu3CA-RT) now)
2. Go into compile_files.m and change the paths on the top to be the paths to the actual libraries.
3. Run compile_files.m. This script expects the actual preprocessing function `rtPreprocessing_simple_new.m`.

Running the compiled file:

The compiled Matlab function expects 4 inputs - full name of trial nii, full name of 4D_pre.nii, full name of the mask file (wWager...) specific to the subject, and full name to the output file from command line. 

An example call would be like:

`./rtPreprocessing_simple_new ~/trial_instance/4D_trial.nii ~/experiment/4D_pre.nii ~/experiment/wWager_ACC_cluster8_thresholded.nii ~/trial_instance/biomarker.csv`

The file 4D_pre.nii and wWager_ACC_cluster8_thresholded.nii is a reference image generated before realtime workflow and would need to be manually uploaded (via ssh) to the server before we run the workflow.

The size of the compiled program is culled a bit. Hopefully this will make it faster.

## Task Server

### Prerequisites

* A Unix-based operating system (yes, that includes Mac!)
* A Java 8 or higher runtime environment
  - You can see what you have by running  ```$ java -version``` on a terminal. You're looking for a version that's at least 1.8 or higher.
  - If not, you can download Java [here](https://docs.oracle.com/javase/9/install/installation-jdk-and-jre-linux-platforms.htm#JSJIG-GUID-737A84E4-2EFF-4D38-8E60-3E29D1B884B8).
  
* User ```Synergy``` with admin/sudo privilege


### Configurations & Environments

* IP: ```170.140.61.168``` (subject to changes)
* Working directory: ```/Users/Synergy/synergy_process```
* Monitoring Folder & Sub folders: ```/Users/Synergy/synergy_process/NOTIFICATION_TO_BMI```
* Monitoring Script: ```/Users/Synergy/synergy_process/start_monitor.sh```
* Optimizer CSV file pushed from BMI:
```/Users/Synergy/synergy_process/DATA_FROM_BMI/optimizer_out.csv```

### Events 

If the monitoring process detects any following events, it will transfer the file(s) to the location ```/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/csv``` in BMI network:

* Any new csv file added to ```Monitoring Folder or its subfolders```
  
* Any content changes in existing csv files in ```Monitoring Folder or its subfolders```

### Scripts

Go to directory ```/Users/Synergy/synergy_process```

#### To start or re-start monitor

```./start_monitor.sh```

#### To stop monitor

```./stop_monitor.sh```

#### To get processId for the running monitor

```./getpid.sh```

### Monitoring Logs

The logs are located in folder ```/Users/Synergy/synergy_process/logs```

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

## Midpoint Server

### Prerequisites

* A Unix-based operating system (yes, that includes Mac!)
* A Java 8 or higher runtime environment
  - You can see what you have by running  ```$ java -version``` on a terminal. You're looking for a version that's at least 1.8 or higher.
  - If not, you can download Java [here](https://docs.oracle.com/javase/9/install/installation-jdk-and-jre-linux-platforms.htm#JSJIG-GUID-737A84E4-2EFF-4D38-8E60-3E29D1B884B8).

  
### Monitoring Environments

* IP: ```170.140.32.177```

* User: ```synergyfernsync```

* Work directory: ```/mnt/drive0/synergyfernsync/synergy_process```

* Monitoring or Listening Folder: ```/mnt/drive0/synergyfernsync/synergy_process/DATA_TO_BMI```

* Monitoring Script: ```/Users/Synergy/synergy_process/start_monitor.sh```

### Events 

If the monitoring process detects any following events, it will transfer the dicom file(s) to the location: ```/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir/image``` in BMI network:

* Any new dicom file added to ```Monitoring Folder or its subfolders```
  
* Any content changes in existing dicom files in ```Monitoring Folder or its subfolders```

### Scripts

Go to directory ```/mnt/drive0/synergyfernsync/synergy_process```

#### To start or re-start monitor

```./start_monitor.sh```

#### To stop monitor

```./stop_monitor.sh```

#### To get processId for the running monitor

```./getpid.sh```

### Monitoring Logs

The logs are located in folder ```/mnt/drive0/synergyfernsync/synergy_process/logs```


## Matlab Scripts Notes

### Compilation

1. Make sure ```spm12```, ```CanlabCore``` and ```Neu3CA-RT``` library is downloaded and unpacked.
(You might not have Neu3CA-RT [GitHub link](https://github.com/jsheunis/Neu3CA-RT) now)
2. Edit  ```compile_files.m``` and change the paths on the top to be the paths to the actual libraries.
3. Compile matlab scripts
   * Compile at your local development which has Matlab compiler, Run ```compile_files.m```. This script expects the actual preprocessing function `rtPreprocessing_simple_new.m`, and the dACC mask `Wager_ACC_cluster8.nii` to be in the same folder.
   * Compile at BMI VM `mahmoudimatlab.priv.bmi.emory.edu`, go to `/home/pgu6/realtime-closedloop` folder
     * Type ```$ matlab -nodisplay -nosplash``` to enter  Matlab Console
     * ```>> cd /home/pgu6/realtime-closedloop```
     * ```>> compile_files```
     * If the comilation succeeds, it generates following messages
   
```
Parsing file "/home/pgu6/realtime-closedloop/RT_Preproc.m"
(referenced from command line).
Generating file "/home/pgu6/realtime-closedloop/readme.txt".
Generating file "run_RT_Preproc.sh".
```
4. Copy Binaries/Scripts to ```/labs/mahmoudilab/synergy-rt-preproc```, run ```$ ./copy_binaries.sh```

### Execution Command Line

The compiled Matlab function expects 3 inputs:

* full name of trial nii 
* full name of 4D_pre.nii 
* full name to the output file from command line 

An example call would be like:

`./RT_Preproc 
~/trial_instance/4D_trial.nii 
~/experiment/4D_pre.nii 
~/experiment/wWager_ACC_cluster8_thresholded.nii 
~/trial_instance/objective.csv`

From my understanding, the file `4D_pre.nii` is a reference image generated before we run the workflow and would need to be uploaded to the server before we run the workflow.

The compiled program runs slow maybe due to it needs to unpack itself - which consists of the full spm library. But due to the nested nature of the spm library (everything calls spm.m and itself calls a ton of other functions) I currently cannot think of a good way to reduce the size.

### Build Docker images
Logon to VM `synergy1.priv.bmi.emory.edu`
Go to folder `/home/pgu6/app/listener/fMri_realtime/listener_execution/docker`, run
```
$ ./build_push_docker.sh
```


## Runtime Configurations

Some application configurations can be set in a configuration file with extention ```.conf```, the configuration file can be placed in the listener folder either at Midpoint server or Task server, the configuration file will be copied to BMI network, and affects the subquent realtime closed-loop workflow pipeline.  If you want to add new configurations, please notify Annie.

* At Task Server, there is a default configuration called ```rtcp_default_settings.conf``` at folder ```/Users/Synergy/synergy_process```, you can make the chanages to that file, and copy it to `NOTIFICATION_TO_BMI`

* At Midpoint Server, there is a default configuration called ```rtcp_default_settings.conf``` at folder ```/mnt/drive0/synergyfernsync/synergy_process```, you can make the chanages to that file, and copy it to `DATA_TO_BMI`

Once the modified configration file is put into the listener folder, it will be pushed to BMI network and availabel to subquent process.

Here is the sample of the configuration file: 

```
## Ip of Task server
RTCP_TASK_SERVER_IP=10.44.121.95
##RTCP_TASK_SERVER_IP=10.44.121.90

## Reset optimizer output csv file at BMI
##RTCP_RESET_OPTIMIZER_CSV=true
RTCP_RESET_OPTIMIZER_CSV=false

## Image pattern
## example: 001_000009_000067.dcm  001_000005_000342.dcm
## <RTCP_IMAGE_NAME_PART1>-<RTCP_IMAGE_NAME_PART2>-<RTCP_IMAGE_NAME_PART3_LENGTH>.dcm
RTCP_IMAGE_NAME_PART1=001
RTCP_IMAGE_NAME_PART2=000008
RTCP_IMAGE_NAME_PART3_LENGTH=6

## Pre NII
RTCP_PRE_4D_NII=4D_pre.nii

## Mask NII
RTCP_SUBJECT_MASK_NII=Wager_ACC_cluster8.nii
```

## Pre 4D NII file and Mask NII file

if you want to use the new NII files, you can also put the NII files in the listener folder either in Task server or Midpoint server, they will be pushed to BMI network immediately, if you use the different names, you can modify ```rtcp_default_settings.conf```, the configuration varilables is ```RTCP_PRE_4D_NII``` and ```RTCP_PRE_4D_NII``` respectively.