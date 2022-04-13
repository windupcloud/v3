#!/bin/bash

#检测root账户
[ $(id -u) != "0" ] && { echo "请切换至root账户执行此脚本."; exit 1; }

#全局变量
server_ip=`curl -s http://ifconfig.co`
separate_lines="####################################################################"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#开始菜单
start_menu(){
clear
echo && echo -e "####################################################################
# 版本：V.0.0.1 2022-04-13                                        #
####################################################################
# [1] xxx                                                          #
# [2] xxx                                                          #
# [3] xxx                                                          #
# [4] xxx                                                          #
# [5] xxx                                                          #
# [6] xxx                                                          #
# [7] xxx                                                          #
# [8] xxx                                                          #
# [8] xxx                                                          #
####################################################################
# [x]刷新脚本 [y]更新脚本 [z]退出脚本                              #
# 此服务器IP信息：${server_ip_info} 国家:${country}
####################################################################"

stty erase '^H' && read -p "请选择安装项[1-8]/[a-g]:" num
clear
case "$num" in
    1)
    xxx;;
    2)
    xxx;;
    3)
    xxx;;
    4)
    xxx;;
    5)
    xxx;;
    6)
    xxx;;
    7)
    xxx;;
    8)
    xxx;;
    9)
    xxx;;    
    x)
    rm -rf /usr/bin/v4 && cp -r /root/v4.sh /usr/bin/v4 && chmod +x /usr/bin/v4
    v4;;
    y)
    update_the_shell;;
    z)
    echo "已退出.";exit 0;;
    *)
    clear
    echo -e "${Error}:请输入正确指令"
    sleep 2s
	start_menu
	;;
esac
}

xxx(){
	echo "xxx"
}

install_shell(){
	if [ ! -f /usr/bin/v4 ]; then
		cp -r /root/v4.sh /usr/bin/v4 && chmod +x /usr/bin/v4
	else
		rm -rf /usr/bin/v4
		cp -r /root/v4.sh /usr/bin/v4 && chmod +x /usr/bin/v4
		clear;echo "Tips:您可通过命令[v3]快速启动本脚本!"
	fi
}

get_server_ip_info(){

}

check_country(){
    resultverify="$(echo $(curl myip.ipip.net) | grep -nP "中国")"
    if [ "$?" = "0" ]; then
        country="CN"
    else
        country="Else"            
    fi
}

update_the_shell(){
	rm -rf /root/v4.sh v4.sh.*
	wget -N "https://github.com/Super-box/v3/raw/master/v4.sh" /root/v4.sh
	#将脚本作为命令放置在/usr/bin目录内,最后执行
	rm -rf /usr/bin/v4;cp -r /root/v4.sh /usr/bin/v4;chmod +x /usr/bin/v4
	v4
}

#安装本脚本,获取服务器IP信息
install_shell
get_server_ip_info
check_country

start_menu

i=1
while((i <= 100))
do
keep_loop
done

#END 2022年04月13日