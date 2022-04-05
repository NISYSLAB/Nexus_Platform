#!/bin/sh

workdir=/home/pgu6/realtime-closedloop
cd $workdir

zipfile=remote_mahmoudimatlab_realtime-closedloop.zip

echo "hostname=$(hostname)"
echo "user=$(whoami)"
echo "PWD=$PWD"

rm -rf ${zipfile}
zip -r ${zipfile} ./*.sh ./*.m ./*.txt ./Docker* ./.ssl
