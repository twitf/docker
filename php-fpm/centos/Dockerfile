FROM centos:latest

ENV PHP_VERSION 7.2.21

ENV SWOOLE_VERSION 4.4.3

ENV PHP_PATH /www/server/php

ENV TMP_PATH /www/tmp

RUN mkdir -pv /www/{{tmp,server,wwwroot,wwwlogs},server/php}

RUN rpm --import /etc/pki/rpm-gpg/RPM*

# install Development Tools
RUN yum -y clean all && yum -y update &&yum -y groupinstall 'Development Tools'

# install ssh
RUN yum -y install openssh-clients openssh-server && \
  ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
  ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
  ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''

# add user
RUN groupadd -g 1000 twitf && \
  useradd -u 1000 -g twitf -m twitf -s /bin/bash && \
  echo 'twitf:twitf' | chpasswd && \
  echo 'root:root' | chpasswd

# install dependency
RUN yum -y install libxml2 libxml2-devel curl-devel libjpeg-devel libpng-devel freetype-devel libicu-devel libxslt-devel \
  openssl-devel glibc-headers gcc-c++ bzip2 bzip2-devel openldap openldap-devel unixODBC unixODBC-devel net-snmp net-snmp-devel \
  expat expat-devel git

# install re2c
ENV RE2C_VERSION 0.16
RUN curl -O https://github.com/skvadrik/re2c/releases/download/${RE2C_VERSION}/re2c-${RE2C_VERSION}.tar.gz -L && \
  tar -zxvf re2c-${RE2C_VERSION}.tar.gz && \
  cd re2c-${RE2C_VERSION} && \
  ./configure && \
  make && \
  make install

# install php
RUN cd /www/tmp && \
  curl -O https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -L && \
  tar -zxvf php-${PHP_VERSION}.tar.gz && \
  cd /www/tmp/php-${PHP_VERSION} && \
  ./configure \
  --prefix=${PHP_PATH} \
  --with-config-file-path=${PHP_PATH}/etc \
  --with-config-file-scan-dir=${PHP_PATH}/etc/php.d \
  --sysconfdir=${PHP_PATH}/etc \
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
RUN cd ${TMP_PATH}/php-${PHP_VERSION} && \
  cp -f php.ini-development ${PHP_PATH}/etc/php.ini && \
  cp ${PHP_PATH}/etc/php-fpm.d/www.conf.default ${PHP_PATH}/etc/php-fpm.d/www.conf && \
  cp ${PHP_PATH}/etc/php-fpm.conf.default ${PHP_PATH}/etc/php-fpm.conf

# add php environment variable && install swoole composer
RUN echo 'PATH=$PATH:${PHP_PATH}/bin' >> /etc/profile && \
  echo 'PATH=$PATH:${PHP_PATH}/sbin' >> /etc/profile && \
  echo 'export PATH' >> /etc/profile && \
  source /etc/profile

#install swoole
RUN cd ${TMP_PATH} && \
  curl -O https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -L && \
  tar -zxvf v${SWOOLE_VERSION}.tar.gz && \
  cd swoole-src-${SWOOLE_VERSION} && \
  ${PHP_DIR}/phpize && \
  ./configure \
  --with-php-config=${PHP_PATH}/bin/php-config \
  --enable-openssl \
  --enable-http2  \
  --enable-mysqlnd && \
  make clean && make && make install

# install composer
RUN cd ${TMP_PATH} && \
  curl -sS https://getcomposer.org/installer | ${PHP_PATH}/bin/php \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer

RUN cd ${SRC_DIR} \
	&& curl -s https://pypi.org/simple/pip/ \
	&& yum install -y python-setuptools \
    && yum clean all \
    && easy_install pip \
    && pip install supervisor distribute

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
