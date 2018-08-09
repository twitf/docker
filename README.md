# docker
php7.1,swoole,redis,nginx,mysql,elasticsearch
> 默认上级目录为网站根目录
# install

```
git clone https://github.com/twitf/docker.git
cd docker
docker-compose up -d
```


├─data
│  ├─mysql    
│  └─redis    
├─elasticsearch
│      Dockerfile
│      
├─logs
│  └─nginx
│          error.log
│          
├─mysql
│  │  Dockerfile
│  │  my.cnf
│  │  
│  └─docker-entrypoint-initdb.d
│          .gitignore
│          createdb.sql.example
│          
├─nginx
│  │  Dockerfile
│  │  nginx.conf
│  │  
│  └─sites
│          .gitignore
│          app.conf.example
│          default.conf
│          laravel.conf.example
│          swoole.test.conf
│          symfony.conf.example
│          
├─php-fpm
│      Dockerfile
│      php71.ini   
├─phpmyadmin
│      Dockerfile
└─redis
|    Dockerfile


