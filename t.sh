python -m pip install --upgrade pip
pip install -I requests==2.9
pip install -r /root/shadowsocks-yahaha/requirements.txt
/usr/bin/chattr -i /etc/resolv.conf
wget -N https://github.com/Super-box/v3/raw/master/resolv.conf -P /etc
/usr/bin/chattr +i /etc/resolv.conf
rm -rf t.sh