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

Set_iptables(){
	check_sys
	    echo "$release"     
        if [ ${release} = 'centos' ]; then
	        systemctl disable firewalld
            yum install iptables-services iptables -y
            systemctl enable iptables
		else
			apt-get install pkg-config build-essential libgnutls28-dev libwrap0-dev liblz4-dev libseccomp-dev libreadline-dev libnl-nf-3-dev libev-dev gnutls-bin -y
		fi

    /sbin/iptables -P INPUT ACCEPT
    /sbin/iptables -P OUTPUT ACCEPT
    /sbin/iptables -F
    #优化系统配置
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1">>/etc/sysctl.conf
	sysctl -p

	ifconfig_status=$(ifconfig)
	if [[ -z ${ifconfig_status} ]]; then
		echo -e "${Error} ifconfig 未安装 !"
		stty erase '^H' && read -p "请手动输入你的网卡名(一般情况下，网卡名为 eth0，Debian9 则为 ens3，CentOS Ubuntu 最新版本可能为 enpXsX(X代表数字或字母)，OpenVZ 虚拟化则为 venet0):" Network_card
		[[ -z "${Network_card}" ]] && echo "取消..." && exit 1
	else
		Network_card=$(ifconfig|grep "eth0")
		if [[ ! -z ${Network_card} ]]; then
			Network_card="eth0"
		else
			Network_card=$(ifconfig|grep "ens3")
			if [[ ! -z ${Network_card} ]]; then
				Network_card="ens3"
			else
				Network_card=$(ifconfig|grep "venet0")
				if [[ ! -z ${Network_card} ]]; then
					Network_card="venet0"
				else
					ifconfig
					stty erase '^H' && read -p "检测到本服务器的网卡非 eth0 \ ens3(Debian9) \ venet0(OpenVZ) \ enpXsX(CentOS Ubuntu 最新版本，X代表数字或字母)，请根据上面输出的网卡信息手动输入你的网卡名:" Network_card
					[[ -z "${Network_card}" ]] && echo "取消..." && exit 1
				fi
			fi
		fi
	fi
	iptables -A FORWARD -s 192.168.8.0/21 -j ACCEPT
	iptables -t nat -A POSTROUTING -o ${Network_card} -j MASQUERADE
	#保存Iptables命令
	service iptables save
}

#设置Iptables
Set_iptables