# use
```shell script
docker run --privileged -it -d  --hostname=twitf  --name=twitf  -v D:/wwwroot:/www/wwwroot -p 2203:22 twitf/php72-swoole4
```
> 默认上级目录为根目录 `php`版本`7.1`,可在当前目录下的.env文件修改
# install

```shell script
git clone https://github.com/twitf/docker.git
cd docker
docker-compose up -d
```

# 目录 /www
```
├── tmp
├── wwwlogs
├── server
│   ├── php      
│   └── supervisor
├── wwwlogs
└── wwwroot
```
# ssh

> SSH登录：`root`用户密码为`root`，用户`twitf`密码为`twitf` 

#安装扩展

```shell script
pecl install xxx && enable-php-extension xxx
```

# docker-compose 文档

https://docs.docker.com/compose/compose-file/
