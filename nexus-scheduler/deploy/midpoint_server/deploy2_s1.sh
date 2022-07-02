#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
####
source ../../common_settings.sh
echo "VERSION=$VERSION"
echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "SCRIPT_NAME=$SCRIPT_NAME"

remote_dest=/labs/mahmoudilab/synergy_remote_data1/midpointserver
APP_JAR=midpoint-directory-monitor-${VERSION}.jar
files=local_midpointserver.zip

#### Main starts
cd ${SCRIPT_DIR}
rm -rf $files

echo "## Do not modify this file, it is created by other scripts" > common_settings.sh
echo "" >> common_settings.sh
sed "s|VERSION_TOBE_REPLACED|${VERSION}|g" common_settings_template.sh >> common_settings.sh

cp $HOME/workspace/Nexus_Platform/nexus-scheduler/target/nexus-scheduler-0.0.1-SNAPSHOT.jar "${APP_JAR}"

zip -r $files ./common_settings.sh ./*_monitor.sh ./scp2_*.sh ./get*.sh ./*.jar
scp_to_vm "${SCRIPT_DIR}/${files}" "${remote_dest}/${files}" "$BMI_SYNERGY_1_VM"
rm -rf $files
rm -rf *.jar
echo "Remote: $BMI_SYNERGY_1_VM:${remote_dest}"


