# Library for working with package managers
#==================================
# Version 0.1
#==================================
#
#Defining the Package manager
function pm_get
{
    local manager_a=();
    local manager=""

    manager_a+=("dnf")
    manager_a+=("yum")
    manager_a+=("apt")
    manager_a+=("apt-get")
    manager_a+=("pacman")
    manager_a+=("zypper")

    for m in ${manager_a[@]}
    do
        if command -v ${m} &> /dev/null; then
            manager=${m}
            break
        fi
    done

    echo $manager
}

function app_exist
{
    local app_name=$1
    local ret=0

    if command -v $app_name &> /dev/null; then
        return 1
    fi

    return $ret
}


function app_install
{
    local app_name=$1
    local package=${2:-${app_name}}
    local p_manager=$(pm_get)
    local cmd_line=""

    if [ -z "$p_manager" ]; then
        echo "Package manager not found"
        return 1
    fi

    if [[ "$p_manager" =~ ^(dnf|yum|apt|apt-get|zypper)$ ]]; then
        cmd_line="$p_manager install -y"
    elif [[ "$p_manager" =~ ^(pacman)$ ]]; then
        cmd_line="yes | $p_manager -Sy"
    fi

    app_exist $app_name
    if [ $? == 0 ]; then
        echo "$cmd_line $package"
    fi

    return 0
}
