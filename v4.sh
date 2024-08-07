#!/bin/bash

#检测root账户
[ $(id -u) != "0" ] && { echo "请切换至root账户执行此脚本."; exit 1; }

#全局变量
separate_lines="####################################################################"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#开始菜单
start_menu(){
clear
echo && echo -e "####################################################################
# 版本：V.0.0.3 2022-07-01                                         #
####################################################################
# [1] 网络重装系统                                                 #
# [2] 更改Linux源                                                  #
# [3] SSH-Key                                                      #
# [4] BBR脚本                                                      #
# [5] 安装Gost                                                     #
# [6] PM2相关                                                      #
# [7] 安装SS_NODE依赖                                            #
# [8] 回程路由查询                                                  #
# [9] 流媒体检测                                                    #
####################################################################
# [a]DDNS安装 [b]Chat测试 [c]路由检测 [d]Linux安装SSR客户端   #
# [e]null [f]null [g]null [h]null   #
# [w]crontab修改                                #
####################################################################
# [x]刷新脚本 [y]更新脚本 [z]退出脚本                              #
# 此服务器IP信息：${server_ip_info} 国家:${country}
####################################################################"

stty erase '^H' && read -p "请选择安装项[1-9]:" num
clear
case "$num" in
    1)
    dd_reinstall;;
    2)
    change_linux_source;;
    3)
    ssh_key;;
    4)
    bbr_install;;
    5)
    gost_install;;
    6)
    pm2_list;;
    7)
    ssr_node_install;;
    8)
    mtr_trace_back;;
    9)
    MediaUnlockTest;;
    a)
    ddns_install;;
    b)
    check_chatgpt;;
    c)
    mtr_trace;;    
    d)
    ssr_linux_install;;
    w)
    set_crontab;;
    x)
    rm -rf /usr/bin/v4
    cp -r /root/v4.sh /usr/bin/v4
    chmod +x /usr/bin/v4
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

base(){
    echo "base"
}

bbr_install(){
    if [[ ${country} = "CN" ]]; then
        bash <(curl -Ls https://raw.githubusercontents.com/ylx2016/Linux-NetSpeed/master/tcp.sh);exit 0
    else 
        bash <(curl -Ls https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh);exit 0
    fi
}

check_crontab_installed_status(){
    if [[ ! -e /usr/bin/cleanLog ]]; then
        echo -e "${Error} cleanLog 没有安装，开始安装..."
            wget -N "https://raw.githubusercontent.com/windupcloud/v3/master/cleanLog" /root/cleanLog
            cp -r /root/cleanLog /usr/bin/cleanLog
            rm -rf /root/cleanLog
            sudo chmod +x /usr/bin/cleanLog
    else
        echo "已经安装"
    fi
}

check_chatgpt(){
    bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh);exit 0
}

check_country(){
    resultverify="$(echo $(curl 3.0.3.0/ips) | grep -nP "China")"
    if [ "$?" = "0" ]; then
        country="CN"
    else
        country="Else"            
    fi
}

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

