---
layout: post
title:  "Nginx X-Sendfile"
date:   2016-09-17 22:07:11 +0800
categories: [nginx]
---

### 常见PHP 下载文件
{% highlight php %}
<?php
// 用户身份认证，若验证失败跳转
authenticate();
// 获取需要下载的文件，若文件不存在跳转
$file= determine_file();
// 读取文件内容
$content=file_get_contents($file);
// 发送合适的 HTTP 头
header("Content-type: application/octet-stream");
header('Content-Disposition: attachment; filename="'. basename($file) .'"');
header("Content-Length: ".filesize($file));
echo$content; // 或者 readfile($file);
?>
{% endhighlight %}
### 开启Nginx X-Sendfile
{% highlight conf %}
location /protected/ {
 internal;
 root  /some/path;
}
{% endhighlight %}

### PHP 使用 X-Sendfile
{% highlight php %}
<?php
$filePath= '/protected/iso.img';
header('Content-type: application/octet-stream');
header('Content-Disposition: attachment; filename="'. basename($file) .'"');
//让Xsendfile发送文件
header('X-Accel-Redirect: '.$filePath);
?>
{% endhighlight %}


### 如果不想显示 /protected路径
{% highlight conf %}
location /protected/ {
 internal;
 alias  /some/path/; # 注意最后的斜杠
}
{% endhighlight %}