#!/bin/bash

# 初始化参数和 常量
RETURN=   # 设定这是函数的默认返回值
PROXY_CORE=xray
SH_VER=v0.0.1
SH_AUTHER=okproxy

# load default okproxy config 
source /etc/xray/sh/conf/config.sh 

# 加载工具
source /etc/xray/sh/libs.sh
source /etc/xray/sh/tools.sh

# 启动控制脚本
source /etc/xray/sh/run.sh
run $@