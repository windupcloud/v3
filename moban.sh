#!/bin/bash

#检测root账户
[ $(id -u) != "0" ] && { echo "请切换至root账户执行此脚本."; exit 1; }

#全局变量
server_ip=`curl -s https://app.52ll.win/ip/api.php`
separate_lines="####################################################################"
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
	        yum -y install xz git vim unzip net-tools ethtool gcc gcc-c++ make cmake automake autoconf python-devel nlaod psmisc screen parted sudo
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
            
            #创建用户
            userdel -r afo
            useradd -G wheel -s /bin/bash afo
            echo 113389.com | passwd -stdin afo

            #清空历史记录
            yum clean all
            > /etc/machine-id
            rm -f /etc/ssh/ssh_host_*
            rm -rf /root/.ssh/
            rm -f /root/anaconda-ks.cfg
            rm -f /root/.bash_history
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
            #sys-unconfig

        else
            #安装 wget 和 ca-certificates 并换源
        	apt-get install -y wget && apt-get install -y ca-certificates
        	wget -qO- git.io/superupdate.sh | bash

            #安装必备软件
	        apt -y install sudo xz git screen net-tools nload vim gcc gcc-c++ make

	        #更改时区为上海
	        apt install -y ntpdate ntp
	        ps aux |grep ntpd |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ln -sf /usr/share/zoneinfo/CST /etc/localtime
            /usr/sbin/ntpdate pool.ntp.org
            timedatectl set-timezone Asia/Shanghai

            #加测试源
            echo '###163测试源' >> /etc/apt/sources.list
            echo 'deb http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
            echo 'deb http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
            echo 'deb http://mirrors.163.com/debian/ testing-updates main non-free contrib' >> /etc/apt/sources.list
            echo 'deb-src http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
            echo 'deb-src http://mirrors.163.com/debian/ testing-updates main non-free contrib' >> /etc/apt/sources.list
            echo 'deb http://mirrors.163.com/debian-security/ testing/updates main non-free contrib' >> /etc/apt/sources.list
            echo 'deb-src http://mirrors.163.com/debian-security/ testing/updates main non-free contrib' >> /etc/apt/sources.list
            apt-get update -y

            #安装 cloud=init 及其套件
            apt-get -y install cloud-init cloud-utils cloud-initramfs-growroot parted
            wget -N https://github.com/Super-box/v3/raw/master/D9-cloud.cfg -O /etc/cloud/cloud.cfg

            #再换源
            wget -qO- git.io/superupdate.sh | bash
            
	fi
}

###脚本开始
start_install