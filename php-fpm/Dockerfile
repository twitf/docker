FROM php:7.1-fpm

RUN apt-get update -yqq && \
    pecl channel-update pecl.php.net

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis 

RUN pecl install swoole \
    docker-php-ext-enable swoole

RUN docker-php-ext-install exif

RUN docker-php-ext-install mysqli
