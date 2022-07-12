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

