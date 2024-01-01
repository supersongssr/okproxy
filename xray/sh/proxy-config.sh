
XrayAddConfigFile(){
    case $1 in 

    vless-tcp-vision-reality-tls)
        cat > /etc/okproxy/xray/conf/vless-tcp-vision-reality-tls.json << EOF 
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

