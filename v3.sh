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
# 版本：V.2.3.6 2019-04-11                                        #
####################################################################
# [1] PM2管理后端                                                  #
# [2] Supervisor管理后端                                           #
# [3] 修改ssr节点配置                                              #
# [4] 安装ssr节点（肥羊）                                          #
# [5] 后端更多选项                                                 #
# [6] 一键安装加速                                                 #
# [7] 一键服务器测试                                               #
# [8] 更多功能                                                     #
####################################################################
# [a]卸载各类云盾 [b]查看回程路由 [c]简易测速 [d]检测BBR安装状态   #
# [e]配置防火墙 [f]列出开放端口 [g]更换默认源                      #
####################################################################
# [x]刷新脚本 [y]更新脚本 [z]退出脚本                              #
# 此服务器IP信息：${server_ip_info}
####################################################################"

stty erase '^H' && read -p "请选择安装项[1-8]/[a-g]:" num
clear
case "$num" in
	1)
	pm2_list;;
	2)
	supervisor_list;;
	3)
	modify_node_info;;
	4)
	install_node;;
	5)
	python_more;;
	6)
	serverspeeder;;
	7)
    speedtest;;
	8)
	system_more;;
	a)
	uninstall_ali_cloud_shield;;
	b)
    detect_backhaul_routing;;
	c)
	superspeed;;
	d)
	check_bbr_installation;;
	e)
	configure_firewall;;
	f)
	yum install -y net-tools;netstat -lnp;;
	g)
	replacement_of_installation_source;;
	x)
	rm -rf /usr/bin/v3 && cp /root/v3.sh /usr/bin/v3 && chmod +x /usr/bin/v3
	v3;;
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

keep_loop(){
#继续还是中止
echo ${separate_lines};echo -n "继续(y)还是中止(n)? [y/n]:"
	read -e -p "(默认: n):" yn
	[[ -z ${yn} ]] && yn="n"
	if [[ ${yn} == [Nn] ]]; then
	echo "已取消..." && exit 1
	else
		clear
		sleep 2s
		start_menu
	fi
}

reboot_system(){
	read -p "需重启服务器使配置生效,现在重启? [y/n]" is_reboot
	if [ ${is_reboot} = 'y' ]; then
		reboot
	else
		echo "需重启服务器使配置生效,稍后请务必手动重启服务器.";exit
	fi
}

#检查系统版本
check_sys(){
		if [[ -f /etc/redhat-release ]]; then
			release="centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			release="debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			release="debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
	        fi
}

#PM2-[1]
pm2_list(){
	echo "选项：[1]安装PM2 [2]配置PM2 [3]更新PM2 [4]卸载PM2 [5]更新cron任务"
	read pm2_option
	if [ ${pm2_option} = '1' ]; then
        install_pm2
    elif [ ${pm2_option} = '2' ]; then
        check_sys
        echo "$release"     
        if [ ${release} = 'centos' ]; then
			use_centos_pm2
		else
			use_debian_pm2
		fi
    elif [ ${pm2_option} = '3' ]; then
        if [ ! -f /usr/bin/pm2 ]; then
            install_pm2
        else
            update_pm2
        fi
    elif [ ${pm2_option} = '4' ]; then
            if [ ! -f /usr/bin/pm2 ]; then
            echo "已经卸载pm2"
        else
            remove_pm2
        fi
    elif [ ${pm2_option} = '5' ]; then
            update_cron
	else
	echo "选项不在范围,操作中止.";exit 0
	fi
}

install_pm2(){
        #检查系统版本
        check_sys
	
	#判断/usr/bin/pm2文件是否存在
	if [ ! -f /usr/bin/pm2 ]; then
        echo "检查到您未安装pm2,脚本将先进行安装"
	    #安装Node.js
        if [[ ${release} = "centos" ]]; then
	        yum -y install xz
    	    yum -y install wget
    	    yum -y install git
            yum install -y ntpdate ntp
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai
    	    wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc && /usr/bin/chattr +i /etc/resolv.conf
        else
	        apt -y install xz
	        apt -y install wget
	        apt -y install git
	        apt install -y ntpdate ntp
	        ps aux |grep ntpd |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai
	        wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc && /usr/bin/chattr +i /etc/resolv.conf
	fi
	    #编译Node.js
    	    wget -N https://nodejs.org/dist/v9.11.2/node-v9.11.2-linux-x64.tar.xz
    	    tar -xvf node-v9.11.2-linux-x64.tar.xz
    	    #设置权限
    	    chmod +x /root/node-v9.11.2-linux-x64/bin/node
    	    chmod +x /root/node-v9.11.2-linux-x64/bin/npm
    	    #创建软连接
	        rm -rf "/usr/bin/node"
	        rm -rf "/usr/bin/npm"
	        ln -sf /root/node-v9.11.2-linux-x64/bin/node /usr/bin/node
    	    ln -sf /root/node-v9.11.2-linux-x64/bin/npm /usr/bin/npm
	        #升级Node
	        npm i -g npm
            npm install -g npm
	        #安装PM2
    	    npm install -g pm2 --unsafe-perm
    	    #创建软连接x2
    	if [ ! -f /usr/bin/pm2 ]; then
    		ln -sf /root/node-v9.11.2-linux-x64/bin/pm2 /usr/bin/pm2
        else
    	    rm -rf "/usr/bin/pm2"
    	    ln -sf /root/node-v9.11.2-linux-x64/bin/pm2 /usr/bin/pm2
        fi
            rm -rf /root/*.tar.xz
            pm2 set pm2:autodump true
	else
		echo "已经安装pm2，请配置pm2"
	fi
}

update_cron(){
            #创建pm2日志清理
            if [ ! -f /var/spool/cron/root ] ; then
                echo "未设置定时任务"
            else
                cp "/var/spool/cron/root" "/var/spool/cron/root.bak"
                rm -rf "/var/spool/cron/root"
            fi
            
            if [ ! -f /root/ddns/cf-ddns.sh ] ; then
                echo "未检测到DDNS"
            else
                echo "添加DDNS定时启动"
                    sleep 2s
                    echo '###DDNS' >> /var/spool/cron/root
                    echo '* * * * * /usr/bin/bash /root/ddns/cf-ddns.sh >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /root/ddns-hz/cf-ddns.sh ] ; then
                    echo "未检测到合租DDNS"
            else
                echo "添加DDNS-HZ定时启动"
                    sleep 2s
                    echo '###DDNS-HZ' >> /var/spool/cron/root
                    echo '* * * * * /usr/bin/bash /root/ddns-hz/cf-ddns.sh >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /root/Application/telegram-socks/server.js ] ; then
                    echo "未检测到socks5"
            else
                echo "添加socks5定时重启"
                    sleep 2s
                    echo '###Socks5' >> /var/spool/cron/root
                    echo '* */1 * * * /usr/bin/systemctl restart telegram >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /etc/ocserv/ocserv.conf ] ; then
                echo "未检测到ocserv"
            else
                echo "添加ocserv定时重启并更新证书"
                    sleep 2s
                    echo '###Ocserv' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/sbin/service ocserv restart >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '* * * * * /usr/sbin/service ocserv start >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '45 2 * * * /usr/bin/bash /etc/ocserv/updatessl.sh >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /usr/local/gost/gostproxy ] ; then
                echo "未检测到gost"
            else
                echo "添加gost定时重启"
                    sleep 2s
                    echo '###Gost' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/local/sbin/gost start >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /usr/bin/docker ] ; then
                echo "未检测到docker"
            else
                echo "添加docker定时重启"
                    sleep 2s
                    echo '###Docker' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/bin/systemctl restart docker >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

                #PM2定时重启
                    echo '#DaliyJob' >> /var/spool/cron/root
                    echo '* */6 * * * /usr/bin/ssrr >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '*/30 * * * * /usr/bin/pm2 flush >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '2 3 * * * /usr/bin/ssrr >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/bin/v3 pm2-update >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '20 3 * * * /usr/bin/killall sftp-server >> /dev/null 2>&1' >> /var/spool/cron/root
                #清理缓存
                    echo '5 3 * * * /usr/bin/cat /dev/null > /var/spool/mail/root >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '10 3 * * * /usr/bin/cat /dev/null > /var/log/cron >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '15 3 * * * /usr/bin/cat /dev/null > /var/log/syslog >> /dev/null 2>&1' >> /var/spool/cron/root
                #重启cron并备份
                    /sbin/service crond restart
                    cp /var/spool/cron/root /var/spool/cron/v3root.bak
                #查看cron进程
                    crontab -l
}