change_linux_source(){
    bash <(curl -sSL https://raw.githubusercontents.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh);exit 0
}

dd_reinstall(){
    #curl -sSL -k -o dd.sh https://raw.githubusercontent.com/haoduck/dd/master/dd.sh && chmod +x dd.sh && bash dd.sh

    curl -sSL -k -o dd.sh https://fastly.jsdelivr.net/gh/haoduck/dd@latest/dd.sh && chmod +x dd.sh && bash dd.sh

    #wget -N --no-check-certificate https://down.vpsaff.net/linux/dd/network-reinstall-os.sh
    #chmod +x network-reinstall-os.sh
    #./network-reinstall-os.sh
}

ddns_install(){
    if [ ! -f /usr/bin/ddns ]; then
        check_sys
        if [[ ${release} = "centos" ]]; then
            yum install python-pip -y
            pip install --upgrade "pip < 21.0"
            pip install ddns
        else
            apt install python3-pip -y
            pip install --upgrade "pip < 21.0"
            pip install ddns
        fi
    else
        echo "DDNS已经安装"
        if [ ! -f /root/config.json ]; then
            echo "下载配置文件"
            wget -N --no-check-certificate "https://raw.githubusercontents.com/windupcloud/v3/master/config.json" -P /root
        else
            echo "当前DDNS配置如下:"
            echo "------------------------------------"
            sed -n '9p' /root/config.json
            echo "------------------------------------"
        fi
        stty erase '^H' && read -p "新的DDNS地址是:" CFRECORD_NAME
        CFRECORD_NAME=${CFRECORD_NAME}
        wget -N —no-check-certificate "https://raw.githubusercontents.com/windupcloud/v3/master/config.json" -P /root
        sed -i "s#aaa.yahaha.pro#${CFRECORD_NAME}#" /root/config.json
        ddns_local=$(echo $(find /usr/ -name ddns))
        ${ddns_local}
    fi
    exit 0;
}

get_server_ip_info(){
    server_ip_info=$(curl -s ifconfig.co)
}

gost_install(){
    bash <(curl -sSL https://raw.githubusercontents.com/windupcloud/v3/master/ghost.sh);exit 0
}

install_shell(){
    if [ ! -f /usr/bin/v4 ]; then
        cp -r /root/v4.sh /usr/bin/v4
        chmod +x /usr/bin/v4
    else
        rm -rf /usr/bin/v4
        cp -r /root/v4.sh /usr/bin/v4
        chmod +x /usr/bin/v4
        clear;echo "Tips:您可通过命令[v4]快速启动本脚本!"
    fi
}

keep_loop(){
#继续还是中止
echo ${separate_lines};echo -n "继续(y)还是中止(n)? [y/n]:"
    stty erase '^H' && read -e -p "(默认: n):" yn
    [[ -z ${yn} ]] && yn="n"
    if [[ ${yn} == [Nn] ]]; then
    echo "已取消..." && exit 1
    else
        clear
        sleep 2s
        start_menu
    fi
}

mtr_trace(){
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/vpsxb/testrace@main/testrace.sh);exit 0
}

mtr_trace_back(){
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/zhucaidan/mtr_trace@main/mtr_trace.sh);exit 0 
}

MediaUnlockTest(){
    #bash <(curl -sSL https://cdn.jsdelivr.net/gh/lmc999/RegionRestrictionCheck@main/check.sh);exit 0
    bash <(curl -L -s media.ispvps.com)
}

pm2_list(){
    echo "选项：[1]安装PM2 [2]配置PM2 [3]卸载PM2"
    stty erase '^H' && read pm2_option
    if [ ${pm2_option} = '1' ]; then
        pm2_install
    elif [ ${pm2_option} = '2' ]; then
        pm2_use
    elif [ ${pm2_option} = '3' ]; then
        pm2_remove
    else
        echo "选项不在范围,操作中止.";exit 0
    fi
}

pm2_install(){
    #检查系统版本
    check_sys
    #判断/usr/bin/pm2文件是否存在
    if [ ! -f /usr/bin/pm2 ]; then
        echo "检查到您未安装pm2,脚本将先进行安装"
        if [[ ${release} = "centos" ]]; then
            yum -y install xz
            yum -y install wget
            yum -y install git
            #切换时钟
            yum install -y ntpdate ntp
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai
            if [[ ${country} = "CN" ]]; then
                /usr/bin/chattr -i /etc/resolv.conf
                mv /etc/resolv.conf /etc/resolv.conf.bak
                echo "#DNS目录" >> /etc/resolv.conf
                echo "nameserver 223.6.6.6 #Aliyun" >> /etc/resolv.conf
                /usr/bin/chattr +i /etc/resolv.conf
            else
                /usr/bin/chattr -i /etc/resolv.conf
                cp -r -n /etc/resolv.conf /etc/resolv.conf.bak
                wget -N https://github.com/windupcloud/v3/raw/master/resolv.conf -P /etc
                /usr/bin/chattr +i /etc/resolv.conf
            fi
            #安装nodejs
            curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash
            sudo yum -y install nodejs
        else
            apt -y install sudo
            apt -y install xz
            apt -y install wget
            apt -y install git
            apt install -y ntpdate ntp
            ps aux |grep ntpd |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai
            if [[ ${country} = "CN" ]]; then
                /usr/bin/chattr -i /etc/resolv.conf
                mv /etc/resolv.conf /etc/resolv.conf.bak
                echo "#DNS目录" >> /etc/resolv.conf
                echo "nameserver 223.6.6.6 #Aliyun" >> /etc/resolv.conf
                /usr/bin/chattr +i /etc/resolv.conf
            else
                /usr/bin/chattr -i /etc/resolv.conf
                cp -r -n /etc/resolv.conf /etc/resolv.conf.bak
                wget -N https://github.com/windupcloud/v3/raw/master/resolv.conf -P /etc
                /usr/bin/chattr +i /etc/resolv.conf
            fi
            apt -y install libssl1.1=1.1.1n-0+deb11u3 --allow-downgrades
            apt-get install -y npm
    fi
        npm install pm2 -g
        pm2 startup
        pm2 set pm2:autodump true
        systemctl enable pm2-root
    else
        echo "已经安装pm2"
    fi
    exit 0
}

