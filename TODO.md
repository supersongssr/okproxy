todo list 
===


## todo 
- [] 还是自己写吧. 别人的脚本,看起来太别扭了. 相当麻烦.还是自己搞比较好.
- [] 先写一个脚本, 先安装了再说.
    - [] 按照增删改查的思想
    - [] 重点是文件放对位置, 同时每个参数记录下来
- [] write a script , only for xray , vless -  tcp - vision - reality  and ss default ! cool way 
- [] init 
- [] fuck 写起来太难了.这样搞的话. 有些复杂了.
- [] 重新考虑
- [] 配置文件用脚本写好,还是修改配置文件比较好呢? 我感觉可以用脚本来写.可能会更好一些. 这个可以有.
- [] 多个core 合成在一个脚本中,比较好.
    - [] goproxy install 控制所有的命令
    - [] 然后, 单独的控制命
        - [] xray 
        - [] v2fly 
        - [] v2ray 
        然后其他的控制命令
- [] add 
- [] check : check user input 
- [] ask : ask user input 
- [] del : delete proxy 
- [] content :
    - install 
    - sh 
        - lib 
        - xray
    - conf



## choice
- [] caddy or nginx?    
    - both 
- [x] used sed or $var ???
    - [x] sed is clear , and $var is simple! . I thought simple is more import 
- [] 

## 目录树
- libs 一些工具 sh 脚本 
    - caddy2-install.sh 
    - nginx-install.sh 
    - systemd.sh 
- xray
    - conf
        - config.sh 一些默认的参数放在这里
        - vless-tcp-vision-reality-domain-port.sh 这个name的 入站的参数放在这里
    - sh sh脚本
        - run.sh 运行脚本, 控制脚本, 和 卸载脚本
    - xray.sh  一些变量的初始化脚本
    - install.sh 安装和卸载脚本. 
- v2ray
- v2fly
- okproxy.sh 一键安装 xray v2ray v2fly等,调用 xray/里面的安装脚本

## 流程

okproxy , 显示 xray v2fly的安装信息,
安装的话,调用 xray/install.sh 这个脚本来安装.
xray v2fly 等脚本可以单独安装.独立于 okproxy 存在