use_centos_pm2(){
    if [ ! -f /usr/bin/killall ]; then
	echo "检查到您未安装psmisc,脚本将先进行安装"
	yum -y update
	yum -y install psmisc
    fi
    
    #清空
    pm2 delete all
    
    #判断内存
    all=`free -m | awk 'NR==2' | awk '{print $2}'`
    used=`free -m | awk 'NR==2' | awk '{print $3}'`
    free=`free -m | awk 'NR==2' | awk '{print $4}'`
    
    echo "Memory usage | [All：${all}MB] | [Use：${used}MB] | [Free：${free}MB]"
    sleep 2s
    #判断几个后端
    ssr_dirs=()
    while IFS=  read -r -d $'\0'; do
        ssr_dirs+=("$REPLY")
    done < <(find /root/  -maxdepth 1 -name "shadowsocks*" -print0)

    ssr_names=()
    for ssr_dir in "${ssr_dirs[@]}"
    do
        ssr_names+=($(basename "$ssr_dir"))
    done

        max_memory_limit=800
    if [ $all -le 256 ] ; then
        max_memory_limit=192
    elif [ $all -le 512 ] ; then
        max_memory_limit=512
    elif [ $all -le 1024 ] ; then
        max_memory_limit=700
    fi

    for ssr_name in "${ssr_names[@]}"
    do
        pm2 start /root/${ssr_name}/server.py --name $(echo ${ssr_name} | sed 's/shadowsocks-//') --max-memory-restart ${max_memory_limit}M  -o /dev/null/out-${ssr_name}.log -e /dev/null/error-${ssr_name}.log
    done


    sleep 2s
        #创建快捷方式
            rm -rf "/usr/bin/srs"
            echo "#!/bin/bash" >> /usr/bin/srs
	        echo "pm2 restart all" >> /usr/bin/srs
	        chmod +x /usr/bin/srs
	    
	        rm -rf "/usr/bin/ssrr"
	        echo "#!/bin/bash" >> /usr/bin/ssrr
	        for ssr_name in "${ssr_names[@]}"
	        do
	            echo "pm2 start /root/${ssr_name}/server.py --name $(echo ${ssr_name} | sed 's/shadowsocks-//') --max-memory-restart ${max_memory_limit}M  -o /dev/null/out-${ssr_name}.log -e /dev/null/error-${ssr_name}.log" >> /usr/bin/ssrr
            done
	        chmod +x /usr/bin/ssrr
	    
        #创建pm2日志清理
            if [ ! -f /var/spool/cron/root ] ; then
	            echo "未设置定时任务"
	        else
                cp "/var/spool/cron/root" "/var/spool/cron/root.bak"
                rm -rf "/var/spool/cron/root"
            fi
            
            if [ ! -f /root/ddns/cf-ddns.sh ] ; then
                echo "未检测到DDNS"
            else
	            echo "添加DDNS定时启动"
                    sleep 2s
                    echo '###DDNS' >> /var/spool/cron/root
                    echo '* * * * * /usr/bin/bash /root/ddns/cf-ddns.sh >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /root/ddns-hz/cf-ddns.sh ] ; then
                    echo "未检测到合租DDNS"
            else
                echo "添加DDNS-HZ定时启动"
                    sleep 2s
                    echo '###DDNS-HZ' >> /var/spool/cron/root
                    echo '* * * * * /usr/bin/bash /root/ddns-hz/cf-ddns.sh >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /root/Application/telegram-socks/server.js ] ; then
                    echo "未检测到socks5"
            else
	            echo "添加socks5定时重启"
                    sleep 2s
                    echo '###Socks5' >> /var/spool/cron/root
                    echo '* */1 * * * /usr/bin/systemctl restart telegram >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /etc/ocserv/ocserv.conf ] ; then
                echo "未检测到ocserv"
            else
	            echo "添加ocserv定时重启并更新证书"
                    sleep 2s
                    echo '###Ocserv' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/sbin/service ocserv restart >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '* * * * * /usr/sbin/service ocserv start >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '45 2 * * * /usr/bin/bash /etc/ocserv/updatessl.sh >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /usr/local/gost/gostproxy ] ; then
                echo "未检测到gost"
            else
                echo "添加gost定时重启"
                    sleep 2s
                    echo '###Gost' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/local/sbin/gost start >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

            if [ ! -f /usr/bin/docker ] ; then
                echo "未检测到docker"
            else
                echo "添加docker定时重启"
                    sleep 2s
                    echo '###Docker' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/bin/systemctl restart docker >> /dev/null 2>&1' >> /var/spool/cron/root
            fi

                #PM2定时重启
                    echo '#DaliyJob' >> /var/spool/cron/root
	                echo '* */6 * * * /usr/bin/ssrr >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '*/30 * * * * /usr/bin/pm2 flush >> /dev/null 2>&1' >> /var/spool/cron/root
	                echo '2 3 * * * /usr/bin/ssrr >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '0 3 * * * /usr/bin/v3 pm2-update >> /dev/null 2>&1' >> /var/spool/cron/root
	                echo '20 3 * * * /usr/bin/killall sftp-server >> /dev/null 2>&1' >> /var/spool/cron/root
                #清理缓存
                    echo '5 3 * * * /usr/bin/cat /dev/null > /var/spool/mail/root >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '10 3 * * * /usr/bin/cat /dev/null > /var/log/cron >> /dev/null 2>&1' >> /var/spool/cron/root
                    echo '15 3 * * * /usr/bin/cat /dev/null > /var/log/syslog >> /dev/null 2>&1' >> /var/spool/cron/root
	            #重启cron并备份
                    /sbin/service crond restart
                    cp /var/spool/cron/root /var/spool/cron/v3root.bak
                #查看cron进程
                    crontab -l
                    sleep 2s
                #创建开机自启动
	                pm2 save
	                pm2 startup
	    #完成提示
	clear;echo "########################################
# SS NODE 已安装完成                   #
########################################
# 启动SSR：pm2 start ssr               #
# 停止SSR：pm2 stop ssr                #
# 重启SSR：pm2 restart ssr             #
# 或：srs                              #
########################################"
}

