---
layout: post
title:  "Go unicode"
date:   2019-10-08 14:31:27 +0800
categories: [Go]
tags: [Go,unicode]
excerpt: "Go unicode"
---

#### 快速获取字符串 utf8字符个数
{% highlight go %}
import "unicode/utf8"
utf8.RuneCountInString()
{% endhighlight %}

#### 判断一个utf8 字符是含汉字 字母 还是数字 
{% highlight go %}
import "unicode/utf8"


  str := "判断一个utf8 字符是含汉字 字母 还是数字 （）《》- ="
	inSlice := []rune(str)
	outSlice := make([]rune,0,15)
	for _,v := range inSlice{
		if unicode.Is(unicode.Han,v){
			outSlice = append(outSlice,v)
		}else if v < 128{
			outSlice = append(outSlice,v)
			if unicode.IsDigit(v){
				outSlice = append(outSlice,v)
			} else if unicode.IsLetter(v){
				outSlice = append(outSlice,v)
			}
		}
 	}
{% endhighlight %}