pm2_use(){
    #检查系统版本
    check_sys
    if [[ ${release} = "centos" ]]; then
        if [ ! -f /usr/bin/killall ]; then
            echo "检查到您未安装psmisc,脚本将先进行安装"
            yum -y install psmisc
        fi
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
        done < <(find /root/ -maxdepth 1 -name "shadowsocks*" -print0)
            ssr_names=()
        for ssr_dir in "${ssr_dirs[@]}"
        do
            ssr_names+=($(basename "$ssr_dir"))
        done
            max_memory_limit=512
        if [ $all -le 256 ] ; then
            max_memory_limit=192
        elif [ $all -le 512 ] ; then
            max_memory_limit=256
        fi
        #创建快捷方式
        rm -rf "/usr/bin/srs"
        echo "#!/bin/bash" >> /usr/bin/srs
        echo "pm2 restart all" >> /usr/bin/srs
        chmod +x /usr/bin/srs
        rm -rf "/usr/bin/ssrr"
        echo "#!/bin/bash" >> /usr/bin/ssrr
        for ssr_name in "${ssr_names[@]}"
        do
            echo "pm2 start /root/${ssr_name}/server.py --name $(echo ${ssr_name} | sed 's/shadowsocks-//') --max-memory-restart ${max_memory_limit}M  -o /dev/null -e /dev/null" >> /usr/bin/ssrr
        done 
        chmod +x /usr/bin/ssrr
        ssrr
    else
        if [ ! -f /usr/bin/killall ]; then
            echo "检查到您未安装psmisc,脚本将先进行安装"
            apt-get install psmisc -y
        fi
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
        done < <(find /root/ -maxdepth 1 -name "shadowsocks*" -print0)
            ssr_names=()
        for ssr_dir in "${ssr_dirs[@]}"
        do
            ssr_names+=($(basename "$ssr_dir"))
        done
            max_memory_limit=512
        if [ $all -le 256 ] ; then
            max_memory_limit=192
        elif [ $all -le 512 ] ; then
            max_memory_limit=256
        fi
        #创建快捷方式
        rm -rf "/usr/bin/srs"
        echo "#!/bin/bash" >> /usr/bin/srs
        echo "pm2 restart all" >> /usr/bin/srs
        chmod +x /usr/bin/srs
        rm -rf "/usr/bin/ssrr"
        echo "#!/bin/bash" >> /usr/bin/ssrr
        for ssr_name in "${ssr_names[@]}"
        do
            echo "pm2 start /root/${ssr_name}/server.py --name $(echo ${ssr_name} | sed 's/shadowsocks-//') --max-memory-restart ${max_memory_limit}M  -o /dev/null -e /dev/null" >> /usr/bin/ssrr
        done 
        chmod +x /usr/bin/ssrr
        ssrr
    fi
    clear;echo "########################################
# SS NODE 已配置完成                   #
########################################
# 启动SSR：pm2 start ssr               #
# 停止SSR：pm2 stop ssr                #
# 重启SSR：pm2 restart ssr             #
# 或：srs                              #
########################################";exit 0
}

pm2_remove(){
    #检查系统版本
    check_sys
    #判断/usr/bin/pm2文件是否存在
    if [ ! -f /usr/bin/pm2 ]; then
        echo "已经卸载pm2"
    else
        if [[ ${release} = "centos" ]]; then
            npm uninstall -g pm2
            yum remove nodejs -y
        else
            npm uninstall -g pm2
            apt-get remove nodejs -y
        fi
    fi
    exit 0
}

