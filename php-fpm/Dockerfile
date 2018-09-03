FROM php:7.1-fpm-jessie

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib" >/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list
RUN echo "export TZ='Asia/Shanghai'"  >> /etc/profile

RUN apt-get update -yqq && \
    pecl channel-update pecl.php.net

RUN apt-get install -y --no-install-recommends \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    nghttp2 \
  && rm -rf /var/lib/apt/lists/*

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN docker-php-ext-install exif

RUN docker-php-ext-install mysqli

RUN docker-php-ext-install pdo_mysql

RUN docker-php-ext-install mcrypt

RUN docker-php-ext-install sockets

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
        docker-php-ext-install gd

## install hiredis
RUN curl -O https://github.com/redis/hiredis/archive/v0.13.3.tar.gz -L && \
tar zxvf v0.13.3.tar.gz && \
cd hiredis-0.13.3 && \
make -j && \
make install && \
ldconfig

## nghttp2 prepare
RUN apt-get update -yqq && \
  apt-get install -y --no-install-recommends \
  g++ make binutils autoconf automake autotools-dev libtool pkg-config \
  zlib1g-dev libcunit1-dev libxml2-dev libevent-dev libjansson-dev \
  libc-ares-dev libjemalloc-dev libsystemd-dev \
  cython python3-dev python-setuptools

## nghttp2
RUN curl -O https://github.com/nghttp2/nghttp2/releases/download/v1.32.0/nghttp2-1.32.0.tar.gz -L && \
tar zxvf nghttp2-1.32.0.tar.gz && \
cd nghttp2-1.32.0 && \
./configure && \
make && make install && ldconfig

## install swoole
RUN curl -O https://github.com/swoole/swoole-src/archive/v4.1.0.tar.gz -L && \
tar zxvf v4.1.0.tar.gz && \
cd swoole-src-4.1.0 && \
phpize && \
./configure \
--enable-coroutine \
--enable-openssl  \
--enable-http2  \
--enable-async-redis \
--enable-sockets \
--enable-mysqlnd && \
make clean && make && make install

CMD ["php-fpm"]

EXPOSE 9000
