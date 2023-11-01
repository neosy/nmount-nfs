#!/bin/bash

#RETURN 0-SUCESS  1-FAIL

SCRIPT_PATH=$(dirname $(readlink -e $0))

SOURCE_LIB_PATH=$SCRIPT_PATH/lib
SOURCE_BIN_PATH=$SCRIPT_PATH
SOURCE_ETC_PATH=$SCRIPT_PATH
SOURCE_SERVICE_PATH=$SCRIPT_PATH

source $SOURCE_LIB_PATH/nmpackage_lib.sh

USR_LIB_PATH=/usr/local/lib
USR_BIN_PATH=/usr/local/bin
USR_ETC_PATH=/usr/local/etc
USR_SYSTEMD_PATH=/usr/lib/systemd/system

LIB_PATH=$USR_LIB_PATH/sh_n
BIN_PATH=$USR_BIN_PATH/sh_n
ETC_PATH=$USR_ETC_PATH
SERVICE_PATH=$USR_SYSTEMD_PATH

LOG_FILE_NAME=
LOG_PATH=
LOG_FILE=$LOG_PATH/$LOG_FILE_NAME

USER_GROUP="user:group"
USER=""
GROUP=""

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

#************************* Base functions ****************************
function user_read
{
    echo -n "Enter the user to start the service (Ex.: $USER_GROUP): "
    read USER_GROUP
    USER=`echo $USER_GROUP | awk -F':' '{print $1}'`
    GROUP=`echo $USER_GROUP | awk -F':' '{print $2}'`

    if ! id "$USER" >/dev/null 2>&1; then
        echo "User \"${USER}\" not found"
        exit 1
    fi

    if ! (id -nG "$USER" | grep -qw "$GROUP"); then
        echo "The user \"$USER\" does not belong to the group \"$GROUP\""
        exit 1
    fi
}

function copy_file
{
    local file_from=$1
    local path_to=$2

    if [ ! -d "$path_to" ]; then
        mkdir "$path_to"
    fi

    if [ ! -d "$path_to" ]; then
        echo "Folder ${path_to} does not exist"
        exit 1
    fi

    cp $file_from $path_to
}

function copy_lib
{
    local file_name=$1
    local rights="$2"

    copy_file $SOURCE_LIB_PATH/$file_name $LIB_PATH

    if [ -n "$rights" ]; then
        chmod $rights $LIB_PATH/$file_name
    fi
}

function copy_bin
{
    local file_name=$1
    local rights="$2"

    copy_file $SOURCE_BIN_PATH/$file_name $BIN_PATH

    if [ -n "$rights" ]; then
        chmod $rights $BIN_PATH/$file_name
    fi
}

function copy_etc
{
    local file_name=$1
    local rights="$2"
    local ret=1

    if [ ! -f "$ETC_PATH/$file_name" ]; then
        copy_file $SOURCE_ETC_PATH/$file_name $ETC_PATH
        ret=0

        if [ -n "$rights" ]; then
            chmod $rights $ETC_PATH/$file_name
        fi
    fi

    return $ret
}

function copy_service
{
    local file_name=$1
    local rights="$2"
    local ret=1

    if [ ! -f "$SERVICE_PATH/$file_name" ]; then
        copy_file $SOURCE_SERVICE_PATH/$file_name $SERVICE_PATH
        ret=0

        if [ -n "$rights" ]; then
            chmod $rights $SERVICE_PATH/$file_name
        fi
    fi

    return $ret
}

function install_depend
{
    app_install $1 $2
    if [ $? == 1 ]; then
        exit 1
    fi
}

#******************************* Custom functions ********************************

function install_depends
{
    echo "Installing the required packages..."
    install_depend showmount nfs-common
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

function install_log
{
    mkdir -p $LOG_PATH
    chown $USER_GROUP $LOG_PATH
    chmod 550 $LOG_PATH

    touch $LOG_FILE
    chown $USER_GROUP $LOG_FILE
    chmod 660 $LOG_FILE
}

function main
{
    #user_read

    install_depends
    install_lib
    install_app
    install_config
    install_service
    #install_log
}

main

exit 0