use_debian_pm2(){
    if [ ! -f /usr/bin/killall ]; then
	echo "检查到您未安装psmisc,脚本将先进行安装"
	apt-get install psmisc
    fi
	#清空
        pm2 delete all
    #判断内存
    all=`free -m | awk 'NR==2' | awk '{print $2}'`
    used=`free -m | awk 'NR==2' | awk '{print $3}'`
    free=`free -m | awk 'NR==2' | awk '{print $4}'`
        echo "Memory usage | [All：${all}MB] | [Use：${used}MB] | [Free：${free}MB]"
        sleep 2s 
    #判断几个后端
    ssr_dirs=()
    while IFS=  read -r -d $'\0'; do
        ssr_dirs+=("$REPLY")
    done < <(find /root/  -maxdepth 1 -name "shadowsocks*" -print0)
    ssr_names=()
    for ssr_dir in "${ssr_dirs[@]}"
    do
        ssr_names+=($(basename "$ssr_dir"))
    done

        max_memory_limit=600
    if [ $all -le 256 ] ; then
        max_memory_limit=192
    elif [ $all -le 512 ] ; then
        max_memory_limit=400
    fi

    for ssr_name in "${ssr_names[@]}"
    do
        pm2 start /root/${ssr_name}/server.py --name $(echo ${ssr_name} | sed 's/shadowsocks-//') --max-memory-restart ${max_memory_limit}M  -o /dev/null/out-${ssr_name}.log -e /dev/null/error-${ssr_name}.log
    done
        sleep 2s
        #创建快捷方式
            rm -rf "/usr/bin/srs"
            echo "#!/bin/bash" >> /usr/bin/srs
            echo "pm2 restart all" >> /usr/bin/srs
            chmod +x /usr/bin/srs
        
            rm -rf "/usr/bin/ssrr"
            echo "#!/bin/bash" >> /usr/bin/ssrr
            for ssr_name in "${ssr_names[@]}"
            do
                echo "pm2 start /root/${ssr_name}/server.py --name $(echo ${ssr_name} | sed 's/shadowsocks-//') --max-memory-restart ${max_memory_limit}M  -o /dev/null/out-${ssr_name}.log -e /dev/null/error-${ssr_name}.log" >> /usr/bin/ssrr
            done
            chmod +x /usr/bin/ssrr
        
        #创建pm2日志清理
            if [ ! -f /var/spool/cron/crontabs/root ] ; then
	        echo "未部署定时任务"
		else
                cp "/var/spool/cron/crontabs/root" "/var/spool/cron/crontabs/root.bak"
                rm -rf "/var/spool/cron/crontabs/root"
            fi
            
            if [ ! -f /root/ddns/cf-ddns.sh ] ; then
                echo "未检测到DDNS"
            else
                echo "添加DDNS定时启动"
                    sleep 2s
                    echo '###DDNS' >> /var/spool/cron/crontabs/root
                    echo '* * * * * /usr/bin/bash /root/ddns/cf-ddns.sh >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
            fi

            if [ ! -f /root/ddns-hz/cf-ddns.sh ] ; then
                    echo "未检测到合租DDNS"
            else
                echo "添加DDNS-HZ定时启动"
                    sleep 2s
                    echo '###DDNS-HZ' >> /var/spool/cron/crontabs/root
                    echo '* * * * * /usr/bin/bash /root/ddns-hz/cf-ddns.sh >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
            fi

            if [ ! -f /root/Application/telegram-socks/server.js ] ; then
                    echo "未检测到socks5"
            else
                echo "添加socks5定时重启"
                    sleep 2s
                    echo '###Socks5' >> /var/spool/cron/crontabs/root
                    echo '* */1 * * * /usr/bin/systemctl restart telegram >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
            fi

            if [ ! -f /etc/ocserv/ocserv.conf ] ; then
                echo "未检测到ocserv"
            else
                echo "添加ocserv定时重启并更新证书"
                    sleep 2s
                    echo '###Ocserv' >> /var/spool/cron/crontabs/root
                    echo '0 3 * * * /usr/sbin/service ocserv restart >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '45 2 * * * /usr/bin/bash /etc/ocserv/updatessl.sh >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
            fi

            if [ ! -f /usr/local/gost/gostproxy ] ; then
                echo "未检测到gost"
            else
                echo "添加gost定时重启"
                    sleep 2s
                    echo '###Gost' >> /var/spool/cron/crontabs/root
                    echo '0 3 * * * /usr/local/sbin/gost start >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
            fi

            if [ ! -f /usr/bin/docker ] ; then
                echo "未检测到docker"
            else
                echo "添加docker定时重启"
                    sleep 2s
                    echo '###Docker' >> /var/spool/cron/crontabs/root
                    echo '0 3 * * * /usr/bin/systemctl restart docker >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
            fi
            
                #PM2定时重启
                    echo '#DaliyJob' >> /var/spool/cron/crontabs/root
                    echo '* */6 * * * /usr/bin/ssrr >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '*/30 * * * * /usr/bin/pm2 flush >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '2 3 * * * /usr/bin/ssrr >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '0 3 * * * /usr/bin/v3 pm2-update >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '20 3 * * * /usr/bin/killall sftp-server >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                #清理缓存
                    echo '5 3 * * * /usr/bin/cat /dev/null > /var/log/syslog >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '6 3 * * * /usr/bin/cat /dev/null > /var/log/spooler >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '7 3 * * * /usr/bin/cat /dev/null > /var/log/messages >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                    echo '8 3 * * * /usr/bin/cat /dev/null > /var/mail/root >> /dev/null 2>&1' >> /var/spool/cron/crontabs/root
                #重启cron并备份
                    service cron restart
                    service cron reload
                    cp /var/spool/cron/crontabs/root /var/spool/cron/crontabs/v3root.bak
                #查看cron进程
                    crontab -l
                    sleep 2s
                #创建开机自启动
                    pm2 save
                    pm2 startup
        #完成提示
	clear;echo "########################################
# SS NODE 已安装完成                   #
########################################
# 启动SSR：pm2 start ssr               #
# 停止SSR：pm2 stop ssr                #
# 重启SSR：pm2 restart ssr             #
# 或：srs                              #
########################################"
}

update_pm2(){
    #更新node.js
	    npm i -g npm
	    npm install -g npm
    #更新PM2
        npm install pm2@latest -g
    #PM2 update
        sleep 1s
        pm2 save
        pm2 update
        pm2 startup
}

remove_pm2(){
	    if [ ! -f /usr/bin/pm2 ]; then
		    echo "PM2已卸载"
		else
		    npm uninstall -g pm2
		    sleep 1s
		    npm uninstall -g npm
		    sleep 1s
		    #卸载Node.js
		    rm -rf "/usr/bin/node"
	        rm -rf "/usr/bin/npm"
	        rm -rf "/root/.npm"
            #卸载PM2
		    rm -rf "/usr/bin/pm2"
		    rm -rf "/root/.pm2"
		    rm -rf /root/node*
		    sleep 1s
		    echo "PM2完成卸载"
		fi
}

