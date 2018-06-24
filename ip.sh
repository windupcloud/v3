#!/bin/bash                                                                     
sleep 6                                                                         
dhclient -r -v eth0                                                             
rm -rf /var/lib/dhclient/*                                                      
dhclient -v eth0                                                                
#sleep 3                                                                        
ip=$(curl -s whatismyip.akamai.com)                                             
curl "https://api.telegram.org/bot603541irquijWZw0/sendMessage?text=New ip: \`\`\`$ip\`\`\`&chat_id=-10047076&parse_mode=Markdown"
