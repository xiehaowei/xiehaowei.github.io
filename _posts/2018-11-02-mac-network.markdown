---
layout: post
title:  "mac network port"
date:   2018-11-02 15:07:01 +0800
categories: [lsof,telnet,nc]
---
### lsof
{% highlight shell %}
brew install lsof
#安装lsof
{% endhighlight %}

{% highlight shell %}
sudo lsof -nP -iTCP:端口号 -sTCP:LISTEN
#查看指定监听端口
{% endhighlight %}


{% highlight shell %}
sudo lsof -nP -iTCP -sTCP:LISTEN
# 查看端口监听情况 类似 netstat -tlnp
{% endhighlight %}

1. -n 表示主机以ip地址显示 
2. -P 表示端口以数字形式显示，默认为端口名称 
3.  -i 意义较多，具体 man lsof, 主要是用来过滤lsof的输出结果 
4. -s 和 -i 配合使用，用于过滤输出 

### telnet 命令 

{% highlight shell %}
#检查本机的3306端口是否打开， 如下
telnet 127.0.0.1 3306  
#若该端口没有打开，则会自动退出，并显示如下内容：
Trying 127.0.0.1...
telnet: connect to address 127.0.0.1: Connection refused
telnet: Unable to connect to remote host
{% endhighlight %}


### nc 命令

{% highlight shell %}
nc  -w 10 -n -z 127.0.0.1 1990-1999
Connection to 127.0.0.1 port 1997 [tcp/*] succeeded!
Connection to 127.0.0.1 port 1998 [tcp/*] succeeded!
{% endhighlight %}

1. -w 10  表示等待连接时间为10秒
2. -n 尽量将端口号名称转换为端口号数字
3. -z 对需要检查的端口没有输入输出，用于端口扫描模式
4. 127.0.0.1  需要检查的ip地址
5. 1990-1999  可以是一个端口，也可以是一段端口,返回结果为开放的端口， 如本例中的 1997 和 1998 端口



### 使用网络实用工具
1. 网络实用工具是苹果自带的网络分析工具
2. 通过 spotlight 搜索 网络实用工具
3. 或者 最左上角的苹果标志 --> 关于本机 -->点按'系统报告' --> 标题栏的'窗口' --> 网络实用工具 --> 点按'端口扫描'

![网络实用工具截图](/assets/mac-network.png)