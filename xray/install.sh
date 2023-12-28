#!/bin/bash



# default config 
PROXY_CORE=xray
IS_CADDY_INSTALLED=
IS_NGINX_INSTALLED=

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



TEMP_PATH=$(mktemp -d)
cd $TEMP_PATH
#
### install xray core 

link=https://github.com/xtls/xray-Core/releases/latest/download/xray-linux-64.zip
curl -LOk $link
unzip xray-linux-64.zip
mkdir -p /etc/xray/bin/
mkdir -p /etc/xray/conf/ 
mv -f xray /etc/xray/bin/xray 
mv -f geosite.dat /etc/xray/bin/
mv -f geoip.dat /etc/xray/bin/
chmod +x /etc/xray/bin/xray




# set config , default api 

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

# set vless-tcp-vision-reality-tls.sh 

GetPort 
port=$RETURN
GetUUID 
uuid=$RETURN 
security=reality
flow=xtls-rprx-vision

# set config, add vless-tcp-vision-reality-tls
cat > /etc/xray/conf/vless-tcp-vision-reality-tls.json << EOF 
{
	"inbounds": [
		{
			"port": ${port},
			"protocol": "vless",
			"tag": "vless-vision-reality",
			"settings": {
				"clients": [
					{
						"id": "${uuid}",
						"flow": "${flow}"
					}
				],
				"decryption": "none",
				"fallbacks": [
					{
						"dest": "31305",
						"xver": 1
					}
				]
			},
			"streamSettings": {
				"network": "tcp",
				"security": "reality",
				"realitySettings": {
					"show": false,
					"dest": "${realityServerName}:${realityDomainPort}",
					"xver": 0,
					"serverNames": [
						"${realityServerName}"
					],
					"privateKey": "${realityPrivateKey}",
					"publicKey": "${realityPublicKey}",
					"maxTimeDiff": 70000,
					"shortIds": [
						"",
						"6ba85179e30d4fc2"
					]
				}
			}
		}
	]
}
EOF 

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



#
### disable firewalld / ufw 

systemctl stop firewalld 
systemctl disable firewalld 

systemctl stop ufw 
systemctl disable ufw 

