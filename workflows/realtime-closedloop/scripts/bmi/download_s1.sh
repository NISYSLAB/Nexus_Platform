#!/bin/bash

remote_dest=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
dev_src=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi
files=rtcl_monitor.sh

#### Main starts
scp_from_vm ${remote_dest}/*.sh ${dev_src}/ $BMI_SYNERGY_1_VM

