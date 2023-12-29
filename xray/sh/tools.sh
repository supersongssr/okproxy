#!/bin/bash

###
# 如果是函数, 统一用 RETURN 作为返回值 , 获取时,用 $RETURN 
###
ShowList(){
    i=0
    select _var in "$@"; do 
        echo $i') '$_var
        ((i++))
    done
}