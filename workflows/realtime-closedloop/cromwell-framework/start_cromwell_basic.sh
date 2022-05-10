#!/bin/bash

source ./common_settings.sh

function get_prerequisites() {
    ## download cromwell if not existing
    if [ ! -f ./cromwell-${cromwell_version}.jar ]
    then
        echo "Fetch cromwell-${cromwell_version}.jar"
        wget https://github.com/broadinstitute/cromwell/releases/download/${cromwell_version}/cromwell-${cromwell_version}.jar
    fi

}


####################################################################
## Non Docker version
## LOCALBACKEND configurations
####################################################################

function start_cromwell_no_docker() {
    java -Dwebservice.port=${CROMWELL_PORT} \
         -Dconfig.file=${CONFIG_FILE} \
         -jar ${PWD}/cromwell-${cromwell_version}.jar server 
}

###########################################################################
clear

echo "Make sure kill cromwell instance!!!"
get_prerequisites
sleep 5 
set -x
start_cromwell_no_docker

