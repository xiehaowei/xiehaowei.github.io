---
layout: post
title:  "Redis-HyperLogLog"
date:   2019-06-09 17:24:57 +0800
categories: [Redis]
tags: [Redis,HyperLogLog]
excerpt: "gin middleware to automatically generate RESTful API documentation with Swagger 2.0."
---
基数计数(cardinality counting)通常用来统计一个集合中不重复的元素个数，例如统计某个网站的UV，或者用户搜索网站的关键词数量。如果统计 PV 那非常好办，给每个网页一个独立的 Redis 计数器就可以了，这个计数器的 key 后缀加上当天的日期。这样来一个请求，INCRBY 一次，最终就可以统计出所有的 PV 数据。

但是 UV 不一样，它要去重，同一个用户一天之内的多次访问请求只能计数一次。这就要求每一个网页请求都需要带上用户的 ID，无论是登陆用户还是未登陆用户都需要一个唯一 ID 来标识。如果采用元素越多耗费内存就越多的集合（HashSet、B+ Tree、BitMap）来存储已登录的用户ID，那么在输入元素的数量或者体积非常大时查重时间（O(log n)）与内存开销（O(n)）都是十分巨大的。相比之下HyperLogLog 计算基数所需的空间总是固定的、并且是很小的。在 Redis 里面，每个 HyperLogLog 键只需要花费 12 KB 内存，就可以计算接近 2^64 个不同元素的基数。

但是，因为 HyperLogLog 只会根据输入元素来计算基数，而不会储存输入元素本身，所以 HyperLogLog 不能像集合那样，返回输入的各个元素，也不能删除元素，这一点和布隆过滤器非常相似。

此外，HyperLogLog 提供的是不准确的去重计数方案，但是可以保证基数随统计量单调递增，并且标准误差达到 0.81%，这样的精确度已经可以满足大部分统计需求了。

HyperLogLog有三个非常简单的API：

PFADD 将多个值存入指定的HyperLogLog
PFCOUNT 获取指定HyperLogLog的基数
PFMERGE 合并多个HyperLogLog，合并前的结果和合并后的统计结果完全一致（取并集），不存在因合并导致的误差