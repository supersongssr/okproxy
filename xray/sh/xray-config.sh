
XrayConfig(){
    case $1 in 
    default)
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
        "port": 11171,
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
    ;;

    vless-tcp-vision-reality-tls)
        cat > /etc/xray/conf/vless-tcp-vision-reality-tls.json << EOF 
{
  "inbounds": [
    {
      "port": ${realityPort},
      "protocol": "vless",
      "tag": "VLESSReality",
      "settings": {
        "clients": [
                {
                    "id": "chika", // 长度为 1-30 字节的任意字符串，或执行 xray uuid 生成
                    "flow": "xtls-rprx-vision"
                }
            ],
        "decryption": "none",
        "fallbacks":[
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
    ;;
    *)
        echo 'not yet xray conf '
    esac 

}

