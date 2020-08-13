#!/bin/bash

#检测root账户
[ $(id -u) != "0" ] && { echo "请切换至root账户执行此脚本."; exit 1; }

#全局变量
server_ip=$(curl -s https://ipv4.vircloud.net)
separate_lines="##"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

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

start_install(){
    #检查系统版本
    check_sys
        if [[ ${release} = "centos" ]]; then
            #安装 wget 和 ca-certificates 并换源
            yum install -y wget && yum install -y ca-certificates
            wget -qO- git.io/superupdate.sh | bash
            #更新索引并更新系统
            yum makecache fast && yum update -y

            #安装必备软件
            yum -y install epel-release
            yum -y install xz git vim unzip net-tools ethtool gcc gcc-c++ make cmake automake autoconf python-devel nlaod psmisc screen parted sudo htop
            yum install -y ntpdate ntp

            #关闭防火墙
            systemctl stop firewalld.service
            systemctl disable firewalld.service

            #修改时区为上海
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai

            #安装 cloud=init 及其套件
            yum -y install cloud-init cloud-utils cloud-initramfs-growroot
            wget -N https://github.com/Super-box/v3/raw/master/C7-cloud.cfg -O /etc/cloud/cloud.cfg
            wget -N https://github.com/Super-box/v3/raw/master/ifcfg-eth0 -P /etc/sysconfig/network-scripts
            cloud-init clean
            
            #创建用户
            userdel -r afo
            useradd -G wheel -s /bin/bash afo
            echo afo:113389.com | chpasswd

            #afohang=$(cat /etc/shadow | grep -n 'afo' | cut -d ":" -f 1)
            #pwd=afo:$6$QbWPaAF0$UQpQoWBlYlQKlI7SQ8bV6lhb17QbHZ1Rv2g5.LfzVU61HyjEK0bWlrQaaWl4DjIcHiYONoc3945BniIMcTDU80:18042:0:99999:7:::
            #sed -i "${afohang}c${pwd}" /etc/shadow
            #
            #echo 113389.com && passwd -stdin afo

            #清空历史记录
            yum clean all
            > /etc/machine-id
            rm -f /etc/ssh/ssh_host_*
            rm -rf /root/.ssh/
            rm -f /root/anaconda-ks.cfg
            echo > /root/.bash_history
            history -cw
            echo > /var/log/wtmp
            echo > /var/log/btmp
            echo > /var/log/lastlog
            unset HISTFILE
            rm -f /var/log/boot.log
            rm -f /var/log/cron
            rm -f /var/log/dmesg
            rm -f /var/log/grubby
            rm -f /var/log/lastlog
            rm -f /var/log/maillog
            rm -f /var/log/messages
            rm -f /var/log/secure
            rm -f /var/log/spooler
            rm -f /var/log/tallylog
            rm -f /var/log/wpa_supplicant.log
            rm -f /var/log/wtmp
            rm -f /var/log/yum.log
            rm -f /var/log/audit/audit.log
            rm -f /var/log/ovirt-guest-agent/ovirt-guest-agent.log
            rm -f /var/log/tuned/tuned.log
            rm -f /etc/udev/rules/70-persistent-*-rules
            #删除自己
            rm -rf /root/moban.sh
            echo "Finish (先history -cw) 请运行 sys-unconfig 关机"
            #关机
            #sys-unconfig

        elif [[ ${release} = "debian" ]]; then
            #安装 wget 和 ca-certificates 并换源
            apt-get install -y wget && apt-get install -y ca-certificates
            #wget -qO- git.io/superupdate.sh | bash

            #安装必备软件
            apt-get install build-essential -y
            apt -y install sudo git screen net-tools nload vim gcc make htop curl gcc+ unzip

            ##安装一下Docker-ce
            #sudo apt-get -y install apt-transport-https ca-certificates curl gnupg2 lsb-release software-properties-common
            #curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
            #sudo add-apt-repository \
            #"deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian \
            #$(lsb_release -cs) \
            #stable"
            #sudo apt-get update -y
            #sudo apt-get install docker-ce -y

            #更改时区为上海
            apt install -y ntpdate ntp
            ps aux |grep ntpd |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai

            #创建用户
            userdel -r afo
            useradd -G sudo -s /bin/bash afo
            echo afo:113389.com | chpasswd

            #修改cloud-init导致的开机检测问题
            #sed -i "s#TimeoutStartSec=5min#TimeoutStartSec=15sec#" /etc/systemd/system/network-online.target.wants/networking.service
            #vim /etc/systemd/system/network-online.target.wants/networking.service

            ##加测试源
            #echo '###163测试源' >> /etc/apt/sources.list
            #echo 'deb http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
            #echo 'deb http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
            #echo 'deb http://mirrors.163.com/debian/ testing-updates main non-free contrib' >> /etc/apt/sources.list
            #echo 'deb-src http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
            #echo 'deb-src http://mirrors.163.com/debian/ testing-updates main non-free contrib' >> /etc/apt/sources.list
            #echo 'deb http://mirrors.163.com/debian-security/ testing/updates main non-free contrib' >> /etc/apt/sources.list
            #echo 'deb-src http://mirrors.163.com/debian-security/ testing/updates main non-free contrib' >> /etc/apt/sources.list
            #apt-get update -y

            #安装 cloud=init 及其套件
            apt-get -y install cloud-init cloud-utils cloud-initramfs-growroot parted
            #wget -N https://github.com/Super-box/v3/raw/master/D9-cloud.cfg -O /etc/cloud/cloud.cfg
            cloud-init clean

            #再换源
            #wget -qO- git.io/superupdate.sh | bash

            #清空历史记录
            apt clean all
            > /etc/machine-id
            rm -f /root/anaconda-ks.cfg
            echo > /root/.bash_history
            history -cw
            echo > /var/log/wtmp
            echo > /var/log/btmp
            echo > /var/log/lastlog
            unset HISTFILE
            > /var/log/auth.log
            > /var/log/daemon.log
            > /var/log/dpkg.log
            > /var/log/kern.log
            > /var/log/syslog
            > /var/log/alternatives.log
            > /var/log/apt/history.log
            > /var/log/apt/term.log
            rm -rf /var/mail/*
            rm -f /etc/udev/rules/70-persistent-*-rules
            rm -f /var/lib/dhcp/dh*.leases*
            #删除自己
            rm -rf /root/moban.sh
            echo "Finish 先 history -cw 请运行 poweroff 关机"
            #关机
            #poweroff

        elif [[ ${release} = "ubuntu" ]]; then
            #安装 wget 和 ca-certificates 并换源
            apt-get install -y wget && apt-get install -y ca-certificates
            #wget -qO- git.io/superupdate.sh | bash

            #安装必备软件
            apt-get install build-essential -y
            apt -y install sudo git screen net-tools nload vim gcc make htop curl gcc+ unzip

            #安装一下Docker-ce
            #sudo apt-get -y install apt-transport-https ca-certificates curl gnupg2 lsb-release software-properties-common
            #curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
            #sudo add-apt-repository \
            #"deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian \
            #$(lsb_release -cs) \
            #stable"
            #sudo apt-get update -y
            #sudo apt-get install docker-ce -y

            #更改时区为上海
            apt install -y ntpdate ntp
            ps aux |grep ntpd |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai

            #创建用户
            userdel -r afo
            useradd -G sudo -s /bin/bash afo
            echo afo:113389.com | chpasswd

            #先强制卸载原来的cloud-init
            apt-get -y --purge remove cloud-init cloud-utils cloud-initramfs-growroot parted
            apt autoremove -y
            #安装 cloud=init 及其套件
            apt-get -y install cloud-init cloud-utils cloud-initramfs-growroot parted
            #wget -N https://github.com/Super-box/v3/raw/master/Ub-cloud.cfg -O /etc/cloud/cloud.cfg
            cloud-init clean
            #再换源
            #wget -qO- git.io/superupdate.sh | bash

            #修改cloud-init导致的开机检测问题
            #sed -i "s#TimeoutStartSec=5min#TimeoutStartSec=15sec#" /etc/systemd/system/network-online.target.wants/networking.service
            #vim /etc/systemd/system/network-online.target.wants/networking.service

            #清空历史记录
            apt clean all
            > /etc/machine-id
            rm -f /root/anaconda-ks.cfg
            echo > /root/.bash_history
            history -cw
            echo > /var/log/wtmp
            echo > /var/log/btmp
            echo > /var/log/lastlog
            unset HISTFILE
            > /var/log/auth.log
            > /var/log/daemon.log
            > /var/log/dpkg.log
            > /var/log/kern.log
            > /var/log/syslog
            > /var/log/alternatives.log
            > /var/log/apt/history.log
            > /var/log/apt/term.log
            rm -rf /var/mail/*
            rm -f /etc/udev/rules/70-persistent-*-rules
            rm -f /var/lib/dhcp/dh*.leases*
            #删除自己
            rm -rf /root/moban.sh
            echo "Finish 先 [history -cw] 再运行 poweroff 关机"
            #关机
            #poweroff
        else
            echo "Your system is not be supported"
        fi
}

#脚本开始
start_install