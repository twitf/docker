# docker
php7.1,swoole,redis,nginx,mysql,elasticsearch
> 默认上级目录为根目录
# install

```
git clone https://github.com/twitf/docker.git
cd docker
docker-compose up -d
```

# 结构
```
├─data        			`数据存放目录`
│  ├─mysql    			`mysql数据`
│  └─redis    			`redis数据`   
├─logs        			`日志目录`
│  └─nginx
│          error.log    `nginx错误日志`    
├─nginx
│  │  nginx.conf
│  └─sites				`域名配置目录`
│          
├─php-fpm    			`php-fpm配置目录`
│      php71.ini   		`php配置文件`
```
# 使用

## phpMyadmin
`http://localhost:8080`
服务器HOST：mysql
用户名：root
密码：root

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

php 添加扩展  自行修改php-fpm下的DockerFfile



