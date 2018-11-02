# Kilim

## 1 概述

常用并发编程模型包括 **并发workers**、**pipeline (actor或channel)**。Kilim是基于actor的并发编程框架，它将线程进一步细分为协程，**协程创建、销毁、切换的开销都比线程小的多**，在 **网络IO密集型** 服务程序中，协程可以 **更加充分地利用多处理器、多核能力** 实现更高的并发。

## 2 核心类

### 2.1 Task

Task就是协程实体，自定义协程实体需要 **继承Task**，Task中方法execute()抛出 **Pausable异常**，Pausable方法并不是真的异常，而只是为了 **kilim.tools.Weaver 通过反射识别出需要暂停的方法**，然后 **“编织”、“织入”一些特殊的字节码，使得该方法可以在运行期间暂停、恢复执行**。

在自定义协程实体中，如果某个方法需要获得暂停、恢复执行的能力，那就要在定义时抛出Pausable异常。

## 2.2 Fiber & State

Java是基于vm的语言，Java方法的暂停、恢复执行不能通过保存物理机现场来实现，那如何实现呢？Kilim依赖于Fiber、State来实现Java方法的暂停、恢复。

- Fiber模拟了一个活动记录，记录了每个Pausable方法对应的pc、state信息
- State记录了一些状态信息，包括两个成员
  - int类型成员pc指示当前Pausing的第${pc}th个Pausable方法
  - Object类型成员寄存了当前Pausing方法中后续执行所需要的部分变量

Kilim中的后处理器Weaver会针对每个Pausable方法进行特殊处理，在其参数列表中追加一个Fiber参数，这个Fiber参数在整个调用链中是共享的，可以通过它追查到所有的Pausable方法信息，Fiber通过down()进入下一个Pausable方法的栈帧，Pausable方法返回后通过up()返回到上一个Pausable方法对应的栈帧。

### 2.3 Scheduler

Scheduler是Task调度器，它维护了一个线程池，并负责将Task交给线程池中的某个线程处理，每个线程有一个自己的任务列表，线程被调度时会自动从自己的任务列表里面获取Task并执行。在Linux平台下的hotspot虚拟机是采用的1:m的线程模型，即1个用户线程可能会在不同的运行期时间片中被映射到多个不同的内核线程上执行，通过内核线程的调度来完成协程的调度。

### 2.4 Mailbox

协程实体Task之间的通信是通过Mailbox来完成（类似于golang中的chan），Mailbox中可以放置任何类型的消息对象，它就是一个多生产者、单消费者的消息队列，可以以三种方式对其进行访问：put、putb、putnb，以及get、getb、getnb。

get、put：don't block thread, also don't pause fiber
getb、putb：block thread，这个特别重
getnb、putnb：don't block thead or don't pause fiber
