#!/bin/bash

OKPROXY_GIT_URL=https://github.com/supersongssr/okproxy.git
OKPROXY_DOWNLOAD_URL=https://github.com/supersongssr/okproxy/archive/refs/tags/v0.0.1.zip
XRAY_CORE_DOWNLOAD_URL=https://github.com/xtls/xray-Core/releases/latest/download/xray-linux-64.zip
PROXY_CORE=xray  # xray v2fly v2ray ...
HTTP_SERVER=
# httpServer 

InitTools(){
	[[ $(type -P curl) ]] || apt install -y curl 
	[[ $(type -P wget) ]] || apt install -y wget 
	[[ $(type -P vnstat) ]] || apt install -y vnstat 
	[[ $(type -P unzip) ]] || apt install -y unzip
	[[ $(type -P git) ]] || apt install -y git 
}

MakeFloder(){
	mkdir -p /etc/xray 
	mkdir -p /etc/xray/bin/
	mkdir -p /etc/xray/conf/ 
}

DefaultConfigXray(){

	cat > /etc/xray/config.json << EOF 
{
	"log": {
		"loglevel": "warning"
	},
	"dns": {},
	"api": {
		"tag": "api",
		"services": [
			"HandlerService",
			"LoggerService",
			"StatsService"
		]
	},
	"stats": {},
	"policy": {
		"levels": {
			"0": {
				"handshake": 2,
				"connIdle": 111,
				"uplinkOnly": 2,
				"downlinkOnly": 10,
				"statsUserUplink": true,
				"statsUserDownlink": true
			}
		},
		"system": {
			"statsInboundUplink": true,
			"statsInboundDownlink": true,
			"statsOutboundUplink": true,
			"statsOutboundDownlink": true
		}
	},
	"routing": {
		"domainStrategy": "IPIfNonMatch",
		"rules": [
			{
				"type": "field",
				"inboundTag": [
					"api"
				],
				"outboundTag": "api"
			},
			{
				"type": "field",
				"protocol": [
					"bittorrent"
				],
				"marktag": "ban_bt",
				"outboundTag": "block"
			},
			{
				"type": "field",
				"ip": [
					"geoip:cn",
					"geoip:private"
				],
				"marktag": "ban_geoip_cn",
				"outboundTag": "block"
			}
		]
	},
	"inbounds": [
		{
			"tag": "api",
			"port": 10086,
			"listen": "127.0.0.1",
			"protocol": "dokodemo-door",
			"settings": {
				"address": "127.0.0.1"
			}
		}
	],
	"outbounds": [
		{
			"tag": "direct",
			"protocol": "freedom"
		},
		{
			"tag": "block",
			"protocol": "blackhole"
		}
	]
}
EOF 


}

SystemdXray(){
# insatll xray systemd
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
ExecStart=/etc/xray/bin/xray run -config /etc/xray/config.json -confdir /etc/xray/conf
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

	# enable xray 
	systemctl daemon-reload
	systemctl enable xray 


}

InstallXray(){
	cd $TEMP_PATH 

	curl -Lk $XRAY_CORE_DOWNLOAD_URL -o xray-core.zip
	unzip -o xray-core.zip
	
	mv -f xray /etc/xray/bin/xray 
	mv -f geosite.dat /etc/xray/bin/
	mv -f geoip.dat /etc/xray/bin/
	chmod +x /etc/xray/bin/xray

	# DefaultConfigXray

	SystemdXray
	
}

# aks caddy or nginx 
InstallHttpServer(){
	echo "请选择安装 http 前置代理程序: 默认 caddy2 :"
	echo "1) Caddy2"
	echo "2) Nginx"
	echo "3) DIY 自己手动设置"
	read -r -p "请选择:" INPUT
	case $INPUT in 
	1)
		echo '还没写呢'
		;;
	2)
		echo 'nginx还没写呢'
		;;
	3)
		echo ' 自己动手丰衣足食'
		HTTP_SERVER=diy
		;;
	*)
		echo '选的什么乱七八糟的,重新选择'
	esac

}

SaveProxyConfigToFile(){
	echo PROXY_CORE=$PROXY_CORE >> /etc/xray/sh/conf/config.sh
	echo HTTP_SERVER=$HTTP_SERVER >> /etc/xray/sh/conf/config.sh
}


Main(){
	# init tools command 
	InitTools 
	# make a temp 
	TEMP_PATH=$(mktemp -d)
	# try get the package 
	cd $TEMP_PATH 
	# curl -Lk $OKPROXY_DOWNLOAD_URL  -o okproxy.zip
	# unzip -o okproxy.zip
	git clone https://github.com/supersongssr/okproxy.git
	cd okproxy
	# make floder 
	MakeFloder 
	# move xray files to /etc/xray 
	cd xray 
	mv * /etc/xray/
	# make run command 
	ln -sf /etc/xray/xray.sh /usr/local/bin/xray
	chmod +x /usr/local/bin/xray
	echo "alias xray=/usr/local/bin/xray" >>/root/.bashrc
	# get and install xray and default config 
	InstallXray
	echo "api port is 10086 "
	# disable firewalld
	echo "请自行设置防火墙. 由于需要配合 面板,所以这里不禁用端口了" 
	
	# aks install caddy or nginx ?
	InstallHttpServer 

	SaveProxyConfigToFile

	# del temp 
	rm -rf $TEMP_PATH
	# run the default config
	xray 

}

Main 





