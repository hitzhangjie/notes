# How Goroutines Work

## Feb 23, 2014 11:09 · 1008 words · 5 minute read

### Introduction to Go

If you are new to the Go programming language, or if the sentence “Concurrency is not parallelism” means nothing to you, then check out Rob Pike’s [excellent talk on the subject](http://www.youtube.com/watch?v=cN_DpYBzKso). Its 30 minutes long, and I guarantee that watching it is 30 minutes well spent.

To summarize the difference - “when people hear the word concurrency they often think of parallelism, a related but quite distinct concept. In programming, concurrency is the composition of independently executing processes, while parallelism is the simultaneous execution of (possibly related) computations. Concurrency is about dealing with lots of things at once. Parallelism is about doing lots of things at once.” [1]

Go allows us to write concurrent programs. It provides goroutines and importantly, the ability to communicate between them. I will focus on the former.

### Goroutines and Threads - the differences

Go uses goroutines while a language like Java uses threads. What are the differences between the two? We need to look at 3 factors - memory consumption, setup and teardown and switching time.

#### Memory consumption

The creation of a goroutine does not require much memory - only 2KB of stack space. They grow by allocating and freeing heap storage as required.[2][3] Threads on the other hand start out at 1MB (500 times more), along with a region of memory called a guard page that acts as a guard between one thread’s memory and another.[7]

A server handling incoming requests can therefore create one goroutine per request without a problem, but one thread per request will eventually lead to the dreaded OutOfMemoryError. This isn’t limited to Java - any language that uses OS threads as the primary means of concurrency will face this issue.

**哇！创建一个线程要耗费1MB的内存，一个64位Linux操作系统最多也就允许创建2000+个协程，2GB，也很吃内存了。但是一个协程栈空间初始只有2KB，这部分内存对绝大多数网络请求来说也差不多足够了，差不多可以省500倍的内存。2GB，几百万并发不是梦。**

#### Setup and teardown costs

Threads have significant setup and teardown costs because it has to request resources from the OS and return it once its done. The workaround to this problem is to maintain a pool of threads. In contrast, goroutines are created and destroyed by the runtime and those operations are pretty cheap. The language doesn’t support manual management of goroutines.

**线程创建销毁的代价，比协程大很多！**

#### Switching costs

When a thread blocks, another has to be scheduled in its place. Threads are scheduled preemptively, and during a thread switch, the scheduler needs to save/restore ALL registers, that is, 16 general purpose registers, PC (Program Counter), SP (Stack Pointer), segment registers, 16 XMM registers, FP coprocessor state, 16 AVX registers, all MSRs etc. This is quite significant when there is rapid switching between threads.

Goroutines are scheduled cooperatively and when a switch occurs, only 3 registers need to be saved/restored - Program Counter, Stack Pointer and DX. The cost is much lower.

As discussed earlier, the number of goroutines is generally much higher, but that doesn’t make a difference to switching time for two reasons. Only runnable goroutines are considered, blocked ones aren’t. Also, modern schedulers are O(1) complexity, meaning switching time is not affected by the number of choices (threads or goroutines).[5]

**线程切换代价要保存的寄存器数量实在是太多了，goroutine协程切换只需要保存3个寄存器的值，开销小很多。**

### How goroutines are executed

As mentioned earlier, the runtime manages the goroutines throughout from creation to scheduling to teardown. The runtime is allocated a few threads on which all the goroutines are multiplexed. At any point of time, each thread will be executing one goroutine. If that goroutine is blocked, then it will be swapped out for another goroutine that will execute on that thread instead.[6]

As the goroutines are scheduled cooperatively, a goroutine that loops continuously can starve other goroutines on the same thread. In Go 1.2, this problem is somewhat alleviated by occasionally invoking the Go scheduler when entering a function, so a loop that includes a non-inlined function call can be prempted.

用下面的代码测试了下：
```go
func main() {

	go func() {
		i := 0
		for {
			i++
		}
	}()

	go func() {
		for {
			fmt.Println("Preempte")
			time.Sleep(time.Second)
		}
	}()

	select{}
}
```
测试结果如下，这表明go运行时会对for循环进行检测，并在必要时进行抢占式调度：
```bash
Preempte
Preempte
Preempte
Preempte
...
```

### Goroutines blocking

Goroutines are cheap and do not cause the thread on which they are multiplexed to block if they are blocked on

- network input
- sleeping
- channel operations or
- blocking on primitives in the sync package.

Even if tens of thousands of goroutines have been spawned, it’s not a waste of system resources if most of them are blocked on one of these since the runtime schedules another goroutine instead.

In simple terms, goroutines are a lightweight abstraction over threads. A Go programmer does not deal with threads, and similarly the OS is not aware of the existence of goroutines. From the OS’s perspective, a Go program will behave like an event-driven C program. [5]

### Threads and processors

Although you cannot directly control the number of threads that the runtime will create, it is possible to set the number of processor cores used by the program. This is done by setting the variable `GOMAXPROCS` with a call to `runtime.GOMAXPROCS(n)`. Increasing the number of cores may not necessarily improve the performance of your program, depending on its design. The profiling tools can be used to find the ideal number of cores for your program.

### Closing thoughts

As with other languages, it is important to prevent simultaneous access of shared resources by more than one goroutine. It is best to transfer data between goroutines using channels, ie, [do not communicate by sharing memory; instead, share memory by communicating](https://blog.golang.org/share-memory-by-communicating).

Lastly, I’d strongly recommend you check out [Communicating Sequential Processes](http://www.cs.cmu.edu/~crary/819-f09/Hoare78.pdf) by C. A. R. Hoare. This man was truly a genius. In this paper (published 1978) he predicted how the single core performance of processors would eventually plateau and chip-makers would instead increase the number of cores. His proposal to exploit this had a deep influence on the design of Go.

### Footnotes

- [1](http://blog.golang.org/concurrency-is-not-parallelism) - Concurrency is not parallelism by Rob Pike
- [2](http://golang.org/doc/effective_go.html#goroutines) - Effective Go: Goroutines
- [3](http://golang.org/doc/go1.4#runtime) - Goroutine stack size was decreased from 8kB to 2kB in Go 1.4.
- [4](http://agis.io/2014/03/25/contiguous-stacks-in-go.html) - Goroutine stacks became contiguous in Go 1.3
- [5](https://groups.google.com/forum/#!topic/golang-nuts/j51G7ieoKh4) - Dmitry Vyukov explains scheduling of goroutines on golang-nuts
- [6](http://www1.cs.columbia.edu/~aho/cs6998/reports/12-12-11_DeshpandeSponslerWeiss_GO.pdf) - Analysis of the Go runtime scheduler by Deshpande et al.
- [7](http://dave.cheney.net/2014/06/07/five-things-that-make-go-fast) - 5 things that make Go fast by Dave Cheney

\###Further Reading

If you’re interested in learning more about Go, there are a couple great talks about the language here

- [Go Concurrency Patterns](http://www.youtube.com/watch?v=f6kdp27TYZs%E2%80%8E) by Rob Pike
- [Advanced Go Concurrency Patterns](http://www.youtube.com/watch?v=QDDwwePbDtw) by Sameer Ajmani.

© Copyright 2019  Krishna Sundarram