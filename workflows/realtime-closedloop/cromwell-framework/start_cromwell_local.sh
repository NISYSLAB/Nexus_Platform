#!/bin/bash

source ./common_settings.sh
cromwell_version=59
export CONFIG_FILE=$PWD/home/pgu6/app/cromwell/.config/local_backend_local_filesystems.conf
export cromwell_port=9033
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
    java -Dwebservice.port=${cromwell_port} \
         -Dconfig.file=${CONFIG_FILE} \
         -jar ${PWD}/cromwell-${cromwell_version}.jar server 
}

###########################################################################
clear

echo "Make sure kill cromwell instance!!!"
./kill_cromwell_instance.sh

get_prerequisites
echo "Open browser: http://localhost:9033/"
sleep 5

set -x
start_cromwell_no_docker

