#!/bin/bash

remote_dest=/labs/mahmoudilab/synergy_rtcl_app
dev_src=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi
files=rtcl_monitor.sh

#### Main starts
scp_from_vm /home/pgu6/app/listener/fMri_realtime/listener_execution/non-wdl/non-wdl-scripts-working.zip \
    ./non-wdl-scripts-working.zip $BMI_SYNERGY_1_VM

exit 0
scp_from_vm /tmp/test/saved_outputs_07192022-19-46-52.tar.gz /tmp/saved_outputs_07192022-19-46-52.tar.gz $BMI_SYNERGY_1_VM
exit 0

scp_from_vm ${remote_dest}/*.sh ${dev_src}/ $BMI_SYNERGY_1_VM

