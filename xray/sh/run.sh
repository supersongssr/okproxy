#!/bin/bash


SaveConfigs(){ # $1=filename
	# 保存这些参数到 文件中去,到时候用的时候,直接加载就好了
	_file=$1
	echo > $_file
	echo protocol=$protocol >> $_file
	echo type=$type >> $_file
	echo tag=$tag >> $_file
	echo uuid=$uuid >> $_file 
	echo remotePort=$remotePort >> $_file 
	echo serviceName=$serviceName >> $_file 
	echo xrayPort=$xrayPort >> $_file
}

ConfigVlessGrpcTls(){
	protocol=vless
	type=grpc
	tag=vless-grpc-tls-$domain-$port
	# config xray
	echo > /etc/xray/conf/$tag.json << EOF 
{
	"inbounds": [
		{
			"port": $xrayPort,
			"protocol": "$protocol",
			"settings": {
				"clients": [
					{
						"id": "$uuid", 
						"flow": "xtls-rprx-vision"
					}
				],
				"decryption": "none"
			},
			"streamSettings": {
				"network": "$type",
				"grpcSettings": {
					"serviceName": "$serviceName"
				},
				"security": "none"
			},
			"sniffing": {
				"enabled": true,
				"destOverride": [
					"http",
					"tls"
				]
			},
			"tag": "$tag"
		}
	]
}
EOF
	# keep configs 
	
	SaveConfigs /etc/xray/sh/conf/$tag.sh

}

ConfigXray(){ # $1=proxyPortocolList
	_pp=$1
	GetUUID 
	uuid=$RETURN
	GetPath
	serviceName=$RETURN
	GetPort
	xrayPort=$RETURN
	
	read -r -p "请输入外部端口:" remotePort
	read -r -p "请输入域名:" remoteHost
	case $_pp in 
	vless-grpc-tls)
		ConfigVlessGrpcTls 
		;;
	*)
		echo '还没写'
		;;
	esac

}

Add(){
	echo '添加代理'
	PROXY_PROTOCOL_LIST=(
		vless-grpc-tls
		vless-tcp-vision-reality-tls
	)

	echo "请选择协议和配置:"
	ShowList ${PROXY_PROTOCOL_LIST[@]}
	read -r -p "请选择:" INPUT
	proxyProtocol=${PROXY_PROTOCOL_LIST[$INPUT]}
	[[ $proxyProtocol ]] || proxyProtocol=${PROXY_PROTOCOL_LIST[0]}  #默认
	
	ConfigXray $proxyProtocol

}

Edit(){
	echo '修改代理配置'
}

Info(){
	echo '查询代理配置信息'
}

Del(){
	echo '删除代理'
}


Uninstall(){
	echo 'uninstall: 卸载代理'
}

run(){
    # 1 ask user to choice action 
	echo "请选择操作命令,默认 add:"
	ACTION_LIST=(add edit info del uninstall) # command 
	ShowList ${ACTION_LIST[@]}
	read -r -p "请选择:" INPUT
	action=${ACTION_LIST[$INPUT]}
	[[ $action ]] || action=${ACTION_LIST[0]}  # 默认

    case $action in 
    add) 
    	Add 
     	;;
    edit)
		Edit 
		;;
    info)
		Info 
		;;
    del)
		Del 
		;;
    uninstall)
		Uninstall 
		;;
    *)
		echo "命令不存在,告退"
		exit 1
    esac
}
