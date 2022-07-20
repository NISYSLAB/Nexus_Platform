#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
####
source ../../common_settings.sh
echo "VERSION=$VERSION"
echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "SCRIPT_NAME=$SCRIPT_NAME"

remote_dest=/labs/mahmoudilab/synergy_rtcl_app
APP_JAR=rtcl-directory-monitor-${VERSION}.jar
files=local_bmi_java.zip

#### functions
function create_common_settings() {
  echo "## Do not modify this file, it is created by other scripts" > common_settings.sh
  echo "" >> common_settings.sh
  sed "s|VERSION_TOBE_REPLACED|${VERSION}|g" common_settings_template.sh >> common_settings.sh
}
function create_local_zip() {
  rm -rf $files
  cp $HOME/workspace/Nexus_Platform/nexus-scheduler/target/nexus-scheduler-0.0.1-SNAPSHOT.jar "${APP_JAR}"
  zip -r $files ./common_settings.sh ./*_monitor.sh ./scp2_*.sh ./get*.sh  ./parse*sub*.sh ./tai*.sh ./*.jar
  rm -rf ./*.jar
}
function scp_zip() {
  scp_to_vm "${SCRIPT_DIR}/${files}" "${remote_dest}/${files}" "$BMI_SYNERGY_1_VM"
  rm -rf $files
  echo "Remote: $BMI_SYNERGY_1_VM:${remote_dest}"
}
#### Main starts
cd ${SCRIPT_DIR}
create_common_settings
create_local_zip
scp_zip



