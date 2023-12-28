#!/bin/bash

# 初始化参数和 常量
RETURN=   # 设定这是函数的默认返回值
PROXY_CORE=xray
SH_VER=v0.0.1
SH_AUTHER=
ACTION_LIST=(
    add
    edit
    info
    del
)

# 加载默认配置参数
[[ -e '/etc/xray/sh/conf/config.sh' ]] && source /etc/xray/sh/conf/config.sh
# 加载工具
source /etc/xray/libs/tools.sh

# 启动控制脚本
source /etc/xray/sh/run.sh
run $@