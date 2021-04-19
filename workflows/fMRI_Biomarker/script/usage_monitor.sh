#!/bin/bash
SCRIPT_NAME=$(basename -- "$0")

## interval in seconds 120 seconds = 2 minutes
interval=120

monitorLog="usage_monitor.log"
COUNTER=0

function print_usage() {
    now=$(date -u +"%m/%d/%Y:%H:%M:%S")
    COUNTER=$((COUNTER+1))
    ## echo "+++++++++++ counter ${COUNTER}: ${now} exec: vmstat ++++++++++++++++"
    ##vmstat || echo "vmstat not found"
    echo ""
    echo "+++++++++++ counter ${COUNTER}: ${now} exec: free ++++++++++++++++++"
    free || echo "free not found"
    echo ""
    echo "++++++++++++ counter ${COUNTER}: ${now} exec: cat /proc/meminfo  ++++"
    cat /proc/meminfo |grep -i mem || echo "/proc/meminfo not found"
    cat /proc/meminfo |grep -i Vmalloc || echo "/proc/meminfo not found"
    echo ""
    echo "+++++++++++++ counter ${COUNTER}: ${now} exec: df  ++++++++++++++++++"
    df || echo "df not found"
    echo ""
}

function print_info() {
    local msg=$1
    echo "${SCRIPT_NAME}: ${msg}"
}

function print_sys_info() {
  print_info "System Specs: $( uname -a )"
  print_info $(cat /etc/os-release )
}

function long_run() {
    while true
    do
        print_usage
        sleep ${interval}
    done
}

## Start
print_info "monitorLog: ${PWD}/${monitorLog}"
rm -rf ${monitorLog} || "${monitorLog} not found! OK to run"
print_sys_info >> ${monitorLog}
print_info "interval: ${interval} seconds" >> ${monitorLog}
echo "" >> ${monitorLog}

## output to stderr
long_run >> /dev/stderr &
## long_run  >> ${monitorLog} 2>&1 &


