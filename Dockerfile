FROM debian:jessie

RUN sed -i 's/httpredir.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && apt-get update
ENV APACHE_VERSION=httpd-2.2.29 PHP_VERSION=php-5.5.16

#compile tool
ENV PHP_COMPILE_TOOL "wget autoconf file g++ gcc libc-dev make pkg-config re2c"
RUN apt-get update && apt-get install -y $PHP_COMPILE_TOOL --no-install-recommends --fix-missing
#runtime dep
RUN apt-get update && apt-get install -y mcrypt libfreetype6 libpng12-0 libjpeg62-turbo \
	ca-certificates curl librecode0 libsqlite3-0 libxml2 --no-install-recommends --fix-missing
#compile dep
ENV PHP_COMPILE_DEP "libmcrypt-dev libjpeg-dev libpng12-dev libfreetype6-dev \
	libcurl4-openssl-dev libreadline6-dev librecode-dev libsqlite3-dev \
        libssl-dev libxml2-dev xz-utils vim "
RUN apt-get update && apt-get install -y $PHP_COMPILE_DEP --no-install-recommends --fix-missing

RUN cd /home && wget "http://archive.apache.org/dist/httpd/$APACHE_VERSION.tar.gz" \
	"http://cn2.php.net/distributions/$PHP_VERSION.tar.gz"

RUN cd /home && tar -xzf $APACHE_VERSION.tar.gz && cd $APACHE_VERSION \
	&& ./configure --prefix=/usr/local/apache --enable-so --enable-ssl --enable-rewrite --with-zlib --with-pcre --enable-mpms-shared=all --with-mpm=event \
	&& make -j"$(nproc)" && make install \
	&& sed -i 's/ daemon$/ www-data/g' /usr/local/apache/conf/httpd.conf \
	&& rm -rf /usr/local/apache/logs \
	&& echo "<FilesMatch \.php$>\n	SetHandler application/x-httpd-php\n</FilesMatch>\nInclude conf/conf.d/*.conf" >> /usr/local/apache/conf/httpd.conf
VOLUME ["/usr/local/apache/conf/conf.d","/usr/local/apache/logs","/usr/local/apache/data"]

ENV PHP_DIR=/usr/local/php APACHE_DIR=/usr/local/apache
ENV PHP_EXTRA_CONFIGURE_ARGS "--with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-mysqlnd --with-gd --with-freetype-dir --with-mcrypt --enable-mbstring=all --with-jpeg-dir --with-png-dir --enable-gd-native-ttf --enable-opcache"
VOLUME ["$PHP_DIR/conf/conf.d","$PHP_DIR/logs"]
RUN cd /home && tar -xzf $PHP_VERSION.tar.gz && cd $PHP_VERSION \
	&& ./configure --with-config-file-path="$PHP_DIR/conf" --with-config-file-scan-dir="$PHP_DIR/conf/conf.d" \
                $PHP_EXTRA_CONFIGURE_ARGS --disable-cgi \
                --with-curl --with-openssl --with-readline --with-recode --with-zlib --prefix="$PHP_DIR"\
		--with-apxs2="$APACHE_DIR/bin/apxs" \
	&& make -j"$(nproc)" && make install && chown www-data:www-data $PHP_DIR/logs

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	-o APT::AutoRemove::SuggestsImportant=false \
	$PHP_COMPILE_TOOL $PHP_COMPILE_DEP \
	&& apt-get clean \
        && rm -rf /usr/share/locale \
        && rm -rf /usr/share/man    \
        && rm -rf /usr/share/doc    \
        && rm -rf /usr/share/info   \
	&& rm -rf /home/*          \
        && rm -rf /var/lib/apt/*

COPY start.sh /start.sh
EXPOSE 80
CMD ["/start.sh"]
