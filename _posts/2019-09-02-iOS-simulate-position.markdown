---
layout: post
title:  "iOS设备不越狱 模拟定位"
date:   2019-09-05 16:45:27 +0800
categories: [iOS]
tags: [iOS]
excerpt: "使用Mac Xcode 修改 iOS设备定位"
---

#### 1. 新建一个gpx文件，包含坐标用于模拟定位
{% highlight xml %}
<?xml version="1.0" encoding="UTF-8" ?>
<gpx version="1.1"
    creator="GMapToGPX 6.4j - http://www.elsewhere.org/GMapToGPX/"
    xmlns="http://www.topografix.com/GPX/1/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
    <wpt lat="30.593234492328744" lon="104.06263069384391">
    </wpt>
</gpx>
{% endhighlight %}

#### 2. 真机运行一个新建的空的iOS项目，把上面我们新建的gpx文件拖到工程里，配置一下Scheme，然后真机运行即可。

![Scheme](/assets/XcodeScheme.webp)

#### 3. 然后打开地图，发现定位到指定坐标的位置