#!/bin/bash

# config #
RETURN=   # 设定这是函数的默认返回值
PROXY_CORE=xray
SH_VER=v0.0.1
SH_AUTHER=okproxy
PROXY_PATH=/etc/okproxy/xray # 获取当前工作目录
OKPROXY_PATH=/etc/okproxy
i=0 #一些运行循环次数统计
XRAY_CORE_DOWNLOAD_URL=https://github.com/xtls/xray-Core/releases/latest/download/xray-linux-64.zip

# load #
source $PROXY_PATH/env/config.sh # 加载初始配置
source $OKPROXY_PATH/libs/functions.sh # 加载函数
source $OKPROXY_PATH/libs/tools.sh  # 加载工具
source $PROXY_PATH/sh/run.sh # 加载控制函数


# functions #

Update(){
    if [[ $1 ]] ;then 
        INPUT=$1
    else
        echo "请选择要升级的项目:"
        echo '======='
        echo '1) sh控制脚本升级'
        echo '2) xrayCore 内核版本升级'
        echo '3) 还没想好'
        echo '======='
        echo 
        echo '请选择数字:'
        read INPUT
    fi 

	case $INPUT in 
	1 | sh)
		UpdateOKProxy
		;;
	*)
		echo 'not yet'
		;;
	esac
}

Install(){
	if [[ $1 ]];then 
		INPUT=$1
	else 
		echo '======= 选择要安装的项目 ======='
		echo '1) xray core内核'
		echo '2) caddy2 '
		echo '3) nginx'
		echo
		echo '请选择数字:'
		read INPUT
	fi 

	case $INPUT in
	1 | xray)
		echo 'install xray'
        InstallXray
		;;
	2 | caddy2)
		echo 'install caddy2 not yet'
		;;
	3 | nginx)
		echo 'install nginx not yet'
		;;
	*)
        ((i++))
        [[ $i -gt 99 ]] && echo '重试次数太多了' && exit 1
        echo 'not yet'
		echo '重新选择'
		Install 
        ;;
	esac
	
}


AskDomain(){
    echo 'ask domain start '
    [[ $domain ]] && return 
    echo 'ask domain 222'
    [[ $ip ]] || ip=$(GetPublicIP)
    [[ $ipv6 ]] || ipv6=$(GetPublicIP 6)
    echo '请将域名解析到 ip: '$ip
    echo '或者将域名解析到 ipv6: '$ipv6
    echo '稍后会进行 domain 测试是否解析'
    echo '======= 输入域名 ======='
    echo '输入域名:'
    read domain 
    if [[ -z $domain ]];then 
        ((i++))
        [[ $i -gt 99 ]] && echo '重试太多次了' && exit 1
        AskDomain 
    fi 
    
}

GetDomainDNS(){
    [[ $1 ]] || exit 
    domainIP=$(host $1 | grep "has address" | awk '{print $4}')
    domainIPv6=$(host s136.koggback.top | grep "has IPv6 address" | awk '{print $5}')
    
}

CheckDomainDNS(){
    GetDomainDNS 
    if [[ $ip && $domainIP == $ip ]] ;then 
        echo '域名 '$domain' 绑定IP是:'$domainIP
        echo 'ipv4解析成功'
    else 
        echo 'ipv4解析失败'
        echo '回车继续检测'
        read INPUT
        CheckDomainDNS 
    fi 

    if [[ $ipv6 && $domainIPv6 == $ipv6 ]];then 
        echo '域名 '$domain ' 绑定 ipv6 成功'
    else 
        echo 'ipv6解析失败'
        echo '回车 继续检测'
        read INPUT 
        CheckDomainDNS
    fi 

}

HttpAddConfig(){
    if [[ $httpServer == 'caddy2' ]] ;then 
        caddy2Config $1 
    elif [[ $httpServer == 'nginx' ]] ;then 
        nginxConfig $1 
    elif [[ $httpServer == 'diy' ]] ;then 
        diyConfig $1 
    else 
        echo '没设定httpServer呢'
    fi 
}

AskConfig(){
    echo 'ask config start '
    AskDomain 
    tls=tls
    type=grpc
    protocol=vless 
    GetUUID && uuid=$RETURN
    GetPort && port=$RETURN
    GetPath && path=$RETURN 
    GetPort && proxyPort=$RETURN # 获取内部转发端口
    httpPort=$port #这里的 http端口 就是 默认端口了. 然后其他的再说吧
    tag=$1-$domain-$port 
    CheckDomainDNS $domain
}

Add(){
    proxyConfigurationList=(
        vless-grpc-tls
        vless-tcp-vision-reality
    )
    if [[ $1 ]] ; then
        INPUT=$1
    else 
        echo '======= 选择配置 ======='
        echo '1) vless-grpc-tls'
        echo '2) vless-tcp-vision-reality'
        echo "请选择协议和配置:"
        read INPUT
    fi
	
    case $INPUT in 
    1 | vless-grpc-tls)
        echo 'vless-grpc-tls 已选择,开搞'
        proxyConfiguration=vless-grpc-tls
        
        
        
        ;;
    2 | vless-tcp-vision-reality)
        echo '啥也没有'
        ;;
    *)
        ((i++))
        [[ $i -gt 99 ]] && exit 1
        echo '选项不存在呢,重新选择'
        Add 
        ;;
    esac

    AskConfig $proxyConfiguration
    ProxyAddConfig $proxyConfiguration 
    HttpAddConfig $proxyConfiguration
    SaveConfig $tag.sh

    ShowProxyInfo $proxyConfiguration

	# ConfigXray $proxyProtocol

}

# show the info of the tag name something ?
Info(){
    configurationList=($(ls /etc/okproxy/xray/sh/conf/))
    if [[ $1 ]];then 
        configurationFile=$1.sh
    else 
        echo '请选择查看到配置'
        echo 
        ShowList ${configurationList[@]}
        read INPUT
        configurationFile=${configurationList[$INPUT -1]}
    fi 
    cd /etc/okproxy/xray/sh/conf/
    source $configurationFile 
    ShowProxyInfo $proxyConfiguration
}

Main(){
	if [[ $1 ]];then 
		INPUT=$1
	else 
		# 1 ask user to choice action 
		echo "请选择操作命令:"
		echo '======= 代理操作 ======='
		echo '1) add 增加代理 '
		echo '2) edit 修改代理 '
		echo '3) info 查询代理信息 '
		echo '4) del 删除代理 [慎用]'
		echo 
		echo '======= 脚本控制 ======='
		echo '6) status 运行状态'
		echo 
		echo '======= 系统操作 ======='
		echo '11) update 升级'
		echo '12) install 安装'
		echo '13) uninstall 卸载'
        echo 
        echo '======= 退出脚本'
        echo '0) 退出脚本'
		echo
		echo "请选择数字:"
		read INPUT
	fi

    case $INPUT in 
    0)
        echo '您选择了退出脚本, 臣妾告退'
        exit 0
        ;;
    1 | add) 
    	Add $2
     	;;
    2 | edit)
		Edit $2
		;;
    3 | info)
		Info $2
		;;
    4 | del)
		Del $2
		;;
	11 | update)
		Update $2
		;;
	12 | install)
		Install $2
		;;
    13 | uninstall)
		Uninstall $2
		;;
    *)
        ((i++))
        [[ $i -gt 99 ]] && echo '重试次数太多,告退了' && exit 1
		echo "命令不存在,重新选择"
		Run
        ;;
    esac
}

Main $@