#!/bin/bash

# ask install core 

# init defalut tools 
InitTools(){
    [[ $(type -P curl) ]] || apt install curl -y &
    [[ $(type -P wget) ]] || apt install wget -y &
    [[ $(type -P unzip) ]] || apt install unzip -y & 
}

# install xray 
InstallXray(){
    [[ -e /etc/xray ]] && echo "/etc/xray已存在,退出" && exit 
    mkdir -p /etc/xray
    cd /etc/xray 
    # curl -LOk xxx
    # unzipxxx

    # command 
    ln -sf /etc/xray/xray.sh /usr/local/bin/xray 
    # alias 
    echo "alias xray=/usr/local/bin/xray" >> ~/.bashrc 
    # 运行 xray 命令
    xray 
}


MakeFloder(){
    mkdir -p /etc/okproxy
}

# install okproxy 
InstallOkproxy(){
    # check if is installed or not 
    [[ -e /etc/okproxy ]] && exit 

    mkdir -p /etc/okproxy

    cd /etc/okproxy 
    # curl -LOk  这里需要下载一个 安装包在脚本中. 下载后,就可以去执行这个脚本了! 这个可以有.

    # alias okproxy 
    echo "alias okproxy=/usr/local/bin/okproxy" >> ~/.bashrc
    # core command 
    # core command
    ln -sf /etc/okproxy/okproxy.sh /usr/local/bin/okproxy
}




main(){
    cd "$HOME" || exit
    InitTools
    echo "v2fly xray v2ray install script"
    echo "1. xray install "
    read _input

    case $_input in 
    1) 
        InstallXray
        ;;
    *)
        echo "not yet "
        exit 
        ;;
    esac
}

main 


