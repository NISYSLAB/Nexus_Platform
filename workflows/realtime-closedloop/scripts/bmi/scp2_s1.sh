#!/bin/bash

remote_dest=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
dev_src=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi
files=local_bmi.zip

#### Main starts
cd $dev_src
rm -rf $files
zip -r $files *.sh
scp_to_vm "${dev_src}/${files}" "${remote_dest}/${files}" "$BMI_SYNERGY_1_VM"
rm -rf $files


