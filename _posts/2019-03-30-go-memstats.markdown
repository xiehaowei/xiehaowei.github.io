---
layout: post
title:  "Go MemStats"
date:   2019-03-30 21:16:32 +0800
categories: [Go]
tags: [Go,MemStats]
excerpt: "Go内存泄漏学习"
---

#### 1. 常见Go内存泄露
* 获取长字符串中的一段导致长字符串未释放
* 同样，获取长slice中的一段导致长slice未释放
* 在长slice新建slice导致泄漏
* goroutine泄漏
* time.Ticker未关闭导致泄漏
* Finalizer导致泄漏
* Deferring Function Call导致泄漏

#### 2. Top
* %MEM：Memory usage (RES) 内存占用
使用的物理内存

* VIRT：Virtual Image (kb) 虚拟镜像
总虚拟内存的使用数量

* SWAP：Swapped size (kb)
非驻留但是存在于程序中的内存，虚拟内存减去物理内存

* RES：Resident size (kb)
非swap的物理内存

SHR：Shared Mem size (kb)
程序使用的共享内存，可以被其它进程所共享

#### 3. Go运行时的内存统计信息
{% highlight go %}
type MemStats struct {
        // 已分配的对象的字节数.
        //
        // 和HeapAlloc相同.
        Alloc uint64
        // 分配的字节数累积之和.
        //
        // 所以对象释放的时候这个值不会减少.
        TotalAlloc uint64
        // 从操作系统获得的内存总数.
        //
        // Sys是下面的XXXSys字段的数值的和, 是为堆、栈、其它内部数据保留的虚拟内存空间. 
        // 注意虚拟内存空间和物理内存的区别.
        Sys uint64
        // 运行时地址查找的次数，主要用在运行时内部调试上.
        Lookups uint64
        // 堆对象分配的次数累积和.
        // 活动对象的数量等于`Mallocs - Frees`.
        Mallocs uint64
        // 释放的对象数.
        Frees uint64
        // 分配的堆对象的字节数.
        //
        // 包括所有可访问的对象以及还未被垃圾回收的不可访问的对象.
        // 所以这个值是变化的，分配对象时会增加，垃圾回收对象时会减少.
        HeapAlloc uint64
        // 从操作系统获得的堆内存大小.
        //
        // 虚拟内存空间为堆保留的大小，包括还没有被使用的.
        // HeapSys 可被估算为堆已有的最大尺寸.
        HeapSys uint64
        // HeapIdle是idle(未被使用的) span中的字节数.
        //
        // Idle span是指没有任何对象的span,这些span **可以**返还给操作系统，或者它们可以被重用,
        // 或者它们可以用做栈内存.
        //
        // HeapIdle 减去 HeapReleased 的值可以当作"可以返回到操作系统但由运行时保留的内存量".
        // 以便在不向操作系统请求更多内存的情况下增加堆，也就是运行时的"小金库".
        //
        // 如果这个差值明显比堆的大小大很多，说明最近在活动堆的上有一次尖峰.
        HeapIdle uint64
        // 正在使用的span的字节大小.
        //
        // 正在使用的span是值它至少包含一个对象在其中.
        // HeapInuse 减去 HeapAlloc的值是为特殊大小保留的内存，但是当前还没有被使用.
        HeapInuse uint64
        // HeapReleased 是返还给操作系统的物理内存的字节数.
        //
        // 它统计了从idle span中返还给操作系统，没有被重新获取的内存大小.
        HeapReleased uint64
        // HeapObjects 实时统计的分配的堆对象的数量,类似HeapAlloc.
        HeapObjects uint64
        // 栈span使用的字节数。
        // 正在使用的栈span是指至少有一个栈在其中.
        //
        // 注意并没有idle的栈span,因为未使用的栈span会被返还给堆(HeapIdle).
        StackInuse uint64
        // 从操作系统取得的栈内存大小.
        // 等于StackInuse 再加上为操作系统线程栈获得的内存.
        StackSys uint64
        // 分配的mspan数据结构的字节数.
        MSpanInuse uint64
        // 从操作系统为mspan获取的内存字节数.
        MSpanSys uint64
        // 分配的mcache数据结构的字节数.
        MCacheInuse uint64
        // 从操作系统为mcache获取的内存字节数.
        MCacheSys uint64
        // 在profiling bucket hash tables中的内存字节数.
        BuckHashSys uint64
        // 垃圾回收元数据使用的内存字节数.
        GCSys uint64 // Go 1.2
        // off-heap的杂项内存字节数.
        OtherSys uint64 // Go 1.2
        // 下一次垃圾回收的目标大小，保证 HeapAlloc ≤ NextGC.
        // 基于当前可访问的数据和GOGC的值计算而得.
        NextGC uint64
        // 上一次垃圾回收的时间.
        LastGC uint64
        // 自程序开始 STW 暂停的累积纳秒数.
        // STW的时候除了垃圾回收器之外所有的goroutine都会暂停.
        PauseTotalNs uint64
        // 一个循环buffer，用来记录最近的256个GC STW的暂停时间.
        PauseNs [256]uint64
        // 最近256个GC暂停截止的时间.
        PauseEnd [256]uint64 // Go 1.4
        // GC的总次数.
        NumGC uint32
        // 强制GC的次数.
        NumForcedGC uint32 // Go 1.8
        // 自程序启动后由GC占用的CPU可用时间，数值在 0 到 1 之间.
        // 0代表GC没有消耗程序的CPU. GOMAXPROCS * 程序运行时间等于程序的CPU可用时间.
        GCCPUFraction float64 // Go 1.5
        // 是否允许GC.
        EnableGC bool
        // 未使用.
        DebugGC bool
        // 按照大小进行的内存分配的统计,具体可以看Go内存分配的文章介绍.
        BySize [61]struct {
                // Size is the maximum byte size of an object in this
                // size class.
                Size uint32
                // Mallocs is the cumulative count of heap objects
                // allocated in this size class. The cumulative bytes
                // of allocation is Size*Mallocs. The number of live
                // objects in this size class is Mallocs - Frees.
                Mallocs uint64
                // Frees is the cumulative count of heap objects freed
                // in this size class.
                Frees uint64
        }
}
{% endhighlight %}

