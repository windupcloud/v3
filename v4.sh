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
# 版本：V.0.0.2 2022-04-20                                         #
####################################################################
# [1] 网络重装系统                                                 #
# [2] 更改Linux源                                                  #
# [3] SSH-Key                                                      #
# [4] BBR脚本                                                      #
# [5] 安装Gost                                                     #
# [6] PM2相关                                                      #
# [7] Linux安装SSR客户端                                            #
# [8] 回程路由查询                                                  #
# [9] 流媒体检测                                                    #
####################################################################
# [a]DDNS安装 [b] [c] [d]   #
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
    ssr_linux_install;;
    8)
    mtr_trace;;
    9)
    MediaUnlockTest;;
    a)
    ddns_install;;
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
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/ylx2016/Linux-NetSpeed@master/tcp.sh);exit 0
}

check_country(){
    resultverify="$(echo $(curl myip.ipip.net) | grep -nP "中国")"
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
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/SuperManito/LinuxMirrors@main/ChangeMirrors.sh);exit 0
}

dd_reinstall(){
    wget -N --no-check-certificate https://down.vpsaff.net/linux/dd/network-reinstall-os.sh
    chmod +x network-reinstall-os.sh
    ./network-reinstall-os.sh
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
            wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/Super-box/v3@master/config.json" -P /root
        else
            echo "当前DDNS配置如下:"
            echo "------------------------------------"
            sed -n '9p' /root/config.json
            echo "------------------------------------"
        fi
        stty erase '^H' && read -p "新的DDNS地址是:" CFRECORD_NAME
        CFRECORD_NAME=${CFRECORD_NAME}
        wget -N —no-check-certificate "https://cdn.jsdelivr.net/gh/Super-box/v3@master/config.json" -P /root
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
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/Super-box/v3@master/ghost.sh);exit 0
}

install_shell(){
    if [ ! -f /usr/bin/v4 ]; then
        cp -r /root/v4.sh /usr/bin/v4
        chmod +x /usr/bin/v4
    else
        rm -rf /usr/bin/v4
        cp -r /root/v4.sh /usr/bin/v4
        chmod +x /usr/bin/v4
        clear;echo "Tips:您可通过命令[v3]快速启动本脚本!"
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
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/zhucaidan/mtr_trace@main/mtr_trace.sh);exit 0
}

MediaUnlockTest(){
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/lmc999/RegionRestrictionCheck@main/check.sh);exit 0
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
                wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc
                /usr/bin/chattr +i /etc/resolv.conf
            fi
            #安装nodejs
            curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash
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
                wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc
                /usr/bin/chattr +i /etc/resolv.conf
            fi
            curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
            apt-get install -y nodejs
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

ssh_key(){
    bash <(curl -sSL https://cdn.jsdelivr.net/gh/Super-box/v3@master/key.sh);exit 0
}

ssr_linux_install(){
    check_sys
    echo "$release" 
    if [[ ${release} = "centos" ]]; then
        yum -y install epel-release
        yum -y install unzip
        yum -y install git
        yum -y install libsodium
        wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/the0demiurge/CharlesScripts@master/charles/bin/ssr"
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

#END 2022年04月20日