#supervisor-[2]
supervisor_list(){
	#检查 Root账户
	[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
        #检查系统版本
        check_sys
	
	echo "选项：[1]安装supervisor [2]卸载supervisor [3]强制重启supervisor"
	read super_option
	if [ ${super_option} = '1' ]; then
           install_supervisor_for_each
        elif [ ${super_option} = '2' ]; then
    	   remove_supervisor_for_each
	elif [ ${super_option} = '3' ]; then
    	   kill_supervisor
	else
           echo "选项不在范围,操作中止.";exit 0
	fi
}

install_supervisor_for_each(){
                #检查系统版本
                check_sys
		if [[ ${release} = "centos" ]]; then
			install_centos_supervisor
		else
			echo "暂时只完美支持Centos,请更换PM2管理";exit 0
		fi
	    }

remove_supervisor_for_each(){
	        #检查系统版本
                check_sys
		if [[ ${release} = "centos" ]]; then
			remove_centos_supervisor
		else
			remove_debian_supervisor
		fi
		}

install_centos_supervisor(){
	#判断/usr/bin/supervisord文件是否存在
	if [ ! -f /usr/bin/supervisord ]; then
		#判断/usr/bin/killall文件是否存在
	    if [ ! -f /usr/bin/killall ]; then
	        echo "检查到您未安装psmisc,脚本将先进行安装"
	        yum -y update
	        yum -y install psmisc
	    fi
	        echo "开始卸载supervisor"
                yum -y remove supervisor
                pip2 uninstall supervisor -y
                rm -rf "/etc/supervisord.conf"
                rm -rf "/usr/bin/srs"
                yum -y install supervisor
        #启用supervisord
                echo_supervisord_conf > /etc/supervisord.conf
                sed -i '$a [program:ssr]\ncommand = python /root/shadowsocks/server.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
                supervisord
        #iptables
            iptables -F
            iptables -X  
            iptables -I INPUT -p tcp -m tcp —dport 104 -j ACCEPT
            iptables -I INPUT -p udp -m udp —dport 104 -j ACCEPT
            iptables -I INPUT -p tcp -m tcp —dport 1024: -j ACCEPT
            iptables -I INPUT -p udp -m udp —dport 1024: -j ACCEPT
            iptables-save >/etc/sysconfig/iptables
            echo 'iptables-restore /etc/sysconfig/iptables' » /etc/rc.local
            echo "/usr/bin/supervisord -c /etc/supervisord.conf" » /etc/rc.local
        #创建快捷重启命令
            echo "#!/bin/bash" » /usr/bin/srs
            echo "supervisorctl restart ssr" » /usr/bin/srs
            chmod +x /usr/bin/srs
        #最后配置
        #/usr/bin/supervisord -c /etc/supervisord.conf
            srs
        #开机自启
            curl https://raw.githubusercontent.com/Supervisor/initscripts/master/centos-systemd-etcs > supervisord.service
            mv supervisord.service /etc/systemd/system
            chmod 644 /etc/systemd/system/supervisord.service
            systemctl daemon-reload
            systemctl start supervisord.service
            systemctl enable supervisord
            systemctl is-enabled supervisord
	else
	    echo "已经安装supervisor";exit 0
    fi        
}

remove_debian_supervisor(){
	#判断/usr/bin/supervisord文件是否存在
	if [ ! -f /usr/bin/supervisord ]; then
		echo "已经卸载supervisor";exit 0
	else
	    if [ ! -f /usr/bin/killall ]; then
	        echo "检查到您未安装psmisc,脚本将先进行安装"
	        apt-get install psmisc
        else
	        echo "现在开始卸载supervisor"
            killall supervisord
	        killall supervisord
	        killall supervisord
	        killall supervisord
	        apt-get remove --purge supervisor -y
            rm -rf "/etc/supervisord.conf"
            rm -rf "/usr/bin/srs"
        fi
	fi
}

remove_centos_supervisor(){
	#判断/usr/bin/supervisord文件是否存在
	if [ ! -f /usr/bin/supervisord ]; then
	    echo "已经卸载supervisor";exit 0
	else
	    if [ ! -f /usr/bin/killall ]; then
	    echo "检查到您未安装psmisc,脚本将先进行安装"
            yum -y update
	        yum -y install psmisc
        fi
	    echo "现在开始卸载supervisor"
            killall supervisord
	        killall supervisord
	        killall supervisord
	        killall supervisord
	        yum -y remove supervisor
            pip2 uninstall supervisor -y
            rm -rf "/etc/supervisord.conf"
            rm -rf "/usr/bin/srs"
	fi
}

kill_supervisor(){
    #检查系统版本
        check_sys
	#判断/usr/bin/killall文件是否存在
	if [ ! -f /usr/bin/killall ]; then
	    echo "检查到您未安装psmisc,脚本将先进行安装..."
	if [[ ${release} = "centos" ]]; then
	    yum -y update
	    yum -y install psmisc
	else
	    apt-get -y update
        apt-get -y install psmisc
	fi
        killall supervisord
	    killall supervisord
	    killall supervisord
	    killall supervisord
	    supervisord
	else
	    killall supervisord
	    killall supervisord
	    killall supervisord
	    killall supervisord
	    supervisord
	fi
}


#节点-[3]
modify_node_info(){
	#检测
	if [ ! -f /root/shadowsocks/userapiconfig.py ]; then
		echo "ssr服务端未安装,不能执行该选项.";exit
	else
		#清屏
		clear
		#输出当前节点配置
		echo "当前节点配置如下:"
		echo "------------------------------------"
		sed -n '3p' /root/shadowsocks/userapiconfig.py
		sed -n '17,18p' /root/shadowsocks/userapiconfig.py
		echo "------------------------------------"
		#获取新节点配置信息
		read -p "新的前端地址是:" Userdomain
		read -p "新的节点ID是:" UserNODE_ID
		read -p "新的MuKey是:" Usermukey
	
			#检查
			if [ ! -f /root/shadowsocks/userapiconfig.py.bak ]; then
				wget https://github.com/Super-box/v3/raw/master/userapiconfig.py
			else
			#还原
				rm -rf /root/shadowsocks/userapiconfig.py
				cp /root/shadowsocks/userapiconfig.py.bak /root/shadowsocks/userapiconfig.py
			fi
	
		#修改
		Userdomain=${Userdomain:-"http://${server_ip}"}
		sed -i "s#http://zhaoj.in#${Userdomain}#" /root/shadowsocks/userapiconfig.py
		Usermukey=${Usermukey:-"mupass"}
		sed -i "s#glzjin#${Usermukey}#" /root/shadowsocks/userapiconfig.py
		UserNODE_ID=${UserNODE_ID:-"3"}
		sed -i '2d' /root/shadowsocks/userapiconfig.py
		sed -i "2a\NODE_ID = ${UserNODE_ID}" /root/shadowsocks/userapiconfig.py
	fi
}

#安装后端-[4]
Libtest(){
	#自动选择下载节点
	GIT='raw.githubusercontent.com'
	LIB='download.libsodium.org'
	GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
	LIB_PING=`ping -c 1 -w 1 $LIB|grep time=|awk '{print $7}'|sed "s/time=//"`
	echo "$GIT_PING $GIT" > ping.pl
	echo "$LIB_PING $LIB" >> ping.pl
	libAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
	if [ "$libAddr" == "$GIT" ]; then
		libAddr='https://github.com/Super-box/v3/raw/master/libsodium-1.0.16.tar.gz'
	else
		libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.16.tar.gz'
	fi
	rm -f ping.pl		
}

Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1][0])'`
    elif [ -s /usr/bin/python2 ]; then
        Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1][0]'`
    fi
}

python_test(){
	#测速决定使用哪个源
	tsinghua='pypi.tuna.tsinghua.edu.cn'
	pypi='mirror-ord.pypi.io'
	doubanio='pypi.doubanio.com'
	pubyun='pypi.pubyun.com'	
	tsinghua_PING=`ping -c 1 -w 1 $tsinghua|grep time=|awk '{print $8}'|sed "s/time=//"`
	pypi_PING=`ping -c 1 -w 1 $pypi|grep time=|awk '{print $8}'|sed "s/time=//"`
	doubanio_PING=`ping -c 1 -w 1 $doubanio|grep time=|awk '{print $8}'|sed "s/time=//"`
	pubyun_PING=`ping -c 1 -w 1 $pubyun|grep time=|awk '{print $8}'|sed "s/time=//"`
	echo "$tsinghua_PING $tsinghua" > ping.pl
	echo "$pypi_PING $pypi" >> ping.pl
	echo "$doubanio_PING $doubanio" >> ping.pl
	echo "$pubyun_PING $pubyun" >> ping.pl
	pyAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
	if [ "$pyAddr" == "$tsinghua" ]; then
		pyAddr='https://pypi.tuna.tsinghua.edu.cn/simple'
	elif [ "$pyAddr" == "$pypi" ]; then
		pyAddr='https://mirror-ord.pypi.io/simple'
	elif [ "$pyAddr" == "$doubanio" ]; then
		pyAddr='http://pypi.doubanio.com/simple --trusted-host pypi.doubanio.com'
	elif [ "$pyAddr" == "$pubyun_PING" ]; then
		pyAddr='http://pypi.pubyun.com/simple --trusted-host pypi.pubyun.com'
	fi
	rm -f ping.pl
}

install_centos_ssr(){
    read -e -p "后端名字是:(默认: yahaha):" Username
	[[ -z ${Username} ]] && Username="yahaha"

	read -e -p "[y/n]是否是合租后端(默认: n):" yn
	[[ -z ${yn} ]] && yn="n"
	if [[ ${yn} == [Nn] ]]; then
	    git clone "https://gitee.com/superbox/p3-Superbox.git" "/root/shadowsocks-${Username}"
	else
        git clone "https://gitee.com/superbox/p3-hezu.git" "/root/shadowsocks-${Username}"
	fi

	#更换DNS至8888/1001
	/usr/bin/chattr -i /etc/resolv.conf && wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc && /usr/bin/chattr +i /etc/resolv.conf
	cd /root
	Get_Dist_Version

    #取消更换内核
	#if [ $Version == "7" ]; then
	#	wget --no-check-certificate https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
	#	rpm -ivh epel-release-latest-7.noarch.rpm	
	#else
	#	wget --no-check-certificate https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
	#	rpm -ivh epel-release-latest-6.noarch.rpm
	#fi
	#rm -rf *.rpm
	
	yum -y update --exclude=kernel*	
	yum -y install git gcc python-setuptools lsof lrzsz python-devel libffi-devel openssl-devel iptables iptables-services
	yum -y groupinstall "Development Tools" 
	#第一次yum安装 supervisor pip
	yum -y install supervisor python-pip
	supervisord
	#第二次pip supervisor是否安装成功
	if [ -z "`pip`" ]; then
    curl -O https://bootstrap.pypa.io/get-pip.py
		python get-pip.py 
		rm -rf *.py
	fi
	if [ -z "`ps aux|grep supervisord|grep python`" ]; then
    pip install supervisor
    supervisord
	fi
	#第三次检测pip supervisor是否安装成功
	if [ -z "`pip`" ]; then
		if [ -z "`easy_install`"]; then
    wget http://peak.telecommunity.com/dist/ez_setup.py
		python ez_setup.py
		fi		
		easy_install pip
	fi
	if [ -z "`ps aux|grep supervisord|grep python`" ]; then
    easy_install supervisor
    supervisord
	fi
	python -m pip install --upgrade pip


    #不再编译，直接yum
        #yum install libsodium -y
    
	#用脚本安装
        wget -N --no-check-certificate https://raw.githubusercontent.com/whunt1/onekeymakelibsodium/master/libsodium.sh && chmod +x libsodium.sh && bash libsodium.sh
	    rm -rf libsodium.sh

	#旧编译
	#	yum update
	#	echo -e "${Info} 安装依赖..."
	#	yum -y groupinstall "Development Tools"
	#	echo -e "${Info} 下载..."
	#	wget -N https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz
	#	echo -e "${Info} 解压..."
	#	tar -xzf libsodium-1.0.18-stable.tar.gz && cd libsodium-stable
	#	echo -e "${Info} 编译安装..."
	#	./configure --disable-maintainer-mode && make -j2 && make install
	#	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf

	cd /root/shadowsocks-${Username}
	chkconfig supervisord on
	#第一次安装
	pip install -I requests==2.9
	python_test
	pip install -r requirements.txt
	#第二次检测是否安装成功
	if [ -z "`python -c 'import requests;print(requests)'`" ]; then
		pip install -r requirements.txt #用自带的源试试再装一遍
	fi
	#第三次检测是否成功
	if [ -z "`python -c 'import requests;print(requests)'`" ]; then
		mkdir python && cd python
		git clone https://github.com/shazow/urllib3.git && cd urllib3
		python setup.py install && cd ..
		git clone https://github.com/nakagami/CyMySQL.git && cd CyMySQL
		python setup.py install && cd ..
		git clone https://github.com/requests/requests.git && cd requests
		python setup.py install && cd ..
		git clone https://github.com/pyca/pyopenssl.git && cd pyopenssl
		python setup.py install && cd ..
		git clone https://github.com/cedadev/ndg_httpsclient.git && cd ndg_httpsclient
		python setup.py install && cd ..
		git clone https://github.com/etingof/pyasn1.git && cd pyasn1
		python setup.py install && cd ..
		rm -rf python
	fi	
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	cp apiconfig.py userapiconfig.py
	cp config.json user-config.json
}

