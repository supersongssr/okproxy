#!/bin/bash

###
# 如果是函数, 统一用 RETURN 作为返回值 , 获取时,用 $RETURN 
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


# 判断端口是否被占用
IsPortUsed() { # $1 = port 
    if [[ $(type -P netstat) ]]; then
        [[ ! $_usedPort ]] && _usedPort="$(netstat -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)"
        echo $_usedPort | sed 's/ /\n/g' | grep ^${1}$
        return
    fi
    if [[ $(type -P ss) ]]; then
        [[ ! $_usedPort ]] && _usedPort="$(ss -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)"
        echo $_usedPort | sed 's/ /\n/g' | grep ^${1}$
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
        _port=$(shuf -i 445-65535 -n 1)
        [[ ! $(IsPortUsed $_port) ]] && break
    done
    RETURN=$_port 
}
