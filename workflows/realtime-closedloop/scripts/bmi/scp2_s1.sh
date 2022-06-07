#!/bin/bash

remote_dest=/home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl
dev_src=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi
files=rtcl_monitor.sh

#### Main starts
scp_to_vm ${dev_src}/${files} ${remote_dest}/${files} $BMI_SYNERGY_1_VM

