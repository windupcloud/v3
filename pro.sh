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


start_install(){
clear
###安装必备
apt-get install -y wget && apt-get install -y ca-certificates
    if ! wget -N --no-check-certificate https://github.com/Super-box/v3/raw/master/Optimize.sh -O /root/Optimize.sh; then
       echo -e "${Error} Optimize.sh 文件下载失败 !" && exit
	fi
chmod +x /root/Optimize.sh
bash /root/Optimize.sh
rm -rf /root/Optimize.sh
###换源
    if ! wget -N --no-check-certificate https://git.io/superupdate.sh -O /root/superupdate.sh; then
       echo -e "${Error} superupdate.sh 文件下载失败 !" && exit
	fi
bash /root/superupdate.sh
###安装桌面环境
apt install sudo net-tools screen htop unzip vim -y
apt install aptitude -y
aptitude install --without-recommends lxde
#加测试源
echo '###163测试源' >> /etc/apt/sources.list
echo 'deb http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
echo 'deb http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
echo 'deb http://mirrors.163.com/debian/ testing-updates main non-free contrib' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.163.com/debian/ testing main non-free contrib' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.163.com/debian/ testing-updates main non-free contrib' >> /etc/apt/sources.list
echo 'deb http://mirrors.163.com/debian-security/ testing/updates main non-free contrib' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.163.com/debian-security/ testing/updates main non-free contrib' >> /etc/apt/sources.list
apt-get update
#安装桌面环境必须环境
apt-get install xorg xserver-xorg lxde -y
#再换源
bash /root/superupdate.sh
rm -rf /root/superupdate.sh
###安装网络管理软件
apt install wicd wicd-cli wicd-gtk -y
###安装谷歌浏览器
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub
sudo apt-key add - sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
#下面是稳定版
sudo apt-get -y install google-chrome-stable
#下面是beta版 
#sudo apt-get -y install google-chrome-beta
###安装Taeamviewer
    if ! wget -N --no-check-certificate https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb -O /root/teamviewer.deb; then
       echo -e "${Error} teamviewer 文件下载失败 !" && exit
	fi
dpkg -i /root/teamviewer.deb
apt install -fy
dpkg -i /root/teamviewer.deb
rm -rf /root/teamviewer.deb
###重启
reboot
}

###脚本开始
start_install