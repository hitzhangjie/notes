看了下cache一致性协议MESI，结合多线程场景分析volatile：

一个volatile变量被多个线程读取了值，假定这几个线程跑在不同的cpu核心上，每个核心有自己的cache，线程1跑在core1上，线程2跑在core2上。

现在线程1准备修改变量值，这个时候会先修改cache中的值然后稍后某个时刻写回主存或者被其他core读取。cache同步策略“write-back”，MESI就是其中的一种。处理器所有的读写操作都能被总线观测到，snoop based cache coherency，当线程2准备读取这个变量时：

\- 假定之前没读取过，发现自己的cache里面没有，就通过总线向内存请求，为了保证cpu cached高吞吐量，总线上所有的事务都能被其他core观测到，core1发现core2要读取内存值，这个数据刚好在我的cache里面，但是处于dirty状态。core1可能灰采取两种动作，一种是将dirty数据直接丢给core2（至少是最新的），或者告知core2延迟read，等我先写回主存，然后core2再尝试read内存。

\- 假定之前读取过了，core1对变量的修改也会被core2观测到，core1应该将其cache line标记为invalidate，并使cache line失效，下次读取时从core1获取或者读内存（触发core1将dirty数据同步回主存）。

这么看来只要处理器的cache一致性算法支持，就能保证线程可见行，但是不同的处理器设计不一样，不一定能保证，编程语言级别的volatile来屏蔽掉不同处理器设计的差异，但是volatile究竟能否保证线程可见性呢？

几位同事推荐的文章链接里面，有描述volatile诞生之初要解决的问题：不可优化性、易变性、顺序性保证。一个可以概括这三点的很好的示例代码：

\```c

unsigned int *p = GetMagicAddress();

unsigned int a, b;



a = *p;

b = *p;



*p = a;

*p = b;

\```

编译器优化后会变成：

\```c

unsigned int *p = GetMagicAddress();

unsigned int a, b;

a = *p;

b = a;

*p = a;

\```

假如p指向的是一个memory-mapped io设备，期望的是一次从*p读取一个字节，连读读两个字节，优化后就只读了一个字节，写的时候也是。透过这个例子可以看到**不可优化性**的含义，另外*p表示外设写入的数据，连续两次读取外设写入信息不同，体现了**易变性**，另外指令重排序也不应该修改这里写入的顺序，比如先写a、再写b的问题，还是先写b再写a的问题，体现了**顺序性**。

很多人再强调，volatile只适用于memory-mapped io，究竟能否保证线程可见性，保持怀疑的态度。

2019-01-03 21:06:21 提问者补充[删除](javascript:void(0);)

在与@xinnjiege的讨论中，xinnjiege一再强调volatile的语义是明确的，这也让我重拾对标准的信心。在几十年的发展中，太多的开发者因为个人原因、其他语言的对比赋予了volatile一些标准中未指定的语义，导致出现了那么多的问题，也出现了很多纠正的说法“volatile与并发编程无关……”、“volatile可能只适用于memory mapped io……”等等。

标准是明确的，它确实没说volatile要保证线程可见性，综合大家反馈的信息、探讨，volatile是不会保证线程可见性的，在x86平台上具备线程可见性，但是这是x86设计上带来的效果，跟volatile无关。