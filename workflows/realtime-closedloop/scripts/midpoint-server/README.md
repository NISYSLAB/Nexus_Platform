## Midpoint Server


* IP: ```170.140.32.177```

* User: ```synergyfernsync```

* Work directory: ```/mnt/drive0/synergyfernsync/synergy_process```

* Cron Entry: ```* * * * * bash /mnt/drive0/synergyfernsync/synergy_process/push_2_bmi.sh > /dev/null 2>&1```

Any dicom files in ```DATA_TO_BMI``` folder will be pushed to BMI network to be processed.