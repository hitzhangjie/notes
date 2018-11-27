golang中提供了sync pacckage，提供了一些其他的并发同步技术。


# 1 sync.WaitGroup

sync.WaitGroup（类似于Java里面的CountDownLatch）用来等待所有的协程执行结束，使用方式是：

- `wg := &amp;sync.WaitGroup{}`

- 开启一个新的协程前，调用`wg.Add(1)`，

- 协程退出阶段调用`defer wg.Done()`,
- 等待上述协程执行结束调用`wg.Wait()`,

sync.WaitGroup里面维护一个计数器，值大于等于0，当调用sync.Wait()时将当前协程阻塞，直到其他协程通过wg.Done()将计数器的值更新为0才会恢复该阻塞协程的执行。

看个示例程序：

```go
func() {
    var wg sync.WaitGroup
    wg.Add(1)

    for i := 0; i < N; i++ {
        i := i
        go func() {
            wg.Wait()
            fmt.Printf("values[%v]=%v \n", i, values[i])
        }()
    }

    // The loop is guaranteed to finish before
    // any above wg.Wait calls returns.
    for i := 0; i < N; i++ {
        values[i] = 50 + rand.Int31n(50)
    }
    wg.Done() // will make a broadcast
}
```

# 2 sync.Once

sync.Once的Do(funval)只会执行一次

看个示例程序：

```go
func main() {
    log.SetFlags(0)

    x := 0
    doSomething := func() {
        x++
        log.Println("Hello")
    }

    var wg sync.WaitGroup
    var once sync.Once
    for i := 0; i < 5; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            once.Do(doSomething)
            log.Println("world!")
        }()
    }

    wg.Wait()
    log.Println("x =", x) // x = 1
}
```

上面hello知会打印一次，但是world会打印5次，x=1。

# 3 sync.Mutex & sync.RWMutex

互斥锁、读写锁，二者都实现了sync.Locker接口，都实现了方法Lock()和UnLock()，但是读写锁还实现了RLock()和RUnLock()。

# 4 sync.Cond

条件变量sync.Cond可以实现多个goroutine之间的高效通知，sync.Cond内部维护一个锁L sync.Locker，c.L通常是一个*sync.Mutex或*sync.RWMutex实现。sync.Cond内部除了一个L sync.Locker，还维护了一个goroutine等待队列，队列中的所有goroutine都是因为等待该条件变量上的通知而被阻塞的。sync.Cond包括3个方法Wait()、Signal()、Broadcast()，执行这任意一个操作之前，都必须先持有锁L，因为这三个操作都涉及到对条件变量内部goroutine等待队列的修改，因此需要上锁。

下面总结下3个方法执行的操作：

## 1) c.Wait()

- 将当前执行的goroutine加入到c中的goroutine等待队列中；
- 修改c完毕，执行c.L.UnLock()释放c.L；
- 当前goroutine暂停执行，等待被其他goroutine执行c.Signal()或者c.Broadcast()来唤醒当前goroutine，该goroutine被唤醒后会立即执行c.L.Lock()，然后返回；
  注意第一步要修改goroutine等待队列，所以要求先持有锁c.L，如果没有持有锁的话，第二步释放锁会导致panic。

## 2) c.Signal()

- 从c的gorotine等待队列中取出一个goroutine恢复其执行；
- 释放锁c.L；
  这个操作也涉及到对内部结构的修改，需要先持有锁，否则会panic。

## 3) c.Broadcast()

- 从c的goroutine等待队列中取出所有的goroutine恢复其执行；
- 释放锁c.L；
  这个操作也涉及到对内部结构的修改，需要先持有锁，否则会panic。

大多数情况下c.Signal()和c.Broadcast()是在c.Wait()执行结束后才执行的，这种情况下协程a因为等待c而阻塞，协程b执行c.Signal()或者c.Broadcast()唤醒a是没有任何问题的，但是：

- 假如a在执行c.Wait()过程中刚刚释放锁c.L就收到了协程b的c.Signal()，协程a可能不会进入阻塞状态；
- 假如a在执行c.Wait()过程中刚刚释放锁c.L就收到了协程b的c.Broadcast()，协程a可能不会进入阻塞状态；

下面是一个sync.Cond的示例：

```go
var (
	fooIsDone = false // Here, the user defined condition
	barIsDone = false // is composed of two parts.
	cond      = sync.NewCond(&amp;sync.Mutex{})
)

func doFoo() {
	time.Sleep(time.Second) // simulate a workload
	cond.L.Lock()
	fooIsDone = true
	cond.Signal() // called when cond.L locker is acquired
	cond.L.Unlock()
}

func doBar() {
	time.Sleep(time.Second * 2) // simulate a workload
	cond.L.Lock()
	barIsDone = true
	cond.L.Unlock()
	cond.Signal() // called when cond.L locker is released
}

func main() {
	cond.L.Lock()
	
    go doFoo()
    go doBar()

    checkConditon := func() bool {
        fmt.Println(fooIsDone, barIsDone)
        return fooIsDone &amp;&amp; barIsDone
    }
    for !checkConditon() {
        cond.Wait()
    }

    cond.L.Unlock()
}
```


