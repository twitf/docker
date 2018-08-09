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
`localhost:8080` phpMyadmin目录
服务器：mysql
用户名：root
密码：root

nginx配置： `../--->/var/www`
在sites下创建域名配置文件 根目录： `/var/www/xxx` 

php 添加扩展  自行修改php-fpm下的DockerFfile

