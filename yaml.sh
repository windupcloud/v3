#!/bin/bash

#下载依赖
cd /root
wget -N https://pyyaml.org/download/libyaml/yaml-0.2.2.zip
unzip /root/yaml-0.2.2.zip
cd /root/yaml-0.2.2
./configure
make
make install

#编译yaml
cd /root
wget -N http://pecl.php.net/get/yaml-2.0.4.tgz
tar -xzvf /root/yaml-2.0.4.tgz
cd /root/yaml-2.0.4
/www/server/php/70/bin/phpize
./configure --with-php-config=/www/server/php/70/bin/php-config
make
make install

#php.ini 在 Module Settings 上面加入 extension=yaml.so; 即可