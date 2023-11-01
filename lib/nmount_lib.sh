# Library for working with mount
# Version 0.2

HOST_NAME=`hostname | awk -F. '{print $1}'`

function run_cmd
{
    local cmd=$1
    local -n arr=$2
    local stdout=""
    local stderr=""
    local rc=""

    if result=$(bash -c "$cmd 2>&1"); then
        stdout=$result
    else
        rc=$?
        stderr=$result
    fi

    arr[0]=$rc
    arr[1]=$stdout
    arr[2]=$stderr
}

function mount-nfs
{
    local server=$1
    local share=$2
    local mount_dir=$3
    local mount_param=$4
    local check_nfs=""
    local ip=`hostname -I | head -1 | awk '{print $1}'`
    local ip_mask=""
    local stdout=""
    local sdterr=""
    local rc=""

    if [ -z $ip ]; then
        echo "The IP address is not defined!!!"
        return 1
    fi

    ping -c1 $server &>/dev/null
    if [ $? != 0 ]; then
        return 1
    fi

    ip_mask=`echo $ip | sed 's/\.[0-9]*$/.0\/24/'`

    run_cmd "showmount -e $server" std_arr
    rc=${std_arr[0]}
    stdout=${std_arr[1]}
    stderr=${std_arr[2]}

    if [ -z "$rc" ]; then
        check_nfs=`showmount -e $server | grep -e "$share " |grep $ip |sed 's/ \{1,\}/ /g' |awk 'BEGIN{RS=" "}{print}' |awk 'BEGIN{RS=","}{print}' |grep -x $ip`
        if [ -z "$check_nfs" ]; then
            check_nfs=`showmount -e $server | grep -e "$share " |grep $ip_mask |sed 's/ \{1,\}/ /g' |awk 'BEGIN{RS=" "}{print}' |awk 'BEGIN{RS=","}{print}' |grep -x $ip_mask`
        fi
    else
        echo "showmount -e $server - Error!"
        echo -e "\t$stderr"
    fi

    check_mount=`findmnt --all | grep -e "$server:$share "`

    #echo "$check_nfs $check_mount"

    if [[ -n "$check_mount" && -z "$check_nfs" ]]; then
        echo "Not available nfs $server:$share"
        echo -e "\tUnmount ${mount_dir}..."
        umount -f $mount_dir || umount -l $mount_dir || umount $mount_dir
    fi

    if [[ -z "$check_mount" && -n "$check_nfs" ]]; then
        echo "Found share $share"
        echo -e "\tMount $server:$share to ${mount_dir}"
        bash -c "mount -t nfs ${mount_param} $server:$share $mount_dir"
    fi
}
