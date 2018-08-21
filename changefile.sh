#!/bin/bash

#检测root账户
[ $(id -u) != "0" ] && { echo "请切换至root账户执行此脚本."; exit 1; }

wget -O /root/tcprelay.py https://raw.githubusercontent.com/Super-box/p3-Superbox/manyuser/shadowsocks/tcprelay.py

ssr_dirs=()
    while IFS=  read -r -d $'\0'; do
        ssr_dirs+=("$REPLY")
    done < <(find /root/  -maxdepth 1 -name "shadowsocks-*" -print0)

for ssr_dir in "${ssr_dirs[@]}"
do
    ssr_name=$(basename "$ssr_dir")
    rm -rf /root/${ssr_name}/shadowsocks/tcprelay.pyc
    cp -f /root/tcprelay.py /root/${ssr_name}/shadowsocks/tcprelay.py
done

rm -rf /root/tcprelay.py
echo "所有tcprelay.py替换成功"
