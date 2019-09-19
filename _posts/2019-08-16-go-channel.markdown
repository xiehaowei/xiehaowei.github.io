---
layout: post
title:  "Go channel 分析"
date:   2019-03-20 16:45:27 +0800
categories: [Go]
tags: [Go,channel]
excerpt: "gin middleware to automatically generate RESTful API documentation with Swagger 2.0."
---

#### 1. runtime/chan.go

{% highlight go %}
type hchan struct {
	qcount   uint           // total data in the queue
	dataqsiz uint           // size of the circular queue
	buf      unsafe.Pointer // points to an array of dataqsiz elements
	elemsize uint16
	closed   uint32
	elemtype *_type // element type
	sendx    uint   // send index
	recvx    uint   // receive index
	recvq    waitq  // list of recv waiters
	sendq    waitq  // list of send waiters

	// lock protects all fields in hchan, as well as several
	// fields in sudogs blocked on this channel.
	//
	// Do not change another G's status while holding this lock
	// (in particular, do not ready a G), as this can deadlock
	// with stack shrinking.
	lock mutex
}
{% endhighlight %}


* buf是有缓冲的channel所特有的结构，用来存储缓存数据。是个循环链表

* sendx和 recvx用于记录 buf这个循环链表中的~发送或者接收的~index

* lock是个互斥锁。

* recvq和 sendq分别是接收(<-channel)或者发送(channel <- xxx)的goroutine抽象出来的结构体(sudog)的队列。是个双向链表



#### 2. 我们首先创建一个channel。

{% highlight go %}
ch := make(chan int,3)
{% endhighlight %}

创建channel实际上就是在内存中实例化了一个 hchan的结构体，并返回一个ch指针，我们使用过程中channel在函数之间的传递都是用的这个指针，这就是为什么函数传递中无需使用channel的指针，而直接用channel就行了，因为channel本身就是一个指针。

channel中发送send(ch <- xxx)和recv(<- ch)接收
先考虑一个问题，如果你想让goroutine以先进先出(FIFO)的方式进入一个结构体中，你会怎么操作？加锁！对的！channel就是用了一个锁。hchan本身包含一个互斥锁 mutex

channel中队列是如何实现的
channel中有个缓存buf，是用来缓存数据的(假如实例化了带缓存的channel的话)队列。

当使用 send(ch<-xx)或者 recv(<-ch)的时候，首先要锁住 hchan这个结构体。

recvx和 sendx是根据循环链表 buf的变动而改变的。至于为什么channel会使用循环链表作为缓存结构，我个人认为是在缓存列表在动态的 send和 recv过程中，定位当前 send或者 recvx的位置、选择 send的和 recvx的位置比较方便吧，只要顺着链表顺序一直旋转操作就好。

缓存中按链表顺序存放，取数据的时候按链表顺序读取，符合FIFO的原则。

send/recv的细化操作
注意：缓存链表中以上每一步的操作，都是需要加锁操作的！

每一步的操作的细节可以细化为：

第一，加锁

第二，把数据从goroutine中copy到“队列”中(或者从队列中copy到goroutine中）。

第三，释放锁

当channel缓存满了之后会发生什么？这其中的原理是怎样的？
使用的时候，我们都知道，当channel缓存满了，或者没有缓存的时候，我们继续send(ch <- xxx)或者recv(<- ch)会阻塞当前goroutine，但是，是如何实现的呢？

我们知道，Go的goroutine是用户态的线程( user-space threads)，用户态的线程是需要自己去调度的，Go有运行时的scheduler去帮我们完成调度这件事情。