---
layout: post
title:  "Go strings Replacer & Join"
date:   2019-02-17 14:37:21 +0800
categories: [Go]
tags: [Go,string]
excerpt: "Go strings.Replacer & strings.Join"
---
### strings.Replacer
{% highlight go %}

type Replacer struct {
    		r replacer    //接口类型
}

// replacer is the interface that a replacement algorithm needs to implement.
type replacer interface {
    Replace(s string) string
    WriteString(w io.Writer, s string) (n int, err error)
}

func nl2br(originalStr string) string {
	relpacer := strings.NewReplacer("\n", "<br />", "\r", "")
	return relpacer.Replace(originalStr)
}
{% endhighlight %}

### strings.Join
{% highlight go %}
func Join(a []string, sep string) string {
    if len(a) == 0 {
        return ""
    }
    if len(a) == 1 {
        return a[0]
    }
    n := len(sep) * (len(a) - 1)
    for i := 0; i < len(a); i++ {
        n += len(a[i])
    }

    b := make([]byte, n)       //借助 字节切片实现
    bp := copy(b, a[0])        
    for _, s := range a[1:] {
        bp += copy(b[bp:], sep)
        bp += copy(b[bp:], s)
    }
    return str
    {% endhighlight %}