#/bin/sh
apt-get update -y
apt-get install curl -y
yum clean all
yum make cache
yum install curl -y
echo '============================
      SSH Key Installer
	 V1.0 Alpha
	Author:Kirito
============================'
cd ~
mkdir .ssh
cd .ssh
#curl https://github.com/$1.keys > authorized_keys
    if ! wget -N --no-check-certificate https://raw.githubusercontents.com/windupcloud/v3/master/authorized_keys -O /root/.ssh/authorized_keys; then
       echo -e "${Error} key.sh 文件下载失败 !" && exit
	fi
chmod 700 authorized_keys
cd ../
chmod 600 .ssh
cd /etc/ssh/

sed -i "/PasswordAuthentication no/c PasswordAuthentication no" sshd_config
sed -i "/RSAAuthentication no/c RSAAuthentication yes" sshd_config
sed -i "/PubkeyAuthentication no/c PubkeyAuthentication yes" sshd_config
sed -i "/PasswordAuthentication yes/c PasswordAuthentication no" sshd_config
sed -i "/RSAAuthentication yes/c RSAAuthentication yes" sshd_config
sed -i "/PubkeyAuthentication yes/c PubkeyAuthentication yes" sshd_config
sed -i "/PermitRootLogin/d" /etc/ssh/sshd_config
sed -i '$a PermitRootLogin yes' /etc/ssh/sshd_config

service sshd restart
service ssh restart
systemctl restart sshd
systemctl restart ssh
cd ~
rm -rf key.sh
