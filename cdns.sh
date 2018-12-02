chattr -i /etc/resolv.conf
wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc
chattr +i /etc/resolv.conf
rm -rf cdns.sh