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
source $OKPROXY_PATH/libs/functions.sh # 加载函数
source $OKPROXY_PATH/libs/tools.sh  # 加载工具
source $PROXY_PATH/config.sh # 加载初始配置
source $PROXY_PATH/sh/run.sh # 加载控制函数

# bash fonts colors
INFO_MSG="\033[32m[信息]\033[0m :"
ERROR_MSG="\033[31m[错误]\033[0m :"
WARNING_MSG="\033[33m[警告]\033[0m :"
TIP_MSG="\033[32m[注意]\033[0m :"

# functions #

# error and exit 
Err(){
    echo -e "$ERROR_MSG $@ "
    exit 1
}

AskDomain(){
    echo 'ask domain start '
    [[ $domain ]] && return 
    echo 'ask domain 222'
    [[ $ip ]] || ip=$(GetPublicIP)
    [[ $ipv6 ]] || ipv6=$(GetPublicIP 6)
    echo
    echo '------------ 需要一个域名 ------------'
    echo '请将域名解析到 ip: '$ip
    echo '或 ipv6: '$ipv6
    echo '稍后会进行 domain 测试是否解析'
    echo '输入域名:'
    read domain 
    if [[ -z $domain ]];then 
        ((i++))
        [[ $i -gt 99 ]] && echo '重试太多次了' && exit 1
        AskDomain 
    fi 
    echo $domain
    
}

AskDomainDNSCheck(){
    GetDomainDNSJsonByCF $domain 
    if [[ $ip && $RETURN =~ $ip ]] ;then 
        echo '域名 '$domain' 绑定IP是:'$ip
        echo 'ipv4解析成功'
        return 
    else 
        echo 'ipv4解析失败'
        echo '回车继续检测'
        read INPUT
    fi 

    GetDomainDNSJsonByCF $domain 6
    if [[ $ipv6 && $RETURN =~ $ipv6 ]];then 
        echo '域名 '$domain ' 绑定 ipv6 成功:'$ipv6
        return 
    else 
        echo 'ipv6解析失败'
        echo '回车 继续检测'
        read INPUT 
    fi 

    echo '------------ 是否继续检测 DNS ------------'
    echo 
    echo '1) 再检测试试'
    echo '2) 不检测了,跳过  '
    echo '0) 退出脚本'
    read INPUT
    [[ $INPUT ]] || INPUT=2

    case $INPUT in 
    1 )
        AskDomainDNSCheck 
        ;;
    2 )
         return
        ;;
    0 )
        exit 1
        ;;
    * )
        Err '没这个选项'
        AskDomainDNSCheck
    esac 
}

AskConfig(){
    echo 'ask config start '
    AskDomain 
    tls=tls
    type=grpc
    protocol=vless 
    GetUUID && uuid=$RETURN
    GetPort && port=$RETURN
    GetPath && serviceName=$RETURN 
    GetPort && proxyPort=$RETURN # 获取内部转发端口
    path=$ServiceName
    httpPort=$port #这里的 http端口 就是 默认端口了. 然后其他的再说吧
    tag=$1-$domain-$port 
    AskDomainDNSCheck $domain
}

Edit(){
    echo 'edit start'
    configurationList=($(ls /etc/okproxy/xray/env/))
    if [[ $1 ]];then 
        configurationFile=$1.sh
    else 
        echo '请选择查看到配置'
        echo 
        ShowList ${configurationList[@]}
        read INPUT
        configurationFile=${configurationList[$INPUT -1]}
    fi 
    cd /etc/okproxy/xray/env/

    echo '剩下的还没写'
    # 遍历参数, 然后根据反馈,进行调整. 然后让用户输入新参数,
    # 检测参数中是否包含=号,然后直接写入到配置文件中去就好了.
    # 然后,重新加载一遍参数,然后 重新配置文件 这应该是最好的方法了.  就是修改参数直接写入配置文件.


}

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



