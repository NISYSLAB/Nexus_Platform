#!/bin/bash

SCRIPT_NAME=$(basename -- "$0")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SRC=/home/pgu6/realtime-closedloop
DEST=/labs/mahmoudilab/synergy-rt-preproc
BACKUP_DIR=${DEST}/BACKUP/$(date -u +"%Y%m%d-%H-%M-%S")

function backup() {
  mkdir -p ${BACKUP_DIR}
  echo "Created backup folder: ${BACKUP_DIR}"
  cp ${DEST}/RT_Preproc ${BACKUP_DIR}/
  cp ${DEST}/run_RT_Preproc.sh ${BACKUP_DIR}/
  cp ${DEST}/readme.txt ${BACKUP_DIR}/
  echo "Files in backup folder: ${BACKUP_DIR}"
  ls -alt ${BACKUP_DIR}/
}
#### Main starts
backup

echo "cp ${SRC}/RT_Preproc ${DEST}/RT_Preproc"
time cp ${SRC}/RT_Preproc ${DEST}/RT_Preproc

echo "cp ${SRC}/run_RT_Preproc.sh ${DEST}/run_RT_Preproc.sh"
time cp ${SRC}/run_RT_Preproc.sh ${DEST}/run_RT_Preproc.sh

echo "cp ${SRC}/readme.txt ${DEST}/readme.txt"
time cp ${SRC}/readme.txt ${DEST}/readme.txt

exit 0

echo "time rsync -a ${SRC}/CanlabCore/ ${DEST}/CanlabCore"
time rsync -a ${SRC}/CanlabCore/ ${DEST}/CanlabCore 

echo "time rsync -a ${SRC}/spm12/ ${DEST}/spm12"
time rsync -a ${SRC}/spm12/ ${DEST}/spm12 

echo "time rsync -a ${SRC}/dicom/ ${DEST}/dicom"
time rsync -a ${SRC}/dicom/ ${DEST}/dicom 

echo "time rsync -a ${SRC}/nii/ ${DEST}/nii" 
time rsync -a ${SRC}/nii/ ${DEST}/nii 

