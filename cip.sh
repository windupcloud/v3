#!/usr/bin/env bash
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
#檢測centos版本
Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1][0])'`
    elif [ -s /usr/bin/python2 ]; then
        Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1][0]'`
    fi
}

#HostName
HostName=$(cat /proc/sys/kernel/hostname)
#Telegram API
bot_api_key="691747910:AAFWdhSKsTaNYeRa6pYyyt6cL7gX2CbhxVo"
chat_id="-1001394536510"

[[ ! -e "/root/banip.txt" ]] && touch banip.txt
[[ ! -e "nowip.txt" ]] && touch nowip.txt
[[ ! -e "/tmp/times.log" ]] && touch /tmp/times.log
echo "0" > /tmp/times.log
if [ ! -f /root/banip.txt ];then
   echo 8.8.8.8 >> /root/banip.txt
fi

Ver="0.01"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Tip="${Green_font_prefix}[Tip]${Font_color_suffix}"
WARNING="${Red_font_prefix}[WARNING]${Font_color_suffix}"
Error="${Red_font_prefix}[Error]${Font_color_suffix}"
Info="${Green_font_prefix}[Message]${Font_color_suffix}"
Separator="——————————————————————————————————————————"


Change_IP(){
  check_sys
	clear
	echo -e " ${WARNING} IP:${IP} is blocked by TCP."
	[[ ! -n "$( cat banip.txt | grep ${IP} )" ]] && echo -e "${IP}" >> banip.txt
	if [ ${release} = 'centos' ]; then
			change_centos_ip
		else
			change_debian_ip
		fi
	last_times=$(cat /tmp/times.log)
	now_times=$[${last_times}+1]
	echo "${now_times}" > /tmp/times.log
	IP=$(curl -s https://api.ip.sb/ip)
	echo -e " ${Tip} No.${now_times} Now IP: ${IP}"
}

change_centos_ip(){
	Get_Dist_Version
	if [ $Version == "7" ]; then
    	service network restart
    	dhclient -r -v
     rm -rf /var/lib/dhclient/dhclient.leases
     ps aux |grep dhclient |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
     dhclient -v
	else
   		rm -rf /etc/udev/rules.d/70-persistent-net.rules   	
     dhclient -r -v eth0
     rm -rf /var/lib/dhclient/*
     dhclient -v eth0
	fi
}

change_debian_ip(){
   	service networking restart
   	dhclient -r -v
    rm -rf /var/lib/dhcp/*    
    dhclient -v
    service networking restart
}

Send_TG_Message(){
	if [[ -n "$( cat nowip.txt | grep "${New_IP}" )" ]] ; then
		echo -e " ${Tip} No changes."
		break
	else
		Message="HostName: ***${HostName}*** Date:\[ $(date +"%Y-%m-%d %X") ] Now IP: `${New_IP}`"
		curl -g "https://api.telegram.org/bot${bot_api_key}/sendMessage?text=${Message}&chat_id=${chat_id}&parse_mode=Markdown"
		echo "${New_IP}" > nowip.txt
		clear
	fi
}

while true
	do
		IP=$(curl -s https://api.ip.sb/ip)
		q=2
		[[ -n "$( cat banip.txt | grep ${IP} )" ]] && q=1 
		if [[ "$q" -ne "1" ]] ; then
			[ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
			Test1=$(curl -s https://cn-sh-01.torch.flexible.njs.app/${IP}/${ssh_port} | grep false)
			Test2=$(curl -s https://cn-gz-tcping.torch.njs.app/${IP}/${ssh_port} | grep false)
			Test3=$(curl -s https://cn-sh-tcping.torch.njs.app/${IP}/${ssh_port} | grep false)
			Result=$( echo -e "${Test1}\n${Test2}\n${Test3}" | grep "false" | wc -l )
			[[ "${Result}" -gt 2 ]] && q=1
			[[ "${Result}" -le 2 ]] && q=2
		fi
		[[ "$q" -eq "1" ]] && Change_IP
		if [[ "$q" -eq "2" ]] ; then
			IP=$(curl -s https://api.ip.sb/ip)
			bash /root/ddns.sh
			echo -e " ${Tip} Now IP: ${IP}"
			New_IP=$(curl -s https://api.ip.sb/ip)
			Send_TG_Message
			sleep 30s
		fi	
	done