# uninstall something 
Uninstall(){
    if [[ $1 ]];then 
        INPUT=$1
    else 
        clear 
        echo '------------------------ 卸载选项 ------------------------'
        echo '1) xray卸载'
        echo '2) sh控制脚本'
        echo 
        echo '请输入[0-9]:'
        read INPUT 
    fi 

    case $INPUT in 
    1 | xray)
        UninstallXray 
        ;;
    2 | sh)
        UninstallShScript
        ;;
    *)
        echo '还没这个选项呢'
        ;;
    esac 
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
        return 
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
    systemctl restart xray 

    HttpAddConfig $proxyConfiguration
    SaveConfigFile $tag

    ShowProxyInfo $proxyConfiguration

    

	# ConfigXray $proxyProtocol

}

# show the info of the tag name something ?
Info(){
    configurationList=($(ls /etc/okproxy/xray/env/))
    if [[ $1 ]];then 
        configurationFile=$1.sh
    else 
        echo '请选择查看到配置'
        echo 
        ShowList ${configurationList[@]}
        read INPUT
        configurationFile=${configurationList[$INPUT -1]}
    fi 
    cd /etc/okproxy/xray/env/
    source $configurationFile 
    ShowProxyInfo $proxyConfiguration
}


Del(){
    configurationList=($(ls /etc/okproxy/xray/env))
    if [[ $1 ]];then 
        configurationFile=$1.sh
    else 
        echo '------------  '
        echo '请选择要删除的配置文件:'
        echo 
        ShowList ${configurationList[@]}
        read INPUT
        configurationFile=${configurationList[$INPUT -1]}
    fi 

    # _tag=${configurationFile/.sh/}
    _tag=${configurationFile%.*}   # 截取文件名 : tag

    # del sh config 
    rm -rf /etc/okproxy/xray/env/$_tag.sh
    
    # del proxy config 
    rm -rf /etc/okproxy/xray/conf/$_tag.json
    systemctl restart xray 

    # del http config 
    echo 'del http config 还没写'

}

Start(){
    if [[ $1 ]];then 
        INPUT=$1
    else 
        echo '------------ 选择 启动的程序'
        echo '1) xray'
        echo '请选择[0-9]'
        read INPUT 
        [[ $INPUT ]] || INPUT=xray
    fi

    case $INPUT in 
    1 | xray)
        systemctl start xray 
        ;;
    *)
        echo '还没写'
        ;;
    esac 

}

Stop(){
    if [[ $1 ]];then 
        INPUT=$1
    else 
        echo '---------- 选择停止的程序 -----------'
        echo '1) xray'
        echo '请选择[0-9]'
        read INPUT
        [[ $INPUT ]] || INPUT=xray 
    fi 

    case $INPUT in 
    1 | xray)
        systemctl stop xray 
        ;;
    *)
        echo 'not yet '
        ;;
    esac 
}



Status(){
    if [[ $1 ]];then 
        INPUT=$1
    else 
        echo 
        echo '------------ 请选择 ------------'
        echo '1) xray运行状态'
        echo '2) caddy2运行状态'
        echo '3) nginx 运行状态'
        echo 
        echo '请输入[0-9]:'
        read INPUT 
    fi 
    case $INPUT in 
    1 | xray)
        systemctl status xray 
        ;;
    2 | caddy2)
        echo '还没写呢 caddy2运行状态'
        ;;
    *)
        echo '选的啥呀'
        ;;
    esac
}

Main(){
	if [[ $1 ]];then 
		INPUT=$1
	else 
		# 1 ask user to choice action 
		echo "请选择操作命令:"
		echo '------------ 代理操作 ------------'
		echo '1) add 增加代理 '
		echo '2) edit 修改代理 '
		echo '3) info 查询代理信息 '
		echo '4) del 删除代理 [慎用]'
		echo 
		echo '------------ 脚本控制 ------------'
		echo '6) status 运行状态'
        echo '7) start '
        echo '8) stop '
		echo 
		echo '------------ 系统操作 ------------'
		echo '11) update 升级'
		echo '12) install 安装'
		echo '13) uninstall 卸载'
        echo 
        echo '------------ 退出脚本 ------------'
        echo '0) 退出脚本'
		echo
		echo "请选择[数字]:"
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
    6 | status | stat)
        Status $2
        ;;
    7 | start)
        Start $2 
        ;;
    8 | stop)
        Stop $2 
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
        [[ $i -gt 99 ]] && Err '重试次数太多,告退了' 
		echo "命令不存在,重新选择"
		Main
        ;;
    esac
}

Main $@