set_crontab(){
    check_crontab_installed_status
    crontab_monitor=$(crontab -l|grep "cleanLog")
    if [[ -z "${crontab_monitor}" ]]; then
        echo && echo -e "当前Cron: ${Green_font_prefix}未开启${Font_color_suffix}" && echo
        echo -e "确定要开启 ${Green_font_prefix}Cron${Font_color_suffix} 功能吗?[Y/n]"
        read -e -p "(默认: y):" crontab_monitor_ny
        [[ -z "${crontab_monitor_ny}" ]] && crontab_monitor_ny="y"
        if [[ ${crontab_monitor_ny} == [Yy] ]]; then
            set_crontab_start
        else
            echo && echo "  已取消..." && echo
        fi
    else
        echo && echo -e "当前监控模式: ${Green_font_prefix}已开启${Font_color_suffix}" && echo
        echo -e "确定要关闭 ${Green_font_prefix}Cron${Font_color_suffix} 功能吗？[y/N]"
        read -e -p "(默认: n):" crontab_monitor_ny
        [[ -z "${crontab_monitor_ny}" ]] && crontab_monitor_ny="n"
        if [[ ${crontab_monitor_ny} == [Yy] ]]; then
            set_crontab_stop
        else
            echo && echo "  已取消..." && echo
        fi
    fi    
}

set_crontab_start(){
    crontab -l > "/root/crontab.bak"
    sed -i "/cleanLog/d" "/root/crontab.bak"
    echo -e "\n*/1 * * * *  /usr/bin/cleanLog >> /dev/null 2>&1" >> "/root/crontab.bak"
    crontab "/root/crontab.bak"
    rm -r "/root/crontab.bak"
    cron_config=$(crontab -l | grep "cleanLog")
    if [[ -z ${cron_config} ]]; then
        echo -e "${Error} cleanlog 已关闭 !" && exit 1
    else
        echo -e "${Info} cleanlog 已开启 !"
    fi
}

set_crontab_stop(){
    crontab -l > "/root/crontab.bak"
    sed -i "/cleanLog/d" "/root/crontab.bak"
    crontab "/root/crontab.bak"
    rm -r "/root/crontab.bak"
    cron_config=$(crontab -l | grep "cleanLog")
    if [[ -z ${cron_config} ]]; then
        echo -e "${Error} cleanlog 已关闭 !" && exit 1
    else
        echo -e "${Info} cleanlog 已开启 !"
    fi
}

