#!/bin/bash

###
# 如果是函数, 统一用 RETURN 作为返回值 , 获取时,用 $RETURN 
###

# try show the list 
ShowList(){  # 1 2 3 4 
    i=0
    for _var in "$@"; do 
        ((i++))
        echo $i') '$_var
    done
}

# try add a temp 
MakeTempPath(){
    if [[ $TEMP_PATH ]];then 
        return 
    else 
        TEMP_PATH=$(mktemp -d)
    fi
}


# 获取公网IP
GetPublicIP() {
    _type=$1
    [[ $_type == '6' ]] || _type=4
 
    RETURN=$(curl -s -"$_type" http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}')
    echo $RETURN

}