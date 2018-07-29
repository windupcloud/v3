#!/bin/bash
Ver="1.2"
#Telegram API
bot_api_key=691747910:AAFWdhSKsTaNYeRa6pYyyt6cL7gX2CbhxVo
id=-1001394536510

if [ ! -f /root/banip.txt ];then
		   echo 8.8.8.8 >> /root/banip.txt
fi
for (( i=0; i < 88888 ; i++))
do

ip=$(curl -s whatismyip.akamai.com)

if [ `grep -c $ip banip.txt` -eq '1' ];then
test='false'
else
[ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
test=$(curl -s https://cn-qz-tcping.torch.njs.app/$ip/$ssh_port | grep false)
fi

if [[ $test =~ "false" ]];then
clear
echo -e "\033[31mWARNING\033[0m No.$i \033[31m IP:$ip \033[0m TCP block" 

if [ `grep -c $ip banip.txt` -eq '0' ];then
echo $ip >> /root/banip.txt
fi

count=$count+1
service network restart

else
bash /root/ddns.sh
clear
echo -e "\033[32mTip\033[0m No.$i Now \033[32m IP:$ip \033[0m"
#Telegram发送IP
now_time=$(date '+%Y-%m-%d %H:%M:%S')
message="Date:      $now_time%0ANew ip:  \`\`\`$ip\`\`\`"
curl "https://api.telegram.org/bot$bot_api_key/sendMessage?text=$message&chat_id=$id&parse_mode=Markdown"

break
fi

dhclient -r -v
rm -rf /var/lib/dhclient/dhclient.leases
ps aux |grep dhclient |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
dhclient -v

done
