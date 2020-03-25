---
layout: post
title:  "Go Module (Go 1.13)"
date:   2019-09-07 11:27:27 +0800
categories: [Go]
tags: [Go,Module]
excerpt: "Go Modules | Golang 包管理方式"
---

#### Go 包管理历史
* 在 1.5 版本之前，所有的依赖包都是存放在 GOPATH 下，没有版本控制。这个类似 Google 使用单一仓库来管理代码的方式。这种方式的最大的弊端就是无法实现包的多版本控制，比如项目 A 和项目 B 依赖于不同版本的 package，如果 package 没有做到完全的向前兼容，往往会导致一些问题。
* 1.5 版本推出了 vendor 机制。所谓 vendor 机制，就是每个项目的根目录下可以有一个 vendor 目录，里面存放了该项目的依赖的 package。go build 的时候会先去 vendor 目录查找依赖，如果没有找到会再去 GOPATH 目录下查找
* 1.9 版本推出了实验性质的包管理工具 dep 
* 1.11 版本推出 modules 机制，简称go mod
* 1.13 Go module 进一步完善,modules 在 Go 1.13 的版本下是默认开启的

#### 在 1.12 版本之前 需要 环境变量 GO111MODULE:

> GO111MODULE=off: 不使用 modules 功能。

> GO111MODULE=on: 使用 modules 功能，不会去 GOPATH 下面查找依赖包。

> GO111MODULE=auto: Golang 自己检测是不是使用 modules 功能。

#### GoProxy 

目前公开的 GOPROXY 有：

* goproxy.io 官方
* goproxy.cn: 由七牛云提供

{% highlight shell %}
go env -w GOPROXY=https://goproxy.io,direct
# Set environment variable allow bypassing the proxy for selected modules
go env -w GOPRIVATE=*.corp.example.com
{% endhighlight %}

#### 常用命令
* 在项目根目录执行命令  go mod init <module>
* go get package@version Go使用语义化版本 [https://semver.org/](https://semver.org/ "语义化版本")
* go mod tidy 清理 go.mod 中的依赖，会添加缺失的依赖，同时移除没有用到的依赖
* go mod vendor

> replace 主要为了解决某些包发生改名的问题，也可以解决个别包无法下载 

{% highlight shell %}
replace golang.org/x/crypto v0.0.0-20181127143415-eb0de9b17e85 => github.com/golang/crypto v0.0.0-20181127143415-eb0de9b17e85,replace 主要为了解决某些包发生改名的问题。
{% endhighlight %}

#### GOPRIVATE
前面也说到对于一些内部的 package，GoProxy 并不能很好的处理，Go 1.13 推出了 GOPRIVATE 机制。只需要设置这个环境变量，然后标识出哪些 package 是 private 的，那么对于这个 package 的处理将不会从 proxy 下载。GOPRIVATE 的值是一个以逗号分隔的列表，支持正则（正则语法遵守 Golang 的 包 path.Match）。下面是一个 GOPRIVATE 的示例：


> GOPRIVATE=*.corp.example.com,rsc.io/private

上面的 GOPRIVATE 表示以 *.corp.example.com 或者 rsc.io/private 开头的 package 都是私有的。

一般使用

{% highlight shell %}
  go env -w GOPRIVATE=gitlab.*.com
  go env -w GOPROXY=https://goproxy.cn,direct
{% endhighlight %}


#### GOSUMDB
GOSUMDB 的全称为 Go CheckSum Database，用来下载的包的安全性校验问题。包的安全性在使用 GoProxy 之后更容易出现，比如我们引用了一个不安全的 GoProxy 之后然后下载了一个不安全的包，这个时候就出现了安全性问题。对于这种情况，可以通过 GOSUMDB 来对包的哈希值进行校验。当然如果想要关闭哈希校验，可以将 GOSUMDB 设置为 off；如果要对部分包关闭哈希校验，则可以将包的前缀设置到环境变量中 GONOSUMDB 中，设置规则类似 GOPRIVATE。