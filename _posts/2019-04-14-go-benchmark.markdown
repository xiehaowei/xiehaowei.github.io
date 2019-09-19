---
layout: post
title:  "Go benchmark"
date:   2019-04-14 16:45:27 +0800
categories: [Go]
tags: [Go,benchmark]
excerpt: "go自带的benchmark可以方便快捷地在测试一个函数方法在串行或并行环境下的基准表现。指定一个时间（默认是1秒），看测试对象在达到或超过时间上限时，最多能被执行多少次和在此期间测试对象内存分配情况。"
---

#### benchmark常用API：

{% highlight go %}
b.StopTimer()

b.StartTimer()

b.ResetTimer()

b.Run(name string, f func(b *B))

b.RunParallel(body func(*PB))

b.ReportAllocs()

b.SetParallelism(p int)

b.SetBytes(n int64)

testing.Benchmark(f func(b *B)) BenchmarkResult
{% endhighlight %}


通过例子看它们之间的组合用法。benchtime默认为1秒。

串行用法
{% highlight go %}
func BenchmarkFoo(b *testing.B) {
  for i:=0; i<b.N; i++ {
    dosomething()
  }
}
{% endhighlight %}

最基本用法，测试dosomething()在达到1秒或超过1秒时，总共执行多少次。b.N的值就是最大次数。


并行用法

{% highlight go %}
func BenchmarkFoo(b *testing.B) {
  b.RunParallel(func(pb *testing.PB) {
    for pb.Next() {
      dosomething()
    }
  })
}
{% endhighlight %}

如果代码只是像上例这样写，那么并行的goroutine个数是默认等于runtime.GOMAXPROCS(0)。

创建P个goroutine之后，再把b.N打散到每个goroutine上执行。所以并行用法就比较适合IO型的测试对象。



若想增大goroutine的个数，那就使用b.SetParallelism(p int)。



{% highlight shell %}

// 最终goroutine个数 = 形参p的值 * runtime.GOMAXPROCS(0)
numProcs := b.parallelism * runtime.GOMAXPROCS(0)
{% endhighlight %}

要注意，b.SetParallelism()的调用一定要放在b.RunParallel()之前。



并行用法带来一些启示，注意到b.N是被RunParallel()接管的。意味着，开发者可以自己写一个RunParallel()方法，goroutine个数和b.N的打散机制自己控制。或接管b.N之后，定制自己的策略。

要注意b.N会递增，这次b.N执行完，不满足终止条件，就会递增b.N，逼近上限，直至满足终止条件。


{% highlight go %}
// 终止策略: 执行过程中没有竟   态问题 & 时间没超出 & 次数没达到上限
// d := b.benchTime
if !b.failed && b.duration < d && n < 1e9 {}
{% endhighlight %}



Start/Stop/ResetTimer()
这三个都是对 计时统计器 和 内存统计器 操作。

benchmark中难免有一些初始化的工作，这些工作耗时不希望被计算进benchmark结果中。

通常做法是

{% highlight go %}
func (b *B) StartTimer() {
  if !b.timerOn {
    // 记录当前时间为开始时间 和 内存分配情况
    b.timerOn = true
  }
}
func (b *B) StopTimer() {
  if b.timerOn {
    // 累计记录执行的时间（当前时间 - 记录的开始时间）
    // 累计记录内存分配次数和分配字节数
    b.timerOn = false
  }
}
func (b *B) ResetTimer() {
  if b.timerOn {
    // 记录当前时间为开始时间 和 内存分配情况
  }
  // 清空所有的累计变量
}
{% endhighlight %}

#### b.Run()
虽然这个方法被暴露了，但其实在源码内部它是被复用的(下文原理部分介绍)。

它作用就是生成一个subbenchmark，每一个subbenchmark都被当成一个普通的Benchmark执行。

有了它，表驱动法派上用场。

{% highlight go %}

func BenchmarkGCMRead(b *testing.B) {
  tests := []struct {
    keyLength   int
    valueLength int
    expectStale bool
  }{
    {keyLength: 16, valueLength: 1024, expectStale: false},
    {keyLength: 32, valueLength: 1024, expectStale: false},
    // more
  }
  for _, t := range tests {
    name := fmt.Sprintf("%vKeyLength/%vValueLength/%vExpectStale", t.keyLength, t.valueLength, t.expectStale)
    b.Run(name, func(b *testing.B) {
      benchmarkGCMRead(b, t.keyLength, t.valueLength, t.expectStale)
    })
  }
}

{% endhighlight %}