#!/bin/bash

###
# 如果是函数, 统一用 RETURN 作为返回值, ERROR 作为 报错值
###

# 随机获取 UUID
GetUUID() {
    RETURN=$(cat /proc/sys/kernel/random/uuid)
}

# 随机获取密码  $1= 长度 ,默认 8位
GetPassword(){
    _len=$1
    [[ $_len ]] || _len=8
    _uuid=$(cat /proc/sys/kernel/random/uuid)
    RETURN=${_uuid:0:$_len}
}

# 
GetPath(){
    GetPassword
}

# 判断端口是否被占用
IsPortUsed() { # $1 = port 
    if [[ $(type -P netstat) ]]; then
        [[ ! $_usedPort ]] && _usedPort="$(netstat -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)"
        RETURN=$(echo $_usedPort | sed 's/ /\n/g' | grep ^${1}$)
        return
    fi
    if [[ $(type -P ss) ]]; then
        [[ ! $_usedPort ]] && _usedPort="$(ss -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)"
        RETURN=$(echo $_usedPort | sed 's/ /\n/g' | grep ^${1}$)
        return
    fi
}

# 获取一个随机端口
GetPort() {
    _count=0
    while :; do
        ((_count++))
        if [[ $_count -ge 99 ]]; then
            echo "试了99次都没拿到可用端口,绝了"
            break
        fi
        _port=$(shuf -i 12345-54321 -n 1)
        IsPortUsed 
        [[ $RETURN ]] || break
    done
    RETURN=$_port 
}


GetDomainDNSJsonByCF(){ # 4 6 
    [[ $1 ]] || return 
    # domainIP=$(host $1 | grep "has address" | awk '{print $4}')
    # domainIPv6=$(host $1 | grep "has IPv6 address" | awk '{print $5}')
    if [[ $2 == '6' ]];then 
        _type=aaaa
    else 
        _type=a
    fi 

    RETURN=$(wget -qO- --header="accept: application/dns-json" "https://one.one.one.one/dns-query?name=$1&type=$_type")
    
}