install_ubuntu_ssr(){
    read -e -p "后端名字是:(默认: yahaha):" Username
	[[ -z ${Username} ]] && Username="yahaha"
	
	read -e -p "[y/n]是否是合租后端(默认: n):" yn
	[[ -z ${yn} ]] && yn="n"
	if [[ ${yn} == [Nn] ]]; then
	    git clone "https://gitee.com/superbox/p3-Superbox.git" "/root/shadowsocks-${Username}"
	else
        git clone "https://gitee.com/superbox/p3-hezu.git" "/root/shadowsocks-${Username}"
	fi

	apt-get -y update
	apt-get -y install build-essential wget iptables git supervisor lsof python-pip
	#编译安装libsodium
    #wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/libsodium.sh && chmod +x libsodium.sh && bash libsodium.sh
    
		apt-get update
		echo -e "${Info} 安装依赖..."
		apt-get install -y build-essential
		echo -e "${Info} 下载..."
		wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz
		echo -e "${Info} 解压..."
		tar -xzf libsodium-1.0.18-stable.tar.gz && cd libsodium-stable
		echo -e "${Info} 编译安装..."
		./configure --disable-maintainer-mode && make -j2 && make install
    
    rm -rf libsodium.sh
	pip install cymysql -i https://pypi.org/simple/
	
	#clone shadowsocks
	
	cd /root
	cd /root/shadowsocks-${Username}
	chkconfig supervisord on
	#第一次安装
	pip install -I requests==2.9
	python_test
	pip install -r requirements.txt -i $pyAddr	
	#第二次检测是否安装成功
	if [ -z "`python -c 'import requests;print(requests)'`" ]; then
		pip install -r requirements.txt #用自带的源试试再装一遍
	fi
	#第三次检测是否成功
	if [ -z "`python -c 'import requests;print(requests)'`" ]; then
		mkdir python && cd python
		git clone https://github.com/shazow/urllib3.git && cd urllib3
		python setup.py install && cd ..
		git clone https://github.com/nakagami/CyMySQL.git && cd CyMySQL
		python setup.py install && cd ..
		git clone https://github.com/requests/requests.git && cd requests
		python setup.py install && cd ..
		git clone https://github.com/pyca/pyopenssl.git && cd pyopenssl
		python setup.py install && cd ..
		git clone https://github.com/cedadev/ndg_httpsclient.git && cd ndg_httpsclient
		python setup.py install && cd ..
		git clone https://github.com/etingof/pyasn1.git && cd pyasn1
		python setup.py install && cd ..
		rm -rf python
	fi
	chmod +x *.sh
	# 配置程序
	cp apiconfig.py userapiconfig.py
	cp config.json user-config.json
}


install_node(){
	#check os version
	check_sys(){
		if [[ -f /etc/redhat-release ]]; then
			release="centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			release="debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			release="debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
	    fi
		bit=`uname -m`
	}
	install_ssr_for_each(){
		check_sys
		if [[ ${release} = "centos" ]]; then
			install_pm2
			###install_python3
			install_centos_ssr
			remove_supervisor_for_each
			use_centos_pm2
		else
			install_pm2
			###install_python3
			install_ubuntu_ssr
			remove_supervisor_for_each	
			use_debian_pm2
		fi
	}

	# 取消文件数量限制
	sed -i '$a * hard nofile 512000\n* soft nofile 512000' /etc/security/limits.conf

	#帮助信息
	echo "#########################################################################################
【前端地址填写规范】
[1]填写IP，需包含http://，例如：http://123.123.123.123
[2]填写域名，需包含http:// 或 https://，例如：https://ssr.domain.com
注意：前端地址若为域名且为https站点，请确保https配置正确(浏览器访问不提示错误即可)

【mukey填写规范】
若没有修改过前端的/home/wwwroot/default/.config.php文件中的$System_Config['muKey']项
则设置该项时，回车即可。若您修改了该项，请输入您设置的值

【节点ID填写规范】
前端搭建完成后，访问前端地址，使用默认管理员账户登陆，管理面板，节点列表，点击右下角的+号
设置节点信息，需要注意的是，节点地址可填域名或IP，节点IP只能填节点IP，设置完成后点添加
返回节点列表，就能看到你刚刚添加的节点的节点ID
#########################################################################################"
	#获取节点信息
	read -p "前端地址是:" Userdomain
	read -p "节点ID是:" UserNODE_ID
	read -p "MuKey是:" Usermukey
        install_ssr_for_each
	#配置节点信息
	cd /root/shadowsocks-${Username}
	#备份
	cp /root/shadowsocks-${Username}/userapiconfig.py /root/shadowsocks-${Username}/userapiconfig.py.bak
	#修改
	Userdomain=${Userdomain:-"http://${server_ip}"}
	sed -i "s#http://zhaoj.in#${Userdomain}#" /root/shadowsocks-${Username}/userapiconfig.py
	Usermukey=${Usermukey:-"mupass"}
	sed -i "s#glzjin#${Usermukey}#" /root/shadowsocks-${Username}/userapiconfig.py
	UserNODE_ID=${UserNODE_ID:-"3"}
	sed -i '2d' /root/shadowsocks-${Username}/userapiconfig.py
	sed -i "2a\NODE_ID = ${UserNODE_ID}" /root/shadowsocks-${Username}/userapiconfig.py
	#启用supervisord
	echo_supervisord_conf > /etc/supervisord.conf
	sed -i '$a [program:ssr]\ncommand = python /root/shadowsocks-${Username}/server.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
	supervisord
	#iptables
	iptables -P INPUT ACCEPT
	iptables -F
	iptables -F
	iptables -X
	#iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
	#iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
	iptables-save >/etc/sysconfig/iptables
	iptables-save >/etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
	echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
	chmod +x /etc/rc.d/rc.local
	#创建快捷重启命令
	rm -rf /usr/bin/srs
	echo "#!/bin/bash" >> /usr/bin/srs
	echo "pm2 restart all" >> /usr/bin/srs
	chmod +x /usr/bin/srs
	#最后配置
	#/usr/bin/supervisord -c /etc/supervisord.conf
	pm2 restart ssr
	#完成提示
	clear;echo "########################################
# SS NODE 已安装完成                   #
########################################
# 启动SSR：pm2 start ssr               #
# 停止SSR：pm2 stop ssr                #
# 重启SSR：pm2 restart ssr             #
# 或：srs                              #
########################################"
}

#More-[5]
python_more(){
    echo "选项：[1]安装Gost服务器 [2]Git更新后端 [3]安装ocserv [4]安装python3"
	read more_option
	if [ ${more_option} = '1' ]; then
		install_gost
	elif [ ${more_option} = '2' ]; then
		git_update
	elif [ ${more_option} = '3' ]; then
		install_ocserv
	elif [ ${more_option} = '4' ]; then
		install_python3
	else
		echo "选项不在范围,操作中止.";exit 0
	fi
}

