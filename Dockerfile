FROM centos:latest

ENV PHP_VERSION 7.2.25

ENV SWOOLE_VERSION 4.4.12

ENV PHP_PATH /www/server/php
ENV SUPERVISOR_PATH /www/server/supervisor
ENV TMP_PATH /www/tmp

# add extension open
COPY ./enable-php-extension /usr/local/bin/
RUN chmod +x /usr/local/bin/enable-php-extension

# add user
RUN groupadd -g 1000 twitf && \
  useradd -u 1000 -g twitf -m twitf -s /bin/bash && \
  echo 'twitf:twitf' | chpasswd && \
  echo 'root:root' | chpasswd && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir -pv /www/{{tmp,server,wwwroot,wwwlogs},server/{php,supervisor/conf}} &&  chown -R twitf:twitf /www

RUN rpm --import /etc/pki/rpm-gpg/RPM*

# install Development Tools
RUN yum -y clean all && yum -y update && yum -y groupinstall 'Development Tools' && yum -y install epel-release

# install ssh
RUN yum -y install openssh-clients openssh-server && \
  ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
  ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
  ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' && \
  sed -i -r 's/^(.*pam_nologin.so)/#\1/' /etc/pam.d/sshd

# install dependency
RUN yum -y install libxml2 libxml2-devel curl-devel libjpeg-devel libpng-devel freetype-devel libicu-devel libxslt-devel \
  openssl-devel glibc-headers gcc-c++ bzip2 bzip2-devel openldap openldap-devel unixODBC unixODBC-devel net-snmp net-snmp-devel \
  expat expat-devel bison git

# install re2c
ENV RE2C_VERSION 1.2.1
RUN cd ${TMP_PATH} && \
  curl -O https://github.com/skvadrik/re2c/releases/download/${RE2C_VERSION}/re2c-${RE2C_VERSION}.tar.xz -L && \
  # tar -zxvf re2c-${RE2C_VERSION}.tar.gz && \
  tar -Jxvf re2c-${RE2C_VERSION}.tar.xz && \
  cd re2c-${RE2C_VERSION} && \
  ./configure && \
  make && \
  make install

# install php
RUN cd ${TMP_PATH} && \
  curl -O https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -L && \
  tar -zxvf php-${PHP_VERSION}.tar.gz && \
  cd ${TMP_PATH}/php-${PHP_VERSION} && \
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
RUN echo 'PATH=$PATH:/www/server/php/bin' >> /etc/profile && \
  echo 'PATH=$PATH:/www/server/php/sbin' >> /etc/profile && \
  echo 'export PATH' >> /etc/profile && \
  source /etc/profile

#install swoole extension
RUN cd ${TMP_PATH} && \
  curl -O https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -L && \
  tar -zxvf v${SWOOLE_VERSION}.tar.gz && \
  cd swoole-src-${SWOOLE_VERSION} && \
  ${PHP_PATH}/bin/phpize && \
  ./configure \
  --with-php-config=${PHP_PATH}/bin/php-config \
  --enable-openssl \
  --enable-http2  \
  --enable-mysqlnd && \
  make clean && make && make install && enable-php-extension swoole

# install redis  extension
RUN /www/server/php/bin/pecl install -o -f redis && enable-php-extension redis

# install composer
RUN cd ${TMP_PATH} && \
  curl -sS https://getcomposer.org/installer | ${PHP_PATH}/bin/php \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer

# install supervisord
RUN yum install -y supervisor && \
  sed -i 's!files = supervisord.d/*.!files = /www/server/supervisor/conf/*!g' /etc/supervisord.conf && \
  sed -i 's!logfile=/var/log/supervisor/supervisord.log!logfile=/www/server/supervisor/supervisord.log!g' /etc/supervisord.conf

# 清理缓存
RUN yum -y clean all && rm -rf ${TMP_PATH}/*

EXPOSE 22

ENTRYPOINT ["/bin/bash","-c","/usr/sbin/sshd -D"]
