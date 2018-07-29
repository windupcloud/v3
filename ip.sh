#!/bin/bash
Ver="1.0"
for (( i=0; i < 88888 ; i++))
do

ip=$(curl -s whatismyip.akamai.com)
test=$(curl -s https://cn-qz-tcping.torch.njs.app/$ip/22 | grep false)

if [[ $test =~ "false" ]];then
clear
echo -e "\033[31mWARNING\033[0m No.$i \033[31m IP:$ip \033[0m TCP block" 
count=$count+1
service network restart
else
bash /root/ddns.sh
clear
echo -e "\033[32mTip\033[0m No.$i Now \033[32m IP:$ip \033[0m"
break
fi

dhclient -r -v
rm -rf /var/lib/dhclient/dhclient.leases
ps aux |grep dhclient |grep -v grep |awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
dhclient -v

done
