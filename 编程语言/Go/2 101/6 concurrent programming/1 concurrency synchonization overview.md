# Concurrency Synchronization Overview

## What Are Synchronizations?  [go101.org]

在一个并发程序里面，可能存在多个goroutine同时访问相同数据的情况，必须对相同数据的访问进行控制，否则数据的完整性就不能被保证。

可以借助多种方式来进行同步控制，或者是传输数据的所有权到另一个goroutine，或者是保护数据避免同时被多个goroutine访问。

**对数据的访问权限控制，又可细分为写权限和读权限**：

- 写权限是排他性的，如果一个goroutine拥有了对数据的写权限，其他所有goroutine不能读写该数据；
- 读权限是非排他性的，如果一个goroutine拥有了对数据的读权限，其他所有goroutine都可以继续获得读权限，但是不允许任何其他goroutine获取写权限。"

## What Synchronization Techniques Does Go Support?  [go101.org]

golang提供了哪些同步控制技术呢？之前了解过用chan进行同步控制，除了chan，go也提供了一些其他的同步技术，例如sync、atomic包。

也可以通过网络IO、文件IO做同步，但是对于单进程程序来说这样代价有点高，通常是在进程间同步、分布式同步时会考虑用这种技术。

为了更好地理解同步技术，强烈建议阅读golang的memory order guarantees。golang的同步技术只能帮助我们更容易地并发编程并享受编码的乐趣，但是如果理解地不够透彻，仍然容易犯错误写出错误的代码。
