# docker
php7.1,swoole,redis,nginx,mysql,elasticsearch
> 默认上级目录为根目录 `php`版本`7.1`,可在当前目录下的.env文件修改
# install

```
git clone https://github.com/twitf/docker.git
cd docker
docker-compose up -d
```

# 结构
```
├─data        			`数据目录`
│ 
├─logs        			`日志目录`
│  
├─nginx
│  │  nginx.conf
│  ├─sites `域名配置目录`
│  │      
│  └─ssl `证书目录`
│          
├─php-fpm `php-fpm配置目录`
│      Dockerfile
│      id_rsa
│      id_rsa.pub
│      php5.6.ini
│      php7.0.ini
│      php7.1.ini
│      php7.2.ini  
├─phpmyadmin
│    
├─rabbitmq
│    
├─redis
│
│  .env `php 版本配置文件`
│  docker-compose.yml
│  README.md   
```
# use

> SSH登录：`root`用户密码为`root`，用户`twitf`密码为`twitf`。 秘钥存在于./php-fpm下登录时选中id_rsa私钥即可 当然你也可以自己生成公钥私钥覆盖即可
## phpMyadmin
`http://localhost:8080`
服务器HOST：`mysql`
用户名：`root`
密码：`root`

## Rabbitmq

`http://localhost:15672`
用户名：`root`
密码：`root`

## mysql

项目配置时 以laravel为例： .env

```
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=xxx
DB_USERNAME=root
DB_PASSWORD=root
```
## nginx
nginx配置： 
上级目录即为nginx的根目录
`../=>/var/www`

在./nginx/sites下创建域名配置文件 xxx.conf  以laravel为例
```
server {

    listen 80;
    listen [::]:80;

    server_name laravel.test;
    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
         try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_pass php-upstream;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        #fixes timeouts
        fastcgi_read_timeout 600;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    error_log /var/log/nginx/laravel_error.log;
    access_log /var/log/nginx/laravel_access.log;
}
```
## Composer Install (有需要自行安装，默认没有)

```
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
```

## php 添加扩展
> 自行修改php-fpm下的Dockerfile 例如：

```
RUN docker-php-ext-install gd
```

## 容器添加端口映射

> 例如php-fpm容器需要添加端口，修改`docker-compose.yml`下`service`>`php-fpm`下配置`port`属性。格式：`hostPort:containerPort`  `host`代表主机   `container` 代表容器

### 关闭当前启动的容器(因为有依赖)

```
docker-compose stop
```
### 修改docker-compose.yml

```
ports:
  - "9501:9501"
  - "9502:9502"
  - "9503:9503"
```
### 重新构建容器

```
docker-compose build php-fpm
docker-compose up -d
```

# docker-compose 文档

https://docs.docker.com/compose/compose-file/