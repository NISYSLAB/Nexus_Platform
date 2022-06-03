#!/bin/bash

dest=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi/tmp
processed=$HOME/workspace/Nexus_Platform/workflows/realtime-closedloop/scripts/bmi/processed
PADDING_ZEROS=5
function copyCSVFile() {
  cp ${processed}/EEfRT_65_run1.csv.zip ${dest}/
  cp ${processed}/test_5.csv.zip ${dest}/
}

function padding() {
    local num=$1
    printf "%0${PADDING_ZEROS}d\n" $num
}

function fakeDicomFile() {
    cd $dest
    for i in {1..600}
    do
       local dicomImg=$(padding $i).dcm
       echo "Generate empty dicom: $dicomImg "
       touch ${dicomImg}
    done
    cd -
}

#### Main starts
copyCSVFile
fakeDicomFile
