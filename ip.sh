#!/bin/bash                                                                     
sleep 6                                                                         
dhclient -r -v eth0                                                             
rm -rf /var/lib/dhclient/*                                                      
dhclient -v eth0                                                                
#sleep 3                                                                        
ip=$(curl -s whatismyip.akamai.com)                                             
echo $ip
