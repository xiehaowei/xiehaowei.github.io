---
layout: post
title:  "algorithm"
date:   2016-09-18 22:07:11 +0800
categories: [algorithm]
---

### 1. 合并排序，将两个已经排序的数组合并成一个数组，其中一个数组能容下两个数组的所有元素

{% highlight c++ %}
//合并排序，将两个已经排序的数组合并成一个数组，其中一个数组能容下两个数组的所有元素
void MergeArray(int a[],int alen,int b[],int blen)
{
    int len=alen+blen-1; 
    alen--;
    blen--;
    while (alen>=0 && blen>=0)
    {
        if (a[alen]>b[blen])
        {
            a[len--]=a[alen--];
        }else{
            a[len--]=b[blen--]; 
        }
    }
 
    while (alen>=0)
    {
        a[len--]=a[alen--];
    } 
    while (blen>=0)
    {
        a[len--]=b[blen--];
    } 
}
 
void MergeArrayTest()
{
    int a[]={2,4,6,8,10,0,0,0,0,0};
    int b[]={1,3,5,7,9};
    MergeArray(a,5,b,5);
    for (int i=0;i<sizeof(a)/sizeof(a[0]);i++)
    {
        cout<<a[i]<<" ";
    }
}
{% endhighlight %}

