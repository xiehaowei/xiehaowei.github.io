---
layout: post
title:  "Go LRU Cache"
date:   2019-06-25 15:10:00 +0800
categories: [Go]
tags: [Go,lru,cache]
excerpt: "用go 实现 lru 用于缓存"
---
#### LRU缓存淘汰算法
LRU是最近最少使用策略的缩写，是根据数据的历史访问记录来进行淘汰数据，其核心思想是“如果数据最近被访问过，那么将来被访问的几率也更高”。

#### 双向链表实现LRU
将Cache的所有位置都用双链表连接起来，当一个位置被访问(get/put)之后，通过调整链表的指向，将该位置调整到链表尾的位置，新加入的Cache直接加到链表尾。

这样，在多次操作后，最近被访问(get/put)的，就会被向链表尾方向移动，而没有访问的，向链表前方移动，链表头则表示最近最少使用的Cache。

当达到缓存容量上限时，链表头就是最少被访问的Cache，我们只需要删除链表头便可继续添加新的Cache。

#### 代码实现

{% highlight go %}
type Node struct {
    Key int
    Value int
    pre *Node
    next *Node
}

type LRUCache struct {
    limit int
    HashMap map[int]*Node
    head *Node
    end *Node
}

func Constructor(capacity int) LRUCache{
    lruCache := LRUCache{limit:capacity}
    lruCache.HashMap = make(map[int]*Node, capacity)
    return lruCache
}

func (l *LRUCache) Get(key int) int {
    if v,ok:= l.HashMap[key];ok {
        l.refreshNode(v)
        return v.Value
    }else {
        return -1
    }
}

func (l *LRUCache) Put(key int, value int) {
    if v,ok := l.HashMap[key];!ok{
        if len(l.HashMap) >= l.limit{
            oldKey := l.removeNode(l.head)
            delete(l.HashMap, oldKey)
        }
        node := Node{Key:key, Value:value}
        l.addNode(&node)
        l.HashMap[key] = &node
    }else {
        v.Value = value
        l.refreshNode(v)
    }
}

func (l *LRUCache) refreshNode(node *Node){
    if node == l.end {
        return
    }
    l.removeNode(node)
    l.addNode(node)
}

func (l *LRUCache) removeNode(node *Node) int{
    if node == l.end  {
        l.end = l.end.pre
    }else if node == l.head {
        l.head = l.head.next
    }else {
        node.pre.next = node.next
        node.next.pre = node.pre
    }
    return node.Key
}

func (l *LRUCache) addNode(node *Node){
    if l.end != nil {
        l.end.next = node
        node.pre = l.end
        node.next = nil
    }
    l.end = node
    if l.head == nil {
        l.head = node
    }
}
{% endhighlight %}
