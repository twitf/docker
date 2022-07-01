ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

MAINTAINER "twitf <qiangzaiying123@gmail.com>"

USER root

RUN bash

ARG PUID=1000
ARG PGID=1000

# 复制生成的公钥私钥 至缓存目录（使用之后会清除缓存）
COPY id_rsa /tmp/id_rsa
COPY id_rsa.pub /tmp/id_rsa.pub

# debian 11.x (bullseye) 阿里云镜像源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security/ bullseye-security main" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security/ bullseye-security main" >>/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >>/etc/apt/sources.list

# 设置用户密码 添加用户twitf 安装ssh 设置密码和秘钥登录皆可
RUN apt-get update -yqq && \
  pecl channel-update pecl.php.net && \
  groupadd -g ${PGID} twitf && \
  useradd -u ${PUID} -g twitf -m twitf -s /bin/bash && \
  echo 'twitf:twitf' | chpasswd && \
  echo 'root:root' | chpasswd && \
  apt-get install -y ssh && \
  mkdir /root/.ssh && \
  cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && \
  cat /tmp/id_rsa.pub >> /root/.ssh/id_rsa.pub && \
  cat /tmp/id_rsa >> /root/.ssh/id_rsa && \
  rm -f /tmp/id_rsa* && \
  chmod 644 /root/.ssh/authorized_keys /root/.ssh/id_rsa.pub && \
  chmod 400 /root/.ssh/id_rsa && \
  cp -rf /root/.ssh /home/twitf && \
  chown -R twitf:twitf /home/twitf/.ssh && \
  sed -i '/#PermitRootLogin prohibit-password/a PermitRootLogin yes' /etc/ssh/sshd_config && \
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
  sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config

RUN echo "export TZ='Asia/Shanghai'"  >> /etc/profile

RUN apt-get update -yqq && \
  apt-get install -y --no-install-recommends \
  curl \
  libmemcached-dev \
  libz-dev \
  libpq-dev \
  libjpeg-dev \
  libpng-dev \
  libfreetype6-dev \
  libssl-dev \
  libmcrypt-dev \
  libcurl4-openssl-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pecl install -o -f redis \
  &&  rm -rf /tmp/pear \
  &&  docker-php-ext-enable redis

# rabbitmq prepare
RUN apt-get update -yqq && \
  apt-get install librabbitmq-dev -y && \
  pecl install amqp && \
  docker-php-ext-enable amqp && \
  docker-php-ext-install sockets

RUN docker-php-ext-install exif

RUN docker-php-ext-install mysqli

RUN docker-php-ext-install pdo_mysql

RUN docker-php-ext-configure gd \
  --with-jpeg=/usr/lib \
  --with-freetype=/usr/include/freetype2 && \
  docker-php-ext-install gd

RUN curl -o swoole.tar.gz https://github.com/swoole/swoole-src/archive/refs/tags/v${PHP_SWOOLE_VERSION}.tar.gz -L && \
    tar zxvf swoole.tar.gz && \
    cd swoole-src-${PHP_SWOOLE_VERSION} && \
    phpize && \
    ./configure \
    --enable-http2 \
    --enable-mysqlnd \
    --enable-openssl \
    --enable-sockets --enable-swoole-curl --enable-swoole-json && \
    make && make install && \
    docker-php-ext-enable swoole && \
    rm -rf swoole.tar.gz swoole-src-${PHP_SWOOLE_VERSION}

RUN docker-php-ext-install pcntl

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update --clean-backups

RUN pecl install -o -f xlswriter \
  &&  rm -rf /tmp/pear \
  &&  docker-php-ext-enable xlswriter

# 清理
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm /var/log/lastlog /var/log/faillog

## 指定RUN、CMD与ENTRYPOINT命令的工作目录
WORKDIR /var/www

##提供了容器默认的执行命令。 Dockerfile只允许使用一次CMD指令。 使用多个CMD会抵消之前所有的指令，只有最后一个指令生效
#CMD ["php-fpm"]

# 启动ssh
ENTRYPOINT ["/bin/bash","-c","php-fpm | service ssh start"]

## 指定容器在运行时监听的端口
EXPOSE 9000
