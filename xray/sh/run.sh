#!/bin/bash


InstallXrayCore(){
	MakeTempPath
	cd $TEMP_PATH 
	curl -Lk $XRAY_CORE_DOWNLOAD_URL -o core.zip
	unzip -o core.zip
	
	mv -f xray /etc/okproxy/xray/bin/xray 
	mv -f geosite.dat /etc/okproxy/xray/bin/
	mv -f geoip.dat /etc/okproxy/xray/bin/
	chmod +x /etc/okproxy/xray/bin/xray
}

SystemdXray(){
	cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/okproxy/xray/bin/xray run -config /etc/okproxy/xray/config.json -confdir /etc/okproxy/xray/conf
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

}

# install xray core 
InstallXray(){

	mkdir -p /etc/okproxy/xray/bin/
	mkdir -p /etc/okproxy/xray/conf/

	InstallXrayCore
	
	SystemdXray

	systemctl daemon-reload
	systemctl enable xray 
	systemctl start xray 

	echo 'xray install sucess'
	# xray info xray # 查看 xray 安装 进程

}

UninstallXray(){
	rm -rf /etc/okproxy/xray/bin/*
	rm -rf /etc/okproxy/xray/conf/*
	systemctl stop xray 
	systemctl disable xray 
	rm -rf /etc/systemd/system/xray.service
	systemctl daemon-reload
	echo 'del xray finished '
    
}

SaveConfigFile(){ # $1=filename
	# 保存这些参数到 文件中去,到时候用的时候,直接加载就好了
	[[ $1 ]] || Err '咋没参数呢 save config file run.sh-63'
	_file=/etc/okproxy/xray/env/$1.sh
	echo > $_file
	[[ $proxyConfiguration ]] && echo proxyConfiguration=$proxyConfiguration >> $_file
	[[ $protocol ]] && echo protocol=$protocol >> $_file
	[[ $type ]] && echo type=$type >> $_file
	[[ $tag ]] && echo tag=$tag >> $_file
	[[ $uuid ]] && echo uuid=$uuid >> $_file 
	[[ $httpPort ]] && echo httpPort=$httpPort >> $_file 
	[[ $serviceName ]] && echo serviceName=$serviceName >> $_file 
	[[ $proxyPort ]] && echo proxyPort=$proxyPort >> $_file
	[[ $port ]] && echo port=$port >> $_file 
	echo 'save configs done file name :'$_file
}


ProxyAddConfig(){
	if [[ $1 == vless-grpc-tls ]] ;then 
		cat > /etc/okproxy/xray/conf/$tag.json << EOF
{
	"inbounds": [
		{
			"port": $proxyPort,
			"protocol": "$protocol",
			"settings": {
				"clients": [
					{
						"id": "$uuid"					
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
	fi 
}

UpdateOKProxy(){
	cd /etc/okproxy 
	git fetch
	git reset --hard HEAD
	git merge '@{u}'
	chmod +x /usr/local/bin/xray
 
}

ShowProxyInfo(){
	echo '------------ proxy配置 '$tag'  ------------'
	case $1 in 
	vless-grpc-tls)
		echo '协议 protocol: ' $protocol 
		echo '地址  address: ' $domain 
		echo '端口  port : ' $httpPort 
		echo '用户ID     : ' $uuid 
		echo '传输协议: network:' $type 
		echo '伪装域名:  '$domain 
		echo '路径: ' $serviceName 
		echo 'tls: ' $tls 
		echo 
		echo '------------  链接 URL ------------'
		echo '还没写'
		echo '------------ http配置 '$tag'  ------------'
		echo '域名:' $domain  
		echo '路径 :' $serviceName 
		echo '端口: ' $httpPort 
		echo '转发端口: ' $proxyPort 
		echo 
		;;
	*)
		echo '配置信息不存在'
		;;
	esac 

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

UninstallShScript(){
	sed -i -e '/alias xray=/d' ~/.bashrc 
	unalias xray 
	echo '安装成功'
}