install_gost(){
           #检查文件gost.sh是否存在,若不存在,则下载该文件
		if [ ! -f /root/gost.sh ]; then
		    wget -N --no-check-certificate https://code.aliyun.com/supppig/gost/raw/master/gost.sh
            chmod +x gost.sh
            fi
            bash gost.sh
	    }
git_update(){
                if [ ! -f /root/shadowsocks/userapiconfig.py ]; then
		        echo "Tan90°"
                else
	         	git clone -b manyuser https://github.com/Super-box/p3.git          
                \cp -r -f /root/p3/* /root/shadowsocks
			    rm -rf /root/p3
                fi
        }
install_ocserv(){
        check_sys
        echo "$release"     
        if [ ${release} = 'centos' ]; then
        	yum update -y
            yum install epel-release -y
	        yum install ocserv radiusclient-ng unzip -y
            yum -y install dos2unix

                if ! wget -N --no-check-certificate https://github.com/Super-box/a5/raw/master/ocserv.zip -O /etc/ocserv.zip; then
		    echo -e "${Error} ocserv 服务 配置文件下载失败 !" && exit
	        fi
                unzip -o /etc/ocserv.zip -d /etc

                if ! wget -N --no-check-certificate https://github.com/Super-box/a5/raw/master/radiusclient-ng.zip -O /etc/radiusclient-ng.zip; then
		    echo -e "${Error} radius 服务 配置文件下载失败 !" && exiy
	        fi
                unzip -o /etc/radiusclient-ng.zip -d /etc
            
                if ! wget -N --no-check-certificate https://github.com/Super-box/v3/raw/master/setiptables.sh -O /root/setiptables.sh; then
                echo -e "${Error} iptables文件下载失败 !" && exit
	        fi
                dos2unix /root/setiptables.sh
	            chmod +x /root/setiptables.sh
                bash /root/setiptables.sh
                rm -rf /root/setiptables.sh

            if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/service/ocserv_debian -O /etc/init.d/ocserv; then
		        echo -e "${Error} ocserv 服务 管理脚本下载失败 !" && exit
	        fi

            if ! wget --no-check-certificate https://github.com/Super-box/a5/raw/master/updatessl.sh -O /etc/ocserv/updatessl.sh; then
                echo -e "${Error} ocserv 服务 SSL更新脚本下载失败 !" && exit
            fi
                dos2unix /etc/ocserv/updatessl.sh
	            chmod +x /etc/init.d/ocserv
	            echo -e "${Info} ocserv 服务 管理脚本下载完成 !"
                /etc/rc.d/init.d/ocserv stop
	            chkconfig --add /etc/rc.d/init.d/ocserv
	            chkconfig /etc/rc.d/init.d/ocserv on
	            #systemctl enable ocserv.service
	            /usr/sbin/service ocserv restart
	            #systemctl status ocserv.service
                rm -rf /etc/ocserv.zip
                rm -rf /etc/radiusclient-ng.zip
		else
			echo "懒得写了"

		fi   
        }

install_python3(){
        check_sys
        echo "$release"     
        if [ ${release} = 'centos' ]; then
        	sudo yum update -y
            sudo yum install epel-release -y
            sudo yum install https://centos7.iuscommunity.org/ius-release.rpm -y
            sudo yum install python36u python36u-pip -y
            sudo mv /bin/pip /bin/pip-backup
            sudo mv /bin/python /bin/python-backup
            sudo ln -sf /bin/pip3.6 /bin/pip
            sudo ln -sf /bin/python3.6 /bin/python
            python -m pip install --upgrade pip
            if ! wget --no-check-certificate https://raw.githubusercontent.com/fanvinga/dockerfiles/master/ssrmu/requirements.txt -O /root/requirements.txt; then
                echo -e "${Error} 依赖列表下载失败 !" && exit
            fi
            sudo pip install -r /root/requirements.txt
            sudo rm -rf /root/requirements.txt
            sed -i '1c #!/usr/bin/python2.7' /usr/bin/yum
            sed -i '1c #!/usr/bin/python2.7' /usr/libexec/urlgrabber-ext-down
        elif [ ${release} = 'ubuntu' ]; then
        	apt install sudo -y
			sudo apt-get autoremove python3.5 python3.5-dev -yq
			sudo apt-get install dirmngr sudo gcc -y
			#echo "deb http://mirrors.163.com/ubuntu/ bionic main" >> /etc/apt/sources.list
			#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
			#echo 'APT::Default-Release "cosmic-updates";' | sudo tee -a /etc/apt/apt.conf.d/00local
            sudo apt-get update
            sudo apt-get install python3.6 python3.6-dev python3-distutils python3-pip -y
            sudo wget -N https://bootstrap.pypa.io/get-pip.py
            sudo python3 get-pip.py
            sudo rm -rf get-pip.py
            sudo mv /bin/pip /bin/pip-backup
            sudo mv /usr/bin/python /usr/bin/python-backup
            sudo ln -sf /usr/bin/python3.6 /usr/bin/python
            sudo ln -sf /usr/local/bin/pip3.6 /bin/pip
            if ! wget --no-check-certificate https://raw.githubusercontent.com/fanvinga/dockerfiles/master/ssrmu/requirements.txt -O /root/requirements.txt; then
                echo -e "${Error} 依赖列表下载失败 !" && exit
            fi
            sudo pip install -r /root/requirements.txt
            sudo rm -rf /root/requirements.txt
 		elif [ ${release} = 'debian' ]; then
            apt install sudo -y
			sudo apt-get autoremove python3.5 python3.5-dev -yq
			sudo apt-get install dirmngr sudo gcc -y
			#echo "deb http://mirrors.163.com/ubuntu/ bionic main" >> /etc/apt/sources.list
			#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
			#echo 'APT::Default-Release "cosmic-updates";' | sudo tee -a /etc/apt/apt.conf.d/00local
            sudo apt-get update
            sudo apt-get install python3.6 python3.6-dev python3-distutils python3-pip -y
            sudo wget -N https://bootstrap.pypa.io/get-pip.py
            sudo python3 get-pip.py
            sudo rm -rf get-pip.py
            sudo mv /bin/pip /bin/pip-backup
            sudo mv /usr/bin/python /usr/bin/python-backup
            sudo ln -sf /usr/bin/python3.6 /usr/bin/python
            sudo ln -sf /usr/local/bin/pip3.6 /bin/pip
            if ! wget --no-check-certificate https://raw.githubusercontent.com/fanvinga/dockerfiles/master/ssrmu/requirements.txt -O /root/requirements.txt; then
                echo -e "${Error} 依赖列表下载失败 !" && exit
            fi
            sudo pip install -r /root/requirements.txt
            sudo rm -rf /root/requirements.txt
        else
            echo "您的系统暂不支持"
		fi              
        }

#一键安装加速-[6]
serverspeeder(){
	echo "选项：[1]KVM安装 [2]OVZ安装"
	read serverspeeder_option
	if [ ${serverspeeder_option} = '1' ]; then
		#检查文件tcp.sh是否存在,若不存在,则下载该文件
	    if [ ! -f /root/tcp.sh ]; then
		wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
		chmod +x tcp.sh
	    fi
	    #执行
		./tcp.sh
	elif [ ${serverspeeder_option} = '2' ]; then
		#检查文件tcp.sh是否存在,若不存在,则下载该文件
		check_sys
		echo "$release"
		if [ ${release} = 'centos' ]; then
			wget -N --no-check-certificate "https://github.com/tcp-nanqinlang/lkl-rinetd/releases/download/1.1.0/tcp_nanqinlang-rinetd-centos.sh"
            chmod +x tcp_nanqinlang-rinetd-centos.sh
            ./tcp_nanqinlang-rinetd-centos.sh
		else
			wget -N --no-check-certificate "https://github.com/tcp-nanqinlang/lkl-rinetd/releases/download/1.1.0/tcp_nanqinlang-rinetd-debianorubuntu.sh"
            chmod +x tcp_nanqinlang-rinetd-debianorubuntu.sh
            ./tcp_nanqinlang-rinetd-debianorubuntu.sh
		fi
	fi
}

#一键全面测速-[7]
speedtest(){
    check_sys
    echo "选项：[1]全面测试 [2]测试CPU [3]内存测试"
    read speedtest
        if [ ${speedtest} = '1' ]; then
        #检查文件ZBench-CN.sh是否存在,若不存在,则下载该文件
            if [ ! -f /root/ZBench-CN.sh ]; then
                wget https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZBench-CN.sh
                chmod +x ZBench-CN.sh
            fi
       #执行测试
       bash /root/ZBench-CN.sh
        elif [ ${speedtest} = '2' ]; then
            curl -fsSL https://ilemonrain.com/download/shell/LemonBench.sh | bash -s sbcfast
        elif [ ${speedtest} = '3' ]; then
            if [ ${release} = 'centos' ]; then
                yum install wget -y
                yum groupinstall "Development Tools" -y
                wget https://raw.githubusercontent.com/FunctionClub/Memtester/master/memtester.cpp
                gcc -l stdc++ memtester.cpp
                ./a.out
            else
                #Ubuntu / Debian
                apt-get update
                apt-get install wget build-essential -y
                wget https://raw.githubusercontent.com/FunctionClub/Memtester/master/memtester.cpp
                gcc -l stdc++ memtester.cpp
                ./a.out
            fi
        else
            echo "选项不在范围,操作中止.";exit 0
        fi
}

#More-[8]
system_more(){
    echo "选项：[1]添加SWAP [2]更改SSH端口 [3]DDNS动态脚本"
	read more_option
        if [ ${more_option} = '1' ]; then
            swap
	    elif [ ${more_option} = '2' ]; then
		    install_ssh_port
	    elif [ ${more_option} = '3' ]; then
	        ddns
	    else
		    echo "选项不在范围,操作中止.";exit 0
	    fi
}

swap(){
	echo "选项：[1]500M [2]1G [3]删除SWAP"
		read swap
	if [ ${swap} = '1' ]; then
		#判断/var/swapfile1文件是否存在
		if [ ! -f /var/swapfile1 ]; then
			#增加500Mb的Swap分区
			dd if=/dev/zero of=/var/swapfile1 bs=1024 count=512000
			mkswap /var/swapfile1;chmod 0644 /var/swapfile1;swapon /var/swapfile1
			echo "/var/swapfile1 swap swap defaults 0 0" >> /etc/fstab
			echo "已经成功添加SWAP"
		else
			echo "检查到您已经添加SWAP,无需重复添加"
		fi

	elif [ ${swap} = '2' ]; then
		#判断/var/swapfile1文件是否存在
		if [ ! -f /var/swapfile1 ]; then
		dd if=/dev/zero of=/var/swapfile1 bs=1024 count=1048576
	        mkswap /var/swapfile1;chmod 0644 /var/swapfile1;swapon /var/swapfile1
	        echo '/var/swapfile1 swap swap default 0 0' >> /etc/fstab
	        echo "已经成功添加SWAP"
		else
			echo "检查到您已经添加SWAP,无需重复添加"
		fi

	elif [ ${swap} = '3' ]; then
		#判断/var/swapfile1文件是否存在
		if [ ! -f /var/swapfile1 ]; then
 		    echo "检查到您未添加SWAP"
		else
	        swapoff /var/swapfile1
                sed -i "/swapfile1/d" /etc/fstab
                rm -rf /var/swapfile1
		fi
	else
		echo "选项不在范围.";exit 0
	fi
}

install_ssh_port(){
	#检查文件sshport.sh是否存在,若不存在,则下载该文件
	if [ ! -f /root/sshport.sh ]; then
		wget -N —no-check-certificate https://www.moerats.com/usr/down/sshport.sh
	    chmod +x sshport.sh
	fi
	    ./sshport.sh
        service restart sshd
}

ddns(){
    echo "选项：[1]安装 [2]配置 [3]运行"
	read ddns
	if [ ${ddns} = '1' ]; then
	    if [ ! -f /root/ddns/cf-ddns.sh ]; then
	    	echo "DDNS未配置，开始下载";
	    	wget -N —no-check-certificate "https://github.com/Super-box/v3/raw/master/cf-ddns.sh" -P /root/ddns
	    	chmod +x /root/ddns/cf-ddns.sh
	    fi
	    #清屏
		clear
		#获取新配置信息
		read -p "新的DDNS地址是:" CFRECORD_NAME
		#修改
		CFRECORD_NAME=${CFRECORD_NAME}
		sed -i "s#aaa.yahaha.pro#${<C></C>FRECORD_NAME}#" /root/ddns/cf-ddns.sh
		#运行
		/usr/bin/bash /root/ddns/cf-ddns.sh
	     
        elif [ ${ddns} = '2' ]; then
		#清屏
		clear
        #判断DDNS文件是否存在
        if [ ! -f /root/ddns/cf-ddns.sh ]; then
            echo "检查到您未安装ddns"
        else
            echo "当前DDNS配置如下:"
            echo "------------------------------------"
            sed -n '9p' /root/ddns/cf-ddns.sh
            sed -n '11p' /root/ddns/cf-ddns.sh
            echo "------------------------------------"
        fi
		#获取新配置信息
		read -p "新的DDNS地址是:" CFRECORD_NAME
			#检查
			if [ ! -f /root/ddns/cf-ddns.sh.bak ]; then
				rm -rf /root/ddns/cloud* && rm -rf /root/ddns/ip*
				wget -N —no-check-certificate "https://github.com/Super-box/v3/raw/master/cf-ddns.sh" -P /root/ddns
			else
			#还原
				rm -rf /root/ddns/cf-ddns.sh && rm -rf /root/ddns/cloud* && rm -rf /root/ddns/ip*
				cp /root/ddns/cf-ddns.sh.bak /root/ddns/cf-ddns.sh
			fi
		#修改
		CFRECORD_NAME=${CFRECORD_NAME}
		sed -i "s#aaa.yahaha.pro#${CFRECORD_NAME}#" /root/ddns/cf-ddns.sh
                #运行
                rm -rf /root/ddns/cloud* && rm -rf /root/ddns/ip*
                /usr/bin/bash /root/ddns/cf-ddns.sh
        elif [ ${ddns} = '3' ]; then
		#判断DDNS文件是否存在
		if [ ! -f /root/ddns/cf-ddns.sh ]; then
 		    echo "检查到您未安装ddns"
		else
	        echo "当前DDNS配置如下:"
		    echo "------------------------------------"
		    sed -n '9p' /root/ddns/cf-ddns.sh
		    sed -n '11p' /root/ddns/cf-ddns.sh
		    echo "------------------------------------"
		fi
		    #运行
		    /usr/bin/bash /root/ddns/cf-ddns.sh
	else
		echo "选项不在范围.";exit 0
	fi
}

#卸载各类云盾-[a]
uninstall_ali_cloud_shield(){
	echo "请选择：[1]卸载阿里云盾 [2]卸载腾讯云盾";read uninstall_ali_cloud_shield

	if [ ${uninstall_ali_cloud_shield} = '1' ]; then
        wget -N https://www.moerats.com/usr/shell/jk_uninstall.sh -P /root
        chmod +x jk_uninstall.sh
        ./jk_uninstall.sh ai
        echo "成功卸载阿里云云盾"
        rm -rf /root/jk_uninstall.sh
    elif [ ${uninstall_ali_cloud_shield} = '2' ]; then
    #检查文件jk_uninstall.sh是否存在,若不存在,则下载该文件
	    if [ ! -f /root/jk_uninstall.sh ]; then
	    	wget -N https://www.moerats.com/usr/shell/jk_uninstall.sh -P /root
	    	chmod +x jk_uninstall.sh
	    fi
            ./jk_uninstall.sh tx
            echo "成功卸载腾讯云云盾"
            rm -rf /root/jk_uninstall.sh
    	else
    		echo "选项不在范围内";exit 0
    	fi
}

#回程路由测试-[b]
nali_test(){
	echo "请输入目标IP：";read purpose_ip
	nali-traceroute -q 1 ${purpose_ip}
}

besttrace_test(){
	echo "请输入目标IP：";read purpose_ip
	cd /root/besttrace
	./besttrace -q 1 ${purpose_ip}
}

mtr_test(){
	echo "请输入目标IP：";read purpose_ip
	echo "请输入测试次数："
	read MTR_Number_of_tests
	mtr -c ${MTR_Number_of_tests} --report ${purpose_ip}
}

detect_backhaul_routing(){
	echo "选项：[1]Nali [2]BestTrace [3]MTR"
	read detect_backhaul_routing_version
	if [ ${detect_backhaul_routing_version} = '1' ]; then
		#判断/root/nali-ipip/configure文件是否存在
		if [ ! -f /root/nali-ipip/configure ]; then
			echo "检查到您未安装,脚本将先进行安装..."
			yum -y update;yum -y install traceroute git gcc make
			git clone https://github.com/dzxx36gyy/nali-ipip.git
			cd nali-ipip
			./configure && make && make install
			clear;nali_test
		else
			nali_test
		fi
	elif [ ${detect_backhaul_routing_version} = '2' ]; then
		#判断/root/besttrace/besttrace文件是否存在
		if [ ! -f /root/besttrace/besttrace ]; then
			echo "检查到您未安装,脚本将先进行安装..."
			yum update -y
			yum install traceroute unzip -y
			wget -N --no-check-certificate "https://cdn.ipip.net/17mon/besttrace4linux.zip"
			unzip besttrace4linux.zip -d besttrace && cd besttrace && chmod +x *
			clear;
            rm -rf /root/*.zip
            besttrace_test
		else
			besttrace_test
		fi
	elif [ ${detect_backhaul_routing_version} = '3' ]; then
		#判断/usr/sbin/mtr文件是否存在
		if [ ! -f /usr/sbin/mtr ]; then
			echo "检查到您未安装,脚本将先进行安装..."
			yum update -y;yum install mtr -y
			clear;mtr_test
		else
			mtr_test
		fi
	else
		echo "选项不在范围.";exit 0
	fi
}

#简易测速-[c]
superspeed(){
	#检查文件superspeed.sh是否存在,若不存在,则下载该文件
	if [ ! -f /root/superspeed.sh ]; then
		wget -N --no-check-certificate "https://github.com/Super-box/v3/raw/master/superspeed.sh" /root/superspeed.sh
		chmod +x /root/superspeed.sh
	fi
	#执行测试
    ./superspeed.sh
}

#检测BBR安装状态-[d]
check_bbr_installation(){
	echo "查看内核版本,含有4.12即可";uname -r
	echo "------------------------------------------------------------"
	echo "返回：net.ipv4.tcp_available_congestion_control = bbr cubic reno 即可";sysctl net.ipv4.tcp_available_congestion_control
	echo "------------------------------------------------------------"
	echo "返回：net.ipv4.tcp_congestion_control = bbr 即可";sysctl net.ipv4.tcp_congestion_control
	echo "------------------------------------------------------------"
	echo "返回：net.core.default_qdisc = fq 即可";sysctl net.core.default_qdisc
	echo "------------------------------------------------------------"
	echo "返回值有 tcp_bbr 模块即说明bbr已启动";lsmod | grep bbr
}

#更换默认源-[g]
replacement_of_installation_source(){
	echo "请选择更换目标源： [1]网易163 [2]阿里云 [3]自定义 [4]恢复默认源"
	read change_target_source
	
	#备份
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
	
	#执行
	if [ ${change_target_source} = '1' ]; then
		echo "更换目标源:网易163,请选择操作系统版本： [1]Centos 5 [2]Centos 6 [3]Centos 7"
		read operating_system_version
		if [ ${operating_system_version} = '1' ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS5-Base-163.repo;yum clean all;yum makecache
		elif [ ${operating_system_version} = '2' ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo;yum clean all;yum makecache
		elif [ ${operating_system_version} = '3' ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo;yum clean all;yum makecache
		fi
	elif [ ${change_target_source} = '2' ]; then
		echo "更换目标源:阿里云,请选择操作系统版本： [1]Centos 5 [2]Centos 6 [3]Centos 7"
		read operating_system_version
		if [ ${operating_system_version} = '1' ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo;yum clean all;yum makecache
		elif [ ${operating_system_version} = '2' ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo;yum clean all;yum makecache
		elif [ ${operating_system_version} = '3' ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo;yum clean all;yum makecache
		fi
	elif [ ${change_target_source} = '3' ]; then
		echo "更换目标源:自定义,请确定您需使用的自定义的源与您的操作系统相符！";echo "请输入自定义源地址："
		read customize_the_source_address
		wget -O /etc/yum.repos.d/CentOS-Base.repo ${customize_the_source_address};yum clean all;yum makecache
	elif [ ${change_target_source} = '4' ]; then
		rm -rf /etc/yum.repos.d/CentOS-Base.repo
		mv /etc/yum.repos.d/CentOS-Base.repo.bak /etc/yum.repos.d/CentOS-Base.repo
		yum clean all;yum makecache
	fi
}

#配置防火墙-[e]
configure_firewall(){
	echo "请选择操作： [1]关闭firewall"
	read firewall_operation

	if [ ${firewall_operation} = '1' ]; then
		echo "停止firewall..."
		systemctl stop firewalld.service
		echo "禁止firewall开机启动"
		systemctl disable firewalld.service
		echo "查看默认防火墙状态,关闭后显示notrunning,开启后显示running"
		firewall-cmd --state
	else
		echo "选项不在范围,操作中止.";exit 0
	fi
}

update_the_shell(){
		rm -rf /root/v3.sh v3.sh.*
		wget -N "https://github.com/Super-box/v3/raw/master/v3.sh" /root/v3.sh
	        #将脚本作为命令放置在/usr/bin目录内,最后执行
	        rm -rf /usr/bin/v3;cp /root/v3.sh /usr/bin/v3;chmod +x /usr/bin/v3
	        v3
}

###待更新
safe_dog(){
	#判断/usr/bin/sdui文件是否存在
	if [ ! -f /usr/bin/sdui ]; then
		echo "检查到您未安装,脚本将先进行安装..."
		wget -N —no-check-certificate  "http://sspanel-1252089354.coshk.myqcloud.com/safedog_linux64.tar.gz"
		tar xzvf safedog_linux64.tar.gz
		mv safedog_an_linux64_2.8.19005 safedog
		cd safedog;chmod +x *.py
		yum -y install mlocate lsof psmisc net-tools
		./install.py
		echo "安装完成,请您重新执行脚本."
	else
		sdui
	fi
}

install_fail2ban(){
	echo "脚本来自:http://www.vpsps.com/225.html";echo "使用简介:https://linux.cn/article-5067-1.html";echo "感谢上述贡献者."
	echo "选择选项: [1]安装fail2ban [2]卸载fail2ban [3]查看封禁列表 [4]为指定IP解锁";read fail2ban_option
	if [ ${fail2ban_option} = '1' ]; then
		wget -N —no-check-certificate"http://sspanel-1252089354.coshk.myqcloud.com/fail2ban.sh";bash fail2ban.sh
	elif [ ${fail2ban_option} = '2' ]; then
		wget -N —no-check-certificate"https://raw.githubusercontent.com/FunctionClub/Fail2ban/master/uninstall.sh";bash uninstall.sh
	elif [ ${fail2ban_option} = '3' ]; then
		echo ${separate_lines};fail2ban-client ping;echo -e "\033[31m[↑]正常返回值:Server replied: pong\033[0m"
		#iptables --list -n;echo -e "\033[31m#当前iptables禁止规则\033[0m"
		fail2ban-client status;echo -e "\033[31m[↑]当前封禁列表\033[0m"
		fail2ban-client status ssh-iptables;echo -e "\033[31m[↑]当前被封禁的IP列表\033[0m"
		sed -n '12,14p' /etc/fail2ban/jail.local;echo -e "\033[31m[↑]当前fail2ban配置\033[0m"
	elif [ ${fail2ban_option} = '4' ]; then
		echo "请输入需要解锁的IP地址:";read need_to_unlock_the_ip_address
		fail2ban-client set ssh-iptables unbanip ${need_to_unlock_the_ip_address}
		echo "已为${need_to_unlock_the_ip_address}解除封禁."
	else
		echo "选项不在范围.";exit 0
	fi
}

install_shell(){
	if [ ! -f /usr/bin/v3 ]; then
		cp /root/v3.sh /usr/bin/v3 && chmod +x /usr/bin/v3
	else
		rm -rf /usr/bin/v3
		cp /root/v3.sh /usr/bin/v3 && chmod +x /usr/bin/v3
		clear;echo "Tips:您可通过命令[v3]快速启动本脚本!"
	fi
}

get_server_ip_info(){
	if [ ! -f /root/.server_ip_info.txt ]; then
		curl -s https://ipv4.vircloud.net > /root/.server_ip_info.txt
	else
		rm -rf /root/.server_ip_info.txt
		curl -s https://ipv4.vircloud.net > /root/.server_ip_info.txt
	fi
	read server_ip_info < /root/.server_ip_info.txt
}

#安装本脚本,获取服务器IP信息
install_shell
get_server_ip_info

action=$1
if [[ "${action}" == "pm2-update" ]]; then
    update_pm2
else
start_menu
fi

i=1
while((i <= 100))
do
keep_loop
done

#END 2018年12月16日