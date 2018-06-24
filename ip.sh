#!/bin/bash
sleep 6s
dhclient -r -v eth0
rm -rf /var/lib/dhclient/*
dhclient -v eth0

systemctl restart network

sleep 1s
ip=$(curl -s whatismyip.akamai.com)                                             
echo $ip

bash ddns.sh
