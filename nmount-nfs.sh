#!/bin/bash
# Auto NFS mounting
# nmount-nfs.sh
#==================================
# Version 0.4
#==================================
# Version 0.3
#==================================
#   1. function umount_from_config
# Version 0.2
#==================================
# Version 0.1
#==================================

source /usr/local/lib/neosy/nfiles_lib.sh
source /usr/local/lib/neosy/nmount_lib.sh

CONFIG_PATH=/usr/local/etc
CONFIG_FILENAME=nmount-nfs.conf
CONFIG_FILE=${CONFIG_PATH}/${CONFIG_FILENAME}
SERVICE_DELAY=30s
DEBUG=false

PARM_1=$1

function mount_from_config
{
    #Selection of lines except for empty ones and with comments "#"
    local f_lines=`sed '/^#\|^$\| *#/d' ${CONFIG_FILE}`
    IFS=$'\n'
    for line in $f_lines
    do
        line=`echo "$line" | sed 's/$HOST_NAME/'$HOST_NAME'/g' | sed 's/${HOST_NAME}/'$HOST_NAME'/g'`

        line_parsing $line line_arr

        server=${line_arr[0]}
        share=${line_arr[1]}
        mount_dir=${line_arr[2]}
        mount_param=${line_arr[3]}

        mount-nfs "$server" "$share" "$mount_dir" "$mount_param"

        if [[ $DEBUG == true ]]; then
            echo "$server $share $mount_dir \"$mount_param\""
        fi
    done
}

function umount_from_config
{
    #Selection of lines except for empty ones and with comments "#"
    local f_lines=`sed '/^#\|^$\| *#/d' ${CONFIG_FILE}`
    IFS=$'\n'
    for line in $f_lines
    do
        line=`echo "$line" | sed 's/$HOST_NAME/'$HOST_NAME'/g' | sed 's/${HOST_NAME}/'$HOST_NAME'/g'`

        line_parsing $line line_arr

        mount_dir=${line_arr[2]}

        umount -f $mount_dir || umount -l $mount_dir || umount $mount_dir
    done
}


function main
{
    local daemon=false

    if [[ $PARM_1 == "-umount" ]]; then
        umount_from_config
        exit 0
    fi

    if [[ $PARM_1 == "-d" ]]; then
        daemon=true
    fi

    if [ ! -d ${CONFIG_PATH}} ]; then
        mkdir -p ${CONFIG_PATH}
    fi

    if [ ! -f ${CONFIG_FILE} ]; then
        echo "#server share mount_dir mount_param" > ${CONFIG_FILE}
    fi

    if [[ $daemon = true ]]; then
        while true
        do
            mount_from_config

            sleep ${SERVICE_DELAY}
        done
    else
        mount_from_config
    fi
}

main

exit 0
