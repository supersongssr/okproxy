

Add(){
	echo '添加代理'
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
    action=$1
    # 1 ask user to choice action 
    if [[ -z $action ]];then  
        ShowList ${ACTION_LIST[@]}
        read -r -p "请选择命令[默认add] :" INPUT
        action=${ACTION_LIST[$INPUT -1]}
    fi 

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