ssh_key(){
    if [[ ${country} = "CN" ]]; then
        bash <(curl -sSL https://raw.githubusercontents.com/windupcloud/v3/master/key.sh);exit 0
    else
        bash <(curl -sSL https://raw.githubusercontent.com/windupcloud/v3/master/key.sh);exit 0
    fi
}

ssr_node_install(){
    check_sys
    echo "$release" 
    if [[ ${release} = "centos" ]]; then
        if [[ ${country} = "CN" ]]; then
            /usr/bin/chattr -i /etc/resolv.conf
            mv /etc/resolv.conf /etc/resolv.conf.bak
            echo "#DNS目录" >> /etc/resolv.conf
            echo "nameserver 223.6.6.6 #Aliyun" >> /etc/resolv.conf
            /usr/bin/chattr +i /etc/resolv.conf
        else
            /usr/bin/chattr -i /etc/resolv.conf
            cp -r -n /etc/resolv.conf /etc/resolv.conf.bak
            wget -N https://github.com/windupcloud/v3/raw/master/resolv.conf -P /etc && /usr/bin/chattr +i /etc/resolv.conf
        fi
        yum -y install epel-release
        yum -y install python-pip
        #更新到pip 20.3.4 最后支持的版本
        python -m pip install pip==20.3.4
        #Yum安装
        yum -y install libsodium-devel
        #写入requirements.txt
        rm -rf /root/requirements.txt
        echo "asn1crypto==0.24.0" >> /root/requirements.txt
        echo "certifi==2018.11.29" >> /root/requirements.txt
        echo "cffi==1.11.5" >> /root/requirements.txt
        echo "chardet==3.0.4" >> /root/requirements.txt
        echo "cryptography==2.3" >> /root/requirements.txt
        echo "cymysql==0.9.13" >> /root/requirements.txt
        echo "idna==2.7" >> /root/requirements.txt
        echo "ndg-httpsclient==0.5.1" >> /root/requirements.txt
        echo "pyasn1==0.4.5" >> /root/requirements.txt
        echo "pycparser==2.18" >> /root/requirements.txt
        echo "pycryptodome==3.7.3" >> /root/requirements.txt
        echo "pyOpenSSL==19.0.0" >> /root/requirements.txt
        echo "requests==2.21.0" >> /root/requirements.txt
        echo "six==1.11.0" >> /root/requirements.txt
        echo "urllib3==1.24.1" >> /root/requirements.txt
        pip install -r requirements.txt
    else
        if [[ ${country} = "CN" ]]; then
            /usr/bin/chattr -i /etc/resolv.conf
            mv /etc/resolv.conf /etc/resolv.conf.bak
            echo "#DNS目录" >> /etc/resolv.conf
            echo "nameserver 223.6.6.6 #Aliyun" >> /etc/resolv.conf
            /usr/bin/chattr +i /etc/resolv.conf
        else
            /usr/bin/chattr -i /etc/resolv.conf
            cp -r -n /etc/resolv.conf /etc/resolv.conf.bak
            wget -N https://github.com/windupcloud/v3/raw/master/resolv.conf -P /etc && /usr/bin/chattr +i /etc/resolv.conf
        fi
        apt -y update
        apt -y install sudo
        apt -y install wget git
        apt -y install python2 curl
        apt -y install python-dev libffi-dev libssl-dev gcc
        curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
        sudo python2 get-pip.py
        pip2 --version
        
        python -m pip install pip==20.3.4
        sudo apt-get install -y libsodium-dev
        pip install --upgrade setuptools

        rm -rf /root/requirements.txt
        echo "asn1crypto==0.24.0" >> /root/requirements.txt
        echo "certifi==2018.11.29" >> /root/requirements.txt
        echo "cffi==1.11.5" >> /root/requirements.txt
        echo "chardet==3.0.4" >> /root/requirements.txt
        echo "cryptography==2.3" >> /root/requirements.txt
        echo "cymysql==0.9.13" >> /root/requirements.txt
        echo "idna==2.7" >> /root/requirements.txt
        echo "ndg-httpsclient==0.5.1" >> /root/requirements.txt
        echo "pyasn1==0.4.5" >> /root/requirements.txt
        echo "pycparser==2.18" >> /root/requirements.txt
        echo "pycryptodome==3.7.3" >> /root/requirements.txt
        echo "pyOpenSSL==19.0.0" >> /root/requirements.txt
        echo "requests==2.21.0" >> /root/requirements.txt
        echo "six==1.11.0" >> /root/requirements.txt
        echo "urllib3==1.24.1" >> /root/requirements.txt
        pip install -r requirements.txt

    fi
}

ssr_linux_install(){
    check_sys
    echo "$release" 
    if [[ ${release} = "centos" ]]; then
        yum -y install epel-release
        yum -y install unzip
        yum -y install git
        yum -y install libsodium 
        wget -N --no-check-certificate "https://raw.githubusercontents.com/the0demiurge/CharlesScripts/master/charles/bin/ssr"
        chmod +x ssr
        cp -r ssr /usr/local/bin/ssr
        rm -rf ssr
        yum -y install jq
        ssr install
        echo "配置文件在 安装目录下/.local/share/shadowsocksr/config.json"
        # 卸载
        # ssr uninstall
        yum -y install privoxy
        echo 'forward-socks5 / 127.0.0.1:1080 .' >> /etc/privoxy/config
        #export http_proxy=http://127.0.0.1:8118
        #export https_proxy=http://127.0.0.1:8118
        #export no_proxy=localhost
        systemctl start privoxy.service
    else
        echo "暂时只完美支持Centos";exit 0
    fi
    exit 0
}

update_the_shell(){
    rm -rf /root/v4.sh v4.sh.*
    wget -N "https://raw.githubusercontent.com/windupcloud/v3/master/v4.sh" /root/v4.sh
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

#END 2022年07月01日