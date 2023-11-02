#!/bin/bash

#RETURN 0-SUCESS  1-FAIL

SCRIPT_PATH=$(dirname $(readlink -e $0))

source $SCRIPT_PATH/lib/nmpackage_lib.sh
source $SCRIPT_PATH/lib/ninstall_lib.sh

check_root

source_lib_path-set $SCRIPT_PATH/lib
source_bin_path-set $SCRIPT_PATH
source_etc_path-set $SCRIPT_PATH
source_service_path-set $SCRIPT_PATH

#******************************* Custom functions ********************************
function install_depends
{
    echo "Installing the required packages..."
    app_install showmount nfs-common
    echo "Package installation is complete"
}

function install_lib
{
    copy_lib nfiles_lib.sh 644
    copy_lib nmount_lib.sh 644
}

function install_app
{
    copy_bin nmount-nfs.sh 755
}

function install_config
{
    copy_etc nmount-nfs.conf 644
}

function install_service
{
    copy_service nmount-nfs.service 644
}

function main
{
    install_depends
    install_lib
    install_app
    install_config
    install_service
}

main

exit 0
