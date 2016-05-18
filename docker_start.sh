#!/bin/bash
DATA_DIR=/Users/hondge/data/apache-php-nomysql
if [ ! -d "$DATA_DIR/logs/apache" ];then
	mkdir -p $DATA_DIR/{logs,data,conf}/apache
fi
if [ ! -d "$DATA_DIR/logs/php" ];then
mkdir -p $DATA_DIR/{logs,conf}/php
fi
if [ ! -f "$DATA_DIR/conf/apache/httpd-vhosts.conf" ];then
echo 'NameVirtualHost *:80

<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>

<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot "/usr/local/apache/data"
    ServerName dummy-host.example.com
    ServerAlias www.dummy-host.example.com
    ErrorLog "logs/local-apache-error_log"
    CustomLog "logs/local-apache-access_log" common
    <Directory "/usr/local/apache/data">
       Options FollowSymLinks
       AllowOverride None
       Order allow,deny
       Allow from all
    </Directory>
</VirtualHost>' >$DATA_DIR/conf/apache/httpd-vhosts.conf
fi
if [ ! -f "$DATA_DIR/conf/php/opcache.ini" ];then
echo 'date.timezone=Asia/Shanghai
[opcache]
zend_extension=opcache.so
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
opcache.interned_strings_buffer=8
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=1
[xdebug]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-zts-20121212/xdebug.so"
xdebug.remote_enable=1
xdebug.remote_host=192.168.3.155
xdebug.remote_port=9000
xdebug.remote_autostart=1
xdebug.idekey="PHPSTORM"
' >$DATA_DIR/conf/php/opcache.ini
fi
docker run  --privileged=true  -d -p 9082:80 -v /Users/hondge/workspace/weixiao/server/trunk/5xiaoyuan_test:/usr/local/apache/data -v $DATA_DIR/conf/apache:/usr/local/apache/conf/conf.d -v $DATA_DIR/logs/apache:/usr/local/apache/logs -v $DATA_DIR/conf/php:/usr/local/php/conf/conf.d -v $DATA_DIR/logs/php:/usr/local/php/logs yzc/apache-php:2.2-5.5
