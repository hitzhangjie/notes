软件性能测试

在软件性能测试过程中，常细分为性能测试、压力测试、负载测试。

- 性能测试
以系统设计初期规划的性能指标为预期指标，对系统不断施加压力，验证系统在资源可接受范围内，是否能达到性能预期。

- 负载测试
对系统不断增加并发请求，以增加系统压力，直到系统的某项或多项性能 指标达到安全临界值。当并发请求数量超过安全临界值之后，系统吞吐量不升反降。实际系统部署时需要权衡性能、成本，应尽量保障系统工作在预期设计性能和安全负载性能之间，以保证系统可用性。

- 压力测试
超过安全负载的情况下，对系统继续施加压力，直到系统崩溃或不能再处理任何请求，以此获得系统最大压力承受能力。软件系统的最大性能并不是随着请求量的飙升而继续上升，在请求量超过某个临界值之后，软件系统的性能会不升反降，甚至完全不能响应任何请求。就好比一个人一小时最多能保质保量写一篇文章，非要让他写十篇，结果是一篇也无法写好，甚至完全不能交稿。

- 稳定性测试
被测试系统在特定硬件、软件、网络环境条件下，给系统施加一定业务压力， 运行一段较长时间，以此检测系统是否稳定。

>通过上述性能测试可以获得3个重要的点，分别是 “**系统最佳运行点、系统最大负载点、系统崩溃点**”。

不少开发者经常把 “**压测**” 挂在嘴边，实则并没有明白上述指标的差异，也没有在软件系统上线之前就对上述重要指标明了于心，而是以敏捷之名将上述前期应该做好的工作拖到了后期的 “**视图告警**” 。结果24小时待命响应告警成了一个员工是否工作靠谱的指标，这是非常不值得认可的。

# 性能测试工具
认识到了上述性能测试指标的差异之后，需要有一款合适的测试工具来获取待测试软件系统的上述指标。那么如何有什么现成的工具可供大家使用呢？

一般可以自己编写压测工具、脚本来对服务性能进行压测，可以从以下方面入手：
- 服务端设置请求处理超时时间，从recv req开始计时，处理完成之前如果超时则放弃处理
- 客户端指定传输模式，tcp、udp、http等
- 客户端指定请求超时时间，客户端可能对响应时间敏感程度不同，超时时间需可配置化
- 客户端指定并发请求数量，并每隔一定时间（如10s）统计一下该10s内共发送、接收的请求数量、超时数量、qps
- 压测的服务端、客户端应用不同的机器进行模拟，避免二者相互干扰
- 压测过程需持续一定的时间，如压测10min或者15min甚至更久，以对服务稳定性进行充分测试
- 压测期间需密切关注系统负载变化，如cpu占用率、内存占用率、磁盘io、网络io情况等
- 压测应该输出量化的压测报告，服务瓶颈分析（如瓶颈是cpu，还是内存，还是网卡等等）

这里的压测工具可以根据需要自行选择或者自己编写，如可以选择“**apache benchmark，简称ab**”对http服务进行压测，压测期间也可以结合一些其他工具来分析性能瓶颈，如“**perf**”定位cpu占用率高的问题，“**free -m**”以及“**/var/log/messages**”定位内存占用偏高导致oom的问题。

- perf top，可以对cpu执行的函数进行采样，并按照执行频率最高的从高到底进行排列，以便定位cpu占用高的原因;
- free -m，可以显示当前剩余内存，也可以用其他工具进行查看；
- 也可以自己编写脚本之类的，查看指定进程的内存随时间变化情况；
```bash
function memstat {
    pid=`ps aux | grep test_benchmark_svr | head -n 1 | awk '{print $2}'`

    while [ 1 -eq 1 ]; do cat /proc/${pid}/status  | grep -i vmrss; sleep 1; done
}
```

# go服务性能分析
go标准库中内置了运行时监控、采样能力，以便对服务性能进行深入洞察，下面描述下go提供的相关工具及其工作原理、使用方式等。

go提供了一些内置工具来探查程序中的内存占用问题、执行耗时问题、cpu占用等问题，如`go tool pprof`，`go test -bench=. -benchmem`，也有一些第三方的非常好用的工具，如`go-torch pprof`，`gops`等等。

## go tool pprof
pprof可以对程序执行过程进行采样，并对采样结果进行汇总，通过一些交互式命令来查看采样期间的执行耗时、内存占用等情况，同时它也提供了一些可视化的方式来更加直观地将问题展示出来。

### 执行耗时

```sh
# 执行该命令启动cpu执行耗时采样
go tool pprof -seconds=10  http://ip:port/debug/pprof/profile

# 列出采样期间最频繁执行的指令（方法、语句）
top 10

# 列出某个方法的详细执行耗时信息（flat、cum）
# - flat表示单条语句执行的耗时情况
# - cum表示整个采样期间该语句总执行耗时
list funcName

# svg将采样期间的调用情况、执行耗时情况，以callgraph的形式进行可视化
svg
```

这里的可视化方式，除了callgraph（调用图）以外，另一种比较直观的方式是flamegraph（火焰图），`go-torch pprof`内部会调用`go tool pprof`并将采样结果使用flamegraph的形式可视化，其使用方式与后者类似，`go-torch pprof -seconds=10 http://ip:port/debug/pprof/profile`。

### 内存占用

```sh
# 执行该命令启动cpu执行内存采样
go tool pprof -seconds=10  http://ip:port/debug/pprof/heap

# 列出采样期间内存占用频繁的指令（方法、语句）
top 10

# 列出某个方法的详细内存占用信息（flat、cum）
# - flat表示单条语句执行的内存占用情况
# - cum表示整个采样期间该语句总内存占用耗时
list funcName

# svg将采样期间的调用情况、内存占用情况，以callgraph的形式进行可视化
svg
```

## go test -bench=. -benchmem

首先要了解go benchmark test的执行过程，以及如何编写一个benchmark test，下面是一个示例。

```go
type Student struct {
  Name string
  Age int
  Sex int
}
func BenchmarkTestAny(b *testing.B) {
  for i:=0; i<b.N; b++ {
    _ = &Student{Name:"whoami", Age:100, Sex:1}
  }
}
```

benchmark测试（基准测试）会将目标代码（for循环体中的代码）执行b.N次，并对测试期间的内存、cpu占用情况进行采样分析，并最终将for循环体单次执行的平均执行耗时情况、内存占用情况进行计算输出。

## 总结

这里只是将本人平时常用的操作进行了一下整理，还有很多第三方的软件可供使用，当然golang内置的pprof、benchmark test也已经很强大了，归根结底还是要求我们要了解golang的执行原理，理解OS原理，才能够敏感的觉察出程序中存在的执行耗时、内存占用问题，才能够进一步想到更好的优化方案。

关于go程序的pprof操作，可以参考下面的两个分享：
- 点击阅读 -> [golang performance and memory analysis](http://blog.ralch.com/tutorial/golang-performance-and-memory-analysis/)
- 点击观看 -> [profiling and optimizating go](https://www.youtube.com/watch?v=N3PWzBeLX2M)
