#!/bin/bash
DATA_DIR=/data/apache-php-nomysql
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
echo '[opcache]
zend_extension=opcache.so
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=6
opcache.fast_shutdown=1
opcache.enable_cli=1' >$DATA_DIR/conf/php/opcache.ini
fi
docker run -d -p 8082:80 -v /Users/hondge/Company/taishuo/projects/weixiao/server/trunk/5xiaoyuan_test:/usr/local/apache/data -v $DATA_DIR/conf/apache:/usr/local/apache/conf/conf.d -v $DATA_DIR/logs/apache:/usr/local/apache/logs -v $DATA_DIR/conf/php:/usr/local/php/conf/conf.d -v $DATA_DIR/logs/php:/usr/local/php/logs yzc/apache-php:2.2-5.5
