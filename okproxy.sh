#!/bin/bash

# config # 
OKPROXY_GIT_URL=https://github.com/supersongssr/okproxy.git


# function # 

# error and exit 
Err(){
    echo -e '\e[31m'' Error '$@'\e[0m'
    exit 1
}

InitTools(){
	[[ $(type -P curl) ]] || apt install -y curl 
	[[ $(type -P wget) ]] || apt install -y wget 
	[[ $(type -P unzip) ]] || apt install -y unzip
	[[ $(type -P git) ]] || apt install -y git 
}

MakeAppAlias(){
    [[ $1 ]] || Err 'make app alias miss app name '
    _app=$1
    ln -sf /etc/okproxy/$_app/$_app.sh /usr/local/bin/$_app
	chmod +x /usr/local/bin/$_app
    sed -i -e '/alias $_app=/d' ~/.bashrc 
	echo "alias $_app=/usr/local/bin/$_app" >> ~/.bashrc
    
}

InstallProxyApp(){
    if [[ $1 ]];then 
        proxyApp=$1 
    else 
        echo '------------ 选择代理程序 默认 Xray ------------'
        echo 
        echo '1) Xray 代理程序 [默认]'
        echo '2) V2Fly (V2ray v5.x版本)'
        echo '3) 还不支持'
        echo 
        echo '请选择[0-9]:'
        read proxyApp
        # [[ $proxyApp ]] || proxyApp=1
    fi

    case $proxyApp in 
    1 | xray)
        MakeAppAlias xray
        mkdir -p /etc/okproxy/xray/env 
        mkdir -p /etc/okproxy/xray/conf
        xray install xray 
        ;;
    2 | v2fly)
        echo '还没写 v2fly 安装脚本'
        # MakeAppAlias v2fly
        # v2fly install v2fly
        ;;
    * )
        echo '这个选项还没有'
        InstallProxyApp 
    esac 

}

# install okproxy sh script
InstallOKProxy(){
    if [[ -e /etc/okproxy ]] ;then 
		echo '检测到已安装 okproxy'
        echo '跳过安装 okproxy'
        IS_OKPROXY_INSTALLED=/etc/okproxy
        return 
	fi 
    cd /etc
	git clone $OKPROXY_GIT_URL
}

Main(){
	# init tools command 
	InitTools 

	InstallOKProxy

    InstallProxyApp $1 

}

# logic # 
Main $@





