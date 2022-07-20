#!/bin/bash

remote_dest=/labs/mahmoudilab/synergy_rtcl_app
dev_src=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi
files=local_bmi.zip

#### Main starts
cd $dev_src
rm -rf $files
zip -r $files *.sh
scp_to_vm "${dev_src}/${files}" "${remote_dest}/${files}" "$BMI_SYNERGY_1_VM"
rm -rf $files
echo "Remote: $BMI_SYNERGY_1_VM:${remote_dest}"


