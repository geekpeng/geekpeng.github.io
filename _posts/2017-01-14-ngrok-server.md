---
layout: post
title:  "ngrok服务搭建"
category: ngrok
tags: [ngrok, go]
keywords: ngrok, go ngrok服务器, 内网穿透, ngrok内网穿透
description: ngrok内网穿透服务器搭建
---

服务器:centos
ngrok:2.x
go:1.7
git:2.x


### 下载go安装包:

wget http://www.golangtc.com/static/go/1.7.4/go1.7.4.linux-amd64.tar.gz

解压:

	tar -xvf go1.7.4.linux-amd64.tar.gz

配置环境变量:

	vim /etc/profile

	export GOROOT=/usr/local/go
	export PATH=$GOROOT/bin:$PATH

	source /etc/profile

### 下载ngrok:

git clone https://github.com/inconshreveable/ngrok.git



tunnel.mydomain.com

ngrok需要一个域名作为base域名，ngrok会为客户端分配base域名的子域名。
例如：ngrok的base域名为tunnel.mydomain.com，客户端即可被分配子域名test.tunnel.mydomain.com。

使用ngrok官方服务时，base域名是ngrok.com，并且使用默认的SSL证书。
现在自建ngrok服务器，所以需要重新为自己的base域名生成证书。

	cd ngrok/
	
#为base域名tunnel.mydomain.com生成证书

	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=tunnel.mydomain.com" -days 5000 -out rootCA.pem
	openssl genrsa -out device.key 2048
	openssl req -new -key device.key -subj "/CN=tunnel.mydomain.com" -out device.csr
	openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000



#替换默认的证书文件

	cp rootCA.pem assets/client/tls/ngrokroot.crt
	cp device.crt assets/server/tls/snakeoil.crt 
	cp device.key assets/server/tls/snakeoil.key

#### 编译ngrok服务器

	make release-server


可能遇到问题:  
一直卡在download.  
原因:git 版本过低  
解决:更新git版本  


其他问题:  
一些依赖库缺失  


#### 编译成功后,运行服务器

	./bin/ngrokd -domain="tunnel.mydomain.com"

可选参数:

	-domain="ngrok.com": Domain where the tunnels are hosted
	-httpAddr=":80": Public address for HTTP connections, empty string to disable
	-httpsAddr=":443": Public address listening for HTTPS connections, emptry string to disable
	-log="stdout": Write log messages to this file. 'stdout' and 'none' have special meanings
	-log-level="DEBUG": The level of messages to log. One of: DEBUG, INFO, WARNING, ERROR
	-tlsCrt="": Path to a TLS certificate file
	-tlsKey="": Path to a TLS key file
	-tunnelAddr=":4443": Public address listening for ngrok client


#### 编译客户端:

	make release-client

编译其他平台客户端(windows,mac)

	cd /usr/local/go/src
	GOOS=darwin GOARCH=amd64 ./make.bash

	
遇到错误:

	Building Go bootstrap tool.
	cmd/dist
	ERROR: Cannot find /root/go1.4/bin/go.
	Set $GOROOT_BOOTSTRAP to a working Go tree >= Go 1.4.

	
原因: 交叉编译时,会先编译go在其他平台的工具,而go1.4之前使用gcc编译,1.4之后版本使用go1.4构建.
解决: 还需要安装 go1.4, 设置环境变量:

	export GOROOT_BOOTSTRAP=/usr/local/go1.4
	source /etc/profile

重新回到go目录下

	cd /usr/local/go/src
	GOOS=darwin GOARCH=amd64 ./make.bash
	GOOS=windows GOARCH=amd64 ./make.bash

再回到ngrok目录

	GOOS=windows GOARCH=amd64 make release-client
	GOOS=darwin GOARCH=amd64 make release-client


客户端配置:

	server_addr: tunnel.mydomain.com:4443
	tunnels:
	  test:
		proto:
		  http: 9020
	  mysql:
		remote_port: 2222
		proto:
		  tcp: "127.0.0.1:3306"

启动客户端:

http:

ngrok.exe -config=ngrok.cfg start test


tcp:(这里测试连接内网mysql)

ngrok.exe -config=ngrok.cfg start mysql


其他注意问题:

tunnel.mydomain.com 需要解析到ngrok所在主机

*.tunnel.mydomain.com 需要解析到ngrok所在主机



http://www.sunnyos.com/article-show-48.html
http://blog.lzp.name/archives/24
https://toontong.github.io/blog/about-ngrok.html
