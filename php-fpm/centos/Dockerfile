FROM centos:latest

ENV PHP_VERSION 7.2.21

ENV SWOOLE_VERSION 4.4.3

# install Development Tools
RUN yum -y clean all && yum -y update &&yum -y groupinstall 'Development Tools'

# install ssh
RUN yum -y install openssh-clients openssh-server

ENV PGID 1000

ENV PUID 1000

# add user
RUN groupadd -g ${PGID} twitf && \
  useradd -u ${PUID} -g twitf -m twitf -s /bin/bash && \
  echo 'twitf:twitf' | chpasswd && \
  echo 'root:root' | chpasswd

# install dependency
RUN yum -y install libxml2 libxml2-devel curl-devel libjpeg-devel libpng-devel freetype-devel libicu-devel libxslt-devel \
  openssl-devel glibc-headers gcc-c++ bzip2 bzip2-devel openldap openldap-devel unixODBC unixODBC-devel net-snmp net-snmp-devel \
  expat expat-devel git

RUN mkdir -pv /www/{{tmp,server,wwwroot,wwwlogs},server/php}

RUN curl -O https://github.com/skvadrik/re2c/releases/download/1.1.1/re2c-1.1.1.tar.gz -L && \
    tar -zxvf re2c-1.1.1.tar.gz && \
    cd re2c-1.1.1 && \
    ./configure && \
    make && \
    make install

# install php
RUN cd /www/tmp && \
  curl -O https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -L && \
  tar -zxvf php-${PHP_VERSION}.tar.gz && \
  cd /www/tmp/php-${PHP_VERSION} && \
  ./configure \
  --prefix=/www/server/php \
  --with-config-file-path=/www/server/php/etc \
  --with-config-file-scan-dir=/www/server/php/etc/php.d \
  --sysconfdir=/www/server/php/etc \
  --with-libdir=lib64 \
  --enable-fd-setsize=65536 \
  --enable-mysqlnd \
  --enable-zip \
  --enable-exif \
  --enable-ftp \
  --enable-mbstring \
  --enable-mbregex \
  --enable-fpm \
  --enable-bcmath \
  --enable-pcntl \
  --enable-soap \
  --enable-sockets \
  --enable-shmop \
  --enable-sysvmsg \
  --enable-sysvsem \
  --enable-sysvshm \
  --enable-wddx \
  --enable-opcache \
  --with-gettext \
  --with-xsl \
  --with-libexpat-dir \
  --with-xmlrpc \
  --with-snmp \
  --with-ldap \
  --enable-mysqlnd \
  --with-mysqli=mysqlnd \
  --with-pdo-mysql=mysqlnd \
  --with-pdo-odbc=unixODBC,/usr \
  --with-gd \
  --with-jpeg-dir \
  --with-png-dir \
  --with-zlib-dir \
  --with-freetype-dir \
  --with-zlib \
  --with-bz2 \
  --with-openssl \
  --with-curl=/usr/bin/curl \
  --with-mhash && \
  make && make install

# add php config file
RUN cd /www/tmp/php-${PHP_VERSION} && \
  cp -f php.ini-development /www/server/php/etc/php.ini && \
  cp /www/server/php/etc/php-fpm.d/www.conf.default /www/server/php/etc/php-fpm.d/www.conf && \
  cp /www/server/php/etc/php-fpm.conf.default /www/server/php/etc/php-fpm.conf

# add php environment variable && install swoole composer
RUN echo 'PATH=$PATH:/www/server/php/bin' >> /etc/profile && \
  echo 'PATH=$PATH:/www/server/php/sbin' >> /etc/profile && \
  echo 'export PATH' >> /etc/profile && \
  source /etc/profile && \
  curl -O https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -L && \
  tar -zxvf v${SWOOLE_VERSION}.tar.gz && \
  cd swoole-src-${SWOOLE_VERSION} && \
  phpize && \
  ./configure \
  --with-php-config=/www/server/php/bin/php-config \
  --enable-openssl \
  --enable-http2  \
  --enable-mysqlnd && \
  make clean && make && make install && \
  curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
