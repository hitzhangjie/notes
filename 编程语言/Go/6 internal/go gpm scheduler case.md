“**纸上得来终觉浅，绝知此事要躬行**”，相信很多人都听说过go runtime scheduler - G.P.M work-stealing scheduler，而且讲的头头是道，但是究竟理解多少呢，在实际工作中遇到相关问题又能否分析、定位准确，就又是另一回事了，“纸上谈兵”者自古有之，今天也一样。搞技术的，最好还是能够知根知底，别含糊。

举这么个示例，大家猜一猜输出结果会是什么。

```go
package main

import "sync"
import "fmt"
import "runtime"

func main() {
	runtime.GOMAXPROCS(1)
	wg := sync.WaitGroup{}
	wg.Add(10)
	
	for i := 0; i < 10; i++ {
		go func(i int) {
			fmt.Println("ii: ", i)
			wg.Done()
		}(i)
	}
	wg.Wait()
}
```

程序多次运行后，输出结果均如下：

```bash
ii: 9
ii: 0
ii: 1
ii: 2
ii: 3
ii: 4
ii: 5
ii: 6
ii: 7
ii: 8
```

为什么多次运行后的结果，结果都是一样的呢？按常理，多个goroutine被调度的顺序应该不是完全固定的，为什么执行顺序总是`9, 0, 1, 2, 3, …, 8`呢，好吧，可能是因为我们限制了`runtime.GOMAXPROCS(1)`的缘故，那么为什么总是先输出`9`呢，而后面的又是按照固定顺序`0, 1, 2, 3, …, 8`呢？

好吧，这是一个促使我们研究下go runtime scheduler的好例子。开始吧！先看看这个ppt中介绍的内容，https://speakerdeck.com/retervision/go-runtime-scheduler，里面大致描述了`go func() {}`调用开始的大致执行过程。

首先描述下GPM中三者的具体职责。

>Gs, Ps, Ms Responsibility:
>
>- M must have an associated P to execute Go code, however it can be blocked or in a syscall w/o an associated P.
>- Gs are in P's local queue or global queue
>- G keeps current task status, provides stack

这里是调度初始化的过程，它根据环境变量GOMAXPROCS决定应该创建多少个P，并完成P的初始化，默认是核数，像我们这个示例中在运行时将其调成了1，会涉及到释放多余的P的过程，这里不展示出来了，感兴趣可以自己看代码。
```go
//go/src/runtime/proc.go
func schedinit(){
    ...
    procs:=int(ncpu)
    if n := atoi(gogetenv("GOMAXPROCS")); n>0 {
    	if n > _MaxGomaxprocs {
    		n = _MaxGomaxprocs
    	}
    	procs=n
    }
    if procresize(int32(procs)) != nil {
    	throw("unknown runnable goroutine during bootstrap")
    }
    ...
}
```

`GOMAXPROCS(n int)`这个函数又做了什么呢？先stopTheWorld，然后修改newprocs的值，再startTheWorld，这个函数会根据newprocs的值执行procresize(procs)操作。

```go
func GOMAXPROCS(n int) int {
	if n > _MaxGomaxprocs {
		n = _MaxGomaxprocs
	}
	lock(&sched.lock)
	ret := int(gomaxprocs)
	unlock(&sched.lock)
	if n <= 0 || n == ret {
		return ret
	}
	stopTheWorld("GOMAXPROCS")
	//newprocs will be processed by startTheWorld
	newprocs = int32(n)
	startTheWorld()
	return ret
}
```

当碰到`go func() {…}`语句的时候就会创建一个G — goroutine。goroutine在用户空间中创建，初始栈空间大小为2KB，由这个函数来创建goroutine `func newproc(siz int32, fn *funcval)`。这个函数最终会调用newproc1切换到系统栈上去执行goroutine的真正创建过程。首先从`_p_.gFree`检查有没有可供复用的空闲goroutine结构，有就拿出来，没有再去全局调度的`sched.gFree`里找，还没有就malg重新分配一个，这些是可复用的。然后设置好goroutine要执行的func地址，切换为runnable状态，然后挂到runnable queue上，就是`runqput(_p_, newg, true)`这个函数了。

```go
func newproc1(fn *funcval, argp *uint8, narg int32, callergp *g, callerpc uintptr) {
	_g_ := getg()
	...
	_p_ := _g_.m.p.ptr()
	newg := gfget(_p_)
	if newg == nil {
		newg = malg(_StackMin)
		casgstatus(newg, _Gidle, _Gdead)
		allgadd(newg) // publishes with a g->status of Gdead so GC scanner doesn't look at uninitialized stack.
	}
	...
	newg.startpc = fn.fn
	casgstatus(newg, _Gdead, _Grunnable)
    ...
	runqput(_p_, newg, true)
	...
}
```

这个函数将gp丢到`_p_`的一个runnable queue里等待调度，如果next为true呢，就将runnext设置为`_p_`，下次就调度它，如果next为false，就将gp丢到`_p_.runq`尾部，让它去排队。因为这里一直为true，所以呢？

当创建协程go func(v int){...}(0)的时候呢，runnext=0，接下来runq=[0]，runnext=1，接下来runq=[0,1]，runnext=2，……一直到runq=[0,1,2,3,4,5,6,7,8]，runnext=9。如果这个时候开始对协程启动调度，而且只有一个P，同一时刻最多只有一个M在调度goroutine，且这一个M或者多个M必将是按照顺序9、0、1、2、……8的顺序去调度的。因为runnext是9，最先被调度，接下来才会从runq中从头到尾去调度。就表现除了我们运行后的那种效果。

```go
// runqput tries to put g on the local runnable queue.
// If next is false, runqput adds g to the tail of the runnable queue.
// If next is true, runqput puts g in the _p_.runnext slot.
// If the run queue is full, runnext puts g on the global queue.
// Executed only by the owner P.
func runqput(_p_ *p, gp *g, next bool) {
	if randomizeScheduler && next && fastrand()%2 == 0 {
		next = false
	}

	if next {
	retryNext:
		oldnext := _p_.runnext
		if !_p_.runnext.cas(oldnext, guintptr(unsafe.Pointer(gp))) {
			goto retryNext
		}
		if oldnext == 0 {
			return
		}
		// Kick the old runnext out to the regular run queue.
		gp = oldnext.ptr()
	}

retry:
	h := atomic.LoadAcq(&_p_.runqhead) // load-acquire, synchronize with consumers
	t := _p_.runqtail
	if t-h < uint32(len(_p_.runq)) {
		_p_.runq[t%uint32(len(_p_.runq))].set(gp)
		atomic.StoreRel(&_p_.runqtail, t+1) // store-release, makes the item available for consumption
		return
	}
	if runqputslow(_p_, gp, h, t) {
		return
	}
	// the queue is not full, now the put above must succeed
	goto retry
}
```

现在想问的是，为什么创建了10个goroutine，中间却没有goroutine进行调度呢？为什么要等到第10个goroutine创建完了之后，才最终开始了goroutine的调度呢？这是什么原因呢？

因为go程序所有代码都是跑在goroutine中的，而且只有一个P，也就意味着同一时刻只有可能有一个M在调度Gs。而for循环体中创建goroutine的代码`for i:=0; i<10; i++ { go func(v int) {fmt.Println(v)}(i) }`,go func不会导致调用的协程挂起，也不会触发协程间的切换，所以所有的for循环执行完毕之后，wg.Wait()的时候当前协程挂起，创建的10个协程开始执行，并且是按照runnext=9、runq从头到尾=[0,1,2,3,…8]的顺序执行。

