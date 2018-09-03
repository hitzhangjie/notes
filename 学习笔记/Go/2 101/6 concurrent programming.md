
- Concurrent Programming
  - Concurrency Synchronization Overview
    - What Are Synchronizations?  [go101.org]
"在一个并发程序里面，可能存在多个goroutine同时访问相同数据的情况，必须对相同数据的访问进行控制，否则数据的完整性就不能被保证。
可以借助多种方式来进行同步控制，或者是传输数据的所有权到另一个goroutine，或者是保护数据避免同时被多个goroutine访问。
对数据的访问权限控制，又可细分为写权限和读权限：
- 写权限是排他性的，如果一个goroutine拥有了对数据的写权限，其他所有goroutine不能读写该数据；
- 读权限是非排他性的，如果一个goroutine拥有了对数据的读权限，其他所有goroutine都可以继续获得读权限，但是不允许任何其他goroutine获取写权限。"
    -  What Synchronization Techniques Does Go Support?  [go101.org]
"golang提供了哪些同步控制技术呢？之前了解过用chan进行同步控制，除了chan，go也提供了一些其他的同步技术，例如sync、atomic包。
也可以通过网络IO、文件IO做同步，但是对于单进程程序来说这样代价有点高，通常是在进程间同步、分布式同步时会考虑用这种技术。
为了更好地理解同步技术，强烈建议阅读golang的memory order guarantees。golang的同步技术只能帮助我们更容易地并发编程并享受编码的乐趣，但是如果理解地不够透彻，仍然容易犯错误写出错误的代码。"
  - Channel Use Cases
    - channel有哪些使用方式、场景、case？
"之前的章节channels in go描述了channel的类型、值的细节，新的go开发人员可能需要多阅读几遍这篇文章来彻底掌握go channel编程。
本文剩余部分将介绍所有的go channel使用场景，读完本节内容之后，读者应该确信：
- 使用go channel进行异步编程、并发编程是简单的、享受的；
- channel同步技术比其他异步编程模型（如actor模型）有更多的使用场景和变体。

本篇文章致力于展示尽可能多的channel使用场景，但是channel并不是go提供的唯一的一种并发同步技术。在某些场景下，channel同步方式并不是最佳解决方案，这个可以阅读atomic operations和some other synchronization techniques来了解下go提供的其他并发同步控制技术。

很多介绍go channel的文章会将使用场景、案例划分为几个大类，如：
- request-response pattern，请求响应方式；
- event based notification pattern，事件驱动方式；
- data flow pattern，数据流方式；

这篇文章不是按照这种方式进行描述的，因为这几种模式之间的界限本来就比较模糊的，有些channel使用案例同属于不止一个类型，所以本篇文章只是展示使用场景、案例，而不对此进行分类。
"
    - Use channels as futures/promises
      - What're Futures and promises  [en.wikipedia.org]
"计算机科学领域，术语future、promise、delay、deferred指的是并发编程中用于并发同步控制的技术。它们描述了一个可以获取结果的代理，这里的计算结果刚开始时是未知的（比如计算还没有完成），后续可以通过这个代理获取计算的最终结果。

这几个术语有时可以交换使用，下面描述下他们之间也有区别。 
- future是计算结果的一个视图，是只读的； 
- promise是可写的（可赋值的）容器，它可以设置future的值。 

尤其是，一个future到底由哪个promise来设置它的值可能是没有指定的，不同的promise可能会设置同一个future的值，尽管一个future可以限定只被设置一次。另外，一个future和一个promise可能是相互绑定的，是一对一的，future是结果视图，promise是这个设置future值的函数。例如一个异步计算函数（即promise）的返回值（即future）。设置future值的过程也称为resolving、fulfilling或者binding。"
      - 用channels来模拟futures、promises的示例介绍
"关于future、promise的区别可以通过wikipedia进行一下详细的了解，这里先做个粗略的概括吧。promise是对一个异步计算任务的描述，而future是对异步计算任务结果的一个只读视图，promise会设置future的值，promise递交给任务管理者时计算不一定完成，此时通过future不一定能拿到最终结果，但是通过future再将来任务执行完成后是可以拿到计算结果的。更好的做法是，为future添加callback，任务计算完成时即可通过callback对计算结果进行处理。
某些语言或者其第三方库提供了对promise、future的支持，这里golang中结合goroutine和channel也可以实现对promise、future的模拟。下面给出几个示例代码。
示例1：返回一个receive-only channel，通过它来返回任务计算结果，来模拟future。
func longTimeRequest() &lt;-chan int32 {
	r := make(chan int32)
	// This goroutine treats the channel r as a promise.
	go func() {
		time.Sleep(time.Second * 3) // simulate a workload
		r &lt;- rand.Int31n(100)
	}()
	return r // return r as a future
}
func sumSquares(a, b int32) int32 {
	return a*a + b*b
}
func main() {
	rand.Seed(time.Now().UnixNano())
	a, b := longTimeRequest(), longTimeRequest()
	fmt.Println(sumSquares(&lt;-a, &lt;-b))
}
示例2：传递一个send-only channel，通过它来提交计算任务，来模拟promise。
// Channel r is viewed as a promise by this function.
func longTimeRequest(r chan&lt;- int32)  {
	time.Sleep(time.Second * 3)
	r &lt;- rand.Int31n(100)
}
func sumSquares(a, b int32) int32 {
	return a*a + b*b
}
func main() {
	rand.Seed(time.Now().UnixNano())
	ra, rb := make(chan int32), make(chan int32)
	go longTimeRequest(ra)
	go longTimeRequest(rb)
	fmt.Println(sumSquares(&lt;-ra, &lt;-rb))
}
通过receive-only channel模拟future的时候，摄像这样一种情景，要获取一个用户数据，这个数据有10个数据源可以用于获取，但是响应速度、可靠性可能不一样，假如我们希望同时请求这10个数据源，但是只要响应速度最快的数据到达后就忽略掉后续的响应，怎么做到呢？
可以创建一个1个buffer，capacity可以设为10-1=9，为啥？先考虑设为10的情况吧，因为假如10个数据源都有响应，那就会写10次channel，假如capacity=1，那么后续channel写操作就会阻塞，协程就会阻塞，gc无法回收这里阻塞的协程。设为10个肯定没问题了，那为什么要设为9呢？因为我们肯定是要获取第一个响应最快的数据了，肯定有一次channel read操作，所以为了不导致后续的9次写操作可以顺利执行，capacity=9就足够了。
下面是示例程序：
func source(c chan&lt;- int32) {
	ra, rb := rand.Int31(), rand.Intn(3) + 1
	time.Sleep(time.Duration(rb) * time.Second) // sleep 1s, 2s or 3s
	c &lt;- ra
}
func main() {
	rand.Seed(time.Now().UnixNano())
	startTime := time.Now()
	c := make(chan int32, 5) // need a buffered channel
	for i := 0; i &lt; cap(c); i++ {
		go source(c)
	}
	rnd := &lt;- c // only the first response is used
	fmt.Println(time.Since(startTime))
	fmt.Println(rnd)
}
上面这个示例也是讲channel用作future、promise的一种变体，当然还有其他更多的变体形式，这里就先总结到这里。"
    - Use channels for notifications
"通知可以被看做是特殊的request-response pattern，对于将channel用作发送、接收通知的通道这种方式。通常情况下可以使用struct{}作为channel中的元素，因为struct{}的size是0，不占用内存空间。
1 通过发送1个值到1个channel实现1对1通知
如果从一个chan中接收数据，但是chan中没有数据，那么发起接收操作的goroutine就会阻塞，这个时候另一个goroutine给这个chan发送一个数据就可以将之前阻塞的goroutine给唤醒，达到发送通知的目的。
下面是一个示例：
func main() {
	values := make([]byte, 32 * 1024 * 1024)
	if _, err := rand.Read(values); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	done := make(chan struct{})
	go func() { // the sorting goroutine
		sort.Slice(values, func(i, j int) bool {
			return values[i] &lt; values[j]
		})
		done &lt;- struct{}{} // notify sorting is done
	}()
	// do some other things ...
	&lt;- done // waiting here for notification
	fmt.Println(values[0], values[len(values)-1])
}
2 通过从1个channel接收1个值实现1对1通知
与1类似的道理，当向chan中写数据时，如果chan的value buffer满了就写不进去，发起写操作的goroutine会阻塞，这个时候如果另一个goroutine从这个chan中读走数据使得value buffer不满那么之前因为写操作阻塞的goroutine就可以被唤醒了。通过这种接收数据的方式也可以实现通知的目的，但是和1中主动去发送一个“信号”来通知唤醒相比，还是1这种方式用的多，比较好理解。
下面是一个示例：
func main() {
	done := make(chan struct{}, 1) // the signal channel
	done &lt;- struct{}{}             // fill the channel
	// Now the channel done is full. A new send will block.
	go func() {
		fmt.Print("Hello")
		time.Sleep(time.Second * 2) // simulate a workload
		&lt;- done // receive a value from the done channel, to
		        // unblock the second send in main goroutine.
	}()
	// do some other things ...
	done &lt;- struct{}{} // block here until a receive is made.
	fmt.Println(" world!")
}
3 扩展为N对1、1对N通知
通过向chan中发送多个“通知信号”就可以起到类似N对1、1对N的通知效果了。
示例代码如下：
func worker(id int, ready &lt;-chan struct{}, done chan&lt;- struct{}) {
	&lt;-ready // wait until ready is closed
	log.Print("Worker#", id, " started to process.")
	time.Sleep(time.Second) // simulate a workload
	log.Print("Worker#", id, " finished its job.")
	done &lt;- struct{}{} // notify the main goroutine (N-to-1)
}
func main() {
	log.SetFlags(0)
	ready, done := make(chan struct{}), make(chan struct{})
	go worker(0, ready, done)
	go worker(1, ready, done)
	go worker(2, ready, done)
	time.Sleep(time.Second * 2) // simulate an initialzation phase
	// 1-to-N notifications.
	ready &lt;- struct{}{}; ready &lt;- struct{}{}; ready &lt;- struct{}{}
	// Being N-to-1 notified.
	&lt;-done; &lt;-done; &lt;-done
}
4 通过关闭一个channel实现1对N广播能力
如果一个chan本来没数据，那么发起chan读取操作的goroutine将会阻塞，但是如果有一个goroutine将这个chan close掉了，那么该chan将变得立即可读，所有之前因为读操作阻塞的goroutine都将被唤醒，读取到的值是0，closedBeforeSent为false。
通过这种方式可以实现1对N的广播能力，当然也可以实现1对1通知。
示例代码如下，将上述3中的代码稍作修改即可：
...
	// ready &lt;- struct{}{}; ready &lt;- struct{}{}; ready &lt;- struct{}{}
	close(ready) // broadcast notifications
...
5 使用同一个channel通知多次
这个非常容易理解，将一个chan当做通知的信道，每往里面发送一个”信号“就相当于一次通知操作，从该chan上读取”信号“的goroutine每收到一个chan都相当于被通知了一次。
这个比较简单就不提供示例代码了。
6 Timer：实现定时调度能力
结合time.Sleep(...)和chan的通知能力，我们可以实现定时调度的能力。
示例代码如下：
func AfterDuration(d time.Duration) &lt;- chan struct{} {
	c := make(chan struct{}, 1)
	go func() {
		time.Sleep(d)
		c &lt;- struct{}{}
	}()
	return c
}
func main() {
	fmt.Println("Hi!")
	&lt;- AfterDuration(time.Second)
	fmt.Println("Hello!")
	&lt;- AfterDuration(time.Second)
	fmt.Println("Bye!")
}"
    - Use channels as mutex locks
"将channel用作mutex locks，这个很好理解，我们可以创建一个capacity=1的chan，然后可以约定chan send、receive操作对应的加解锁操作。
有两种方式：
- 初始时chan里面有数据，chan recv对应着lock，chan send对应着unlock；
- 初始时chan里面没数据，chan send对应着lock，chan recv对应着unlock；
这两种方式都可以，可以实现一个互斥量，但是这种方式没有sync包里面提供的mutex高效。
示例代码如下：
func main() {
	mutex := make(chan struct{}, 1) // the capacity must be one
	counter := 0
	increase := func() {
		mutex &lt;- struct{}{} // lock
		counter++
		&lt;-mutex // unlock
	}
	increase1000 := func(done chan&lt;- struct{}) {
		for i := 0; i &lt; 1000; i++ {
			increase()
		}
		done &lt;- struct{}{}
	}
	done := make(chan struct{})
	go increase1000(done)
	go increase1000(done)
	&lt;-done; &lt;-done
	fmt.Println(counter) // 2000
}"
    - Use channels as counting semaphores
"将channel用作计数信号量，buffered chan如果capacity=1可以模拟出互斥量，当capacity&gt;1的时候还可以支持模拟计数信号量。如果capacity=N那么表示最多有N把锁可供获取。
计数信号量也是比较有用的，例如用来限制吞吐量来保证资源配额。
类似上面模拟互斥量的方式，chan的发送、接收可以根据chan初始情况下有误数据来将其映射为lock、unlock操作：
- chan初始状态数据空，lock对应着chan send，unlock对应着chan recv；
- chan初始状态数据满，lock对应着chan recv，unlock对应着chan send；
下面模拟一个酒吧中有N把椅子，顾客来了之后坐一把椅子然后离开时椅子由占用状态变为未占用。示例代码如下：
type Seat int
type Bar chan Seat
func (bar Bar) ServeConsumer(customerId int) {
	log.Print("-&gt; consumer#", customerId, " enters the bar")
	seat := &lt;- bar // need a seat to drink
	log.Print("consumer#", customerId, " drinks at seat#", seat)
	time.Sleep(time.Second * time.Duration(2 + rand.Intn(6)))
	log.Print("&lt;- consumer#", customerId, " frees seat#", seat)
	bar &lt;- seat // free the seat and leave the bar
}
func main() {
	rand.Seed(time.Now().UnixNano())
	bar24x7 := make(Bar, 10) // the bar has 10 seats
	// Place seats in an bar.
	for seatId := 0; seatId &lt; cap(bar24x7); seatId++ {
		bar24x7 &lt;- Seat(seatId) // none of the sends will block
	}
	for customerId := 0; ; customerId++ {
		time.Sleep(time.Second)
		go bar24x7.ServeConsumer(customerId)
	}
	for {time.Sleep(time.Second)} // sleeping != blocking
}"
    - Ping-Pong Dialogue
"两个goroutine之间有时需要来回地传递数据、消息、通信，有点像打乒乓球一来一回，或者说两个goroutine好像在对话一样。
下面给出了一个示例程序，打印fibonacci数列：
type Ball uint64
func Play(playerName string, table chan Ball) {
	var lastValue Ball = 1
	for {
		ball := &lt;- table // get the ball
		fmt.Println(playerName, ball)
		ball += lastValue
		if ball &lt; lastValue { // overflow
			os.Exit(0)
		}
		lastValue = ball
		table &lt;- ball // bat back the ball
		time.Sleep(time.Second)
	}
}
func main() {
	table := make(chan Ball)
	go func() {
		table &lt;- 1 // throw ball on table
	}()
	go Play("A:", table)
	Play("B:", table)
}"
    - channel encapsulated in channel
"可以创建一个channel，它的元素类型仍然是channel，如&lt;-chan chan&lt;- int，这就创建了一个只读的channel，它的元素类型是一个可写的channel，这个可写的channel的元素类型是int。
这个很容易理解，就不提供示例代码了，读者可以自己写个测试程序验证一下。"
    - check length and capacity of channel
"检查channel的length或者capacity，对于channel的length可以通过函数len(...)来获取，对于capacity可以通过cap(...)来获取，但是都不常用。原因是因为，len即便获取了chan的长度，可能chan操作又迅速改变了真实长度，cap一般是在chan定义的时候就给出的所以也没什么必要。
但是确实存在一些场景，需要用到这两个函数len、cap来对chan的长度、容量做检查。
例如，我们通过某种方式知道了不会再有chan写操作，而我们希望将chan中已有的数据全部取出来，我们当然可以使用for-range，但是for-range需要检查sentBeforeClosed，每次遍历都需要多一次变量拷贝，可以这样用：
for len(c) &gt; 0 {
	value := &lt;-c
	// use value ...
}
或者也可以使用后面将介绍的select-case中的try-receive机制来实现。
另一种情况，一个goroutine可能希望将一个channel（记为ch）写满而又不想引起goroutine阻塞。当chan中的数据写满len(ch)==cap(ch)的时候如果还执行写操作就会阻塞，为此可以这么使用：
for len(c) &lt; cap(c) {
	c &lt;- aValue
}"
    - Block the current goroutine forever
"如何永久阻塞一个goroutine？select{}，虽然也有其他写法，但是这个无疑是最简单的形式了！
select-case使得我们可以同时对多个chan进行操作，极大地丰富了并发编程能力，一个空的select{}没有任何分支，它会永远阻塞当前goroutine，通常j将其用于阻止main goroutine退出，因为main goroutine退出整个程序就会退出了。
func DoSomething() {
	for {
		// do something ...
		time.Sleep(time.Hour) // sleeping is not blocking
	}
}
func main() {
	go DoSomething()
	select{}
}"
    - Try-Send and Try-Receive
"select-case中如果只包括一个case分支和一个default分支，这种被称为try-send操作或者try-receive操作，具体要看case里面是chan的send操作还是receive操作。
try-send或者try-receive操作永远不会阻塞goroutine，因为如果case分支中的chan操作没有完成，那么会立即执行default分支。
golang编译器对这种try-send、try-receive操作进行了特殊优化，它比拥有多个case分支的switch-case的执行效率要高的多。
下面是一个示例代码：
func main() {
	type Book struct{id int}
	bookshelf := make(chan Book, 3)
	for i := 0; i &lt; cap(bookshelf) * 2; i++ {
		select {
		case bookshelf &lt;- Book{id: i}:
			fmt.Println("succeed to put book", i)
		default:
			fmt.Println("failed to put book")
		}
	}
	for i := 0; i &lt; cap(bookshelf) * 2; i++ {
		select {
		case book := &lt;-bookshelf:
			fmt.Println("succeed to get book", <a target="_blank" rel="nofollow" class="link " href="http://book.id)" data-auto="true">book.id)</a>
		default:
			fmt.Println("failed to get book")
		}
	}
}

下面是对try-send、try-receive的其他使用案例。

1 有个unbuffered chan，不会有goroutine向它写数据，只会被关闭以实现通知功能。假如现在写个方法来检测这个chan是否被关闭了，而且要求不能阻塞goroutine。可以借用上面讲过的try-receive来实现。
示例代码如下：
func IsClosed(c chan T) bool {
	select {
	case &lt;-c:
		return true
	default:
	}
	return false
}

2 峰值限制（peak limiting）
前面有个模拟顾客到酒吧喝酒占座位的问题，这里当座位被坐满时，如果又有新顾客来，就应该告诉他到其他酒吧去。这里的座位数量存在一个上限，称为peak limiting（峰值限制）。
这里对前面的这个示例的代码进行了修改，如果分配座位失败的时候，不会阻塞当前goroutine让顾客等待，而是通知其去其他酒吧。
修改后代码如下所示：
...
	bar24x7 := make(Bar, 10) // can serve most 10 consumers
	for customerId := 0; ; customerId++ {
		time.Sleep(time.Second)
		consumer := Consumer{customerId}
		select {
		case bar24x7 &lt;- consumer: // try to enter the bar
			go bar24x7.ServeConsumer(consumer)
		default:
			log.Print("consumer#", customerId, " goes elsewhere")
		}
	}
...

3 前面有个示例模拟的是请求用户数据可能同时请求多个数据源，但是只需要最快响应的数据。前面实现的时候假如请求N个数据源，那么要求chan的capacity至少为N-1才不会导致goroutine阻塞。现在我们借用try-send操作做一下优化，这样capacity只要为1就可以。
修改后的示例代码如下：
func source(c chan&lt;- int32) {
	ra, rb := rand.Int31(), rand.Intn(3)+1
	time.Sleep(time.Duration(rb) * time.Second) // sleep 1s, 2s or 3s
	select {
	case c &lt;- ra:
	default:
	}
}
func main() {
	rand.Seed(time.Now().UnixNano())
	c := make(chan int32, 1) // the capacity should be at least 1
	for i := 0; i &lt; 5; i++ {
		go source(c)
	}
	rnd := &lt;-c // only the first response is used
	fmt.Println(rnd)
}

4 紧接上文这个案例，如果每个goroutine请求一个单独的数据源，且通过一个单独的channel来通知调用者数据是否返回，当这里channel数量不多时，比如只有两三个，那么使用select-case来检查哪个数据到达的最快也是可以的。
示例代码如下所示：
func source() &lt;-chan int32 {
	c := make(chan int32, 1) // must be a buffered channel
	go func() {
		ra, rb := rand.Int31(), rand.Intn(3)+1
		time.Sleep(time.Duration(rb) * time.Second)
		c &lt;- ra
	}()
	return c
}
func main() {
	rand.Seed(time.Now().UnixNano())
	var rnd int32
	select{
	case rnd = &lt;-source():
	case rnd = &lt;-source():
	case rnd = &lt;-source():
	}
	fmt.Println(rnd)
}

5 timeout控制
有时执行一个请求需要花费较长的时间，例如client请求server返回数据，可能需要花费一定时间就能返回，甚至是在指定的时间内根本没有返回数据，这种情况下，让client指定一个超时时间，在这个超时时间内如果server返回了数据则返回数据，如果没有则返回超时错误。这里的超时逻辑也可以借助channel的select-case操作来实现。
示例代码如下：
func requestWithTimeout(timeout time.Duration) (int, error) {
	c := make(chan int)
	go doRequest(c) // may need a long time to response
	select {
	case data := &lt;-c:
		return data, nil
	case &lt;-time.After(timeout):
		return 0, errors.New("timeout")
	}
}

6 实现一个ticker
可以借助一个buffered chan和try-send操作来实现一个ticker。
前面有基于channel实现过timer，这里又实现了ticker，二者的区别是什么呢？timer是类似于一个定时器，到了时间会触发且只触发一次，适合用来设定一次执行的任务；ticker类似于时钟，每隔一段时间就会触发一次，适合用来设定周期性执行的任务。
实现ticker的示例代码如下所示（当然了golang标准库里面有一个更高效的ticker实现，实际项目中药用标准库中的ticker实现）：
func Tick(d time.Duration) &lt;-chan struct{} {
	c := make(chan struct{}, 1) // the capacity should be exactly one
	go func() {
		for {
			time.Sleep(d)
			select {
			case c &lt;- struct{}{}:
			default:
			}
		}
	}()
	return c
}
func main() {
	t := time.Now()
	for range Tick(time.Second) {
		fmt.Println(time.Since(t))
	}
}

7 速率限制（rate limiting）
前面描述过峰值限制（peak limiting），峰值限制的是同时允许处理的最大请求数量；速率限制（rate limiting）限制的是单位时间内允许处理的请求数量。二者都是为了避免服务过载，但是关注的点略有不同，实际后台服务开发中，可以结合二者使用。
下面是一个实现速率限制的示例代码：
type Request interface{}
func handle(Request) {/* do something */}
const RateLimit = 10
const BurstLimit = 5 // 1 means bursts are not supported.
func handleRequests(requests &lt;-chan Request) {
	throttle := make(chan time.Time, BurstLimit)
	go func() {
		tick := time.NewTicker(time.Second / RateLimit)
		defer tick.Stop()
		for t := range tick.C {
			select {
			case throttle &lt;- t:
			default:
			}
		}
	}()
	for reqest := range requests {
		&lt;-throttle
		go handle(reqest)
	}
}

8 switch-case的分支禁用、开启
向一个nil channel写数据，或者从一个nil channel中读取数据，会导致goroutine阻塞，利用这个特性可以在switch-case中禁用或开启某个case分支。
下面基于这点，对上面生成fibonacci的示例（ping-pong）进行了改写。
示例代码如下所示：
type Ball uint8
func Play(playerName string, table chan Ball, serve bool) {
	var receive, send chan Ball
	if serve {
		receive, send = nil, table
	} else {
		receive, send = table, nil
	}
	var lastValue Ball = 1
	for {
		select {
		case send &lt;- lastValue:
		case value := &lt;- receive:
			fmt.Println(playerName, value)
			value += lastValue
			if value &lt; lastValue { // overflow
				os.Exit(0)
			}
			lastValue = value
		}
		receive, send = send, receive // switch on/off
		time.Sleep(time.Second)
	}
}
func main() {
	table := make(chan Ball)
	go Play("A:", table, false)
	Play("B:", table, true)
}

9 select-case块中的多个case分支在运行时是会做排序处理的，然后会依次检查各个case分支条件是否满足，如果之前有个case &lt;-c 分支，现在如果多写1个case &lt;-c分支，那么该分支就相当于增加了依次检查的机会，执行对应分之下代码的概率就增加了一倍。
示例代码如下：
func main() {
	foo, bar := make(chan struct{}), make(chan struct{})
	close(foo); close(bar) // for demo purpose
	x, y := 0.0, 0.0
	f := func(){x++}
	g := func(){y++}
	for i := 0; i &lt; 100000; i++ {
		select {
		case &lt;-foo: f()
		case &lt;-foo: f()
		case &lt;-bar: g()
		}
	}
	fmt.Println(x/y) // about 2
}

10 reflect pacakge也支持动态生成select-case块，reflect包里面也提供了TrySend、TryReceive方法实现只包括一个case分支外加一个default分支的select-case块。但是reflect包毕竟是在运行时才处理的，效率要比这种编译时就可以确定下来的select-case块效率低。"
    - Data Flow Manipulations
"这一部分介绍一些数据流操作示例，实践中存在很多数据流处理的场景，例如消息队列（发布、订阅），大数据处理（map、reduce）、负载均衡、作业拆分等等。
通常，一个数据流应用程序包括了很多模块，不同的模块负责拥有不同的职能，每一个模块可能都包括了一个worker组（这里的worker指的是goroutine），这些worker并发执行来处理模块任务。下面给出了实践中一个数据流系统通常包括的模块作业：
- data generation/collecting/loading
- data serving/saving
- data calculation/analyzation
- data validation/filtering
- data aggregation/division
- data composition/decomposition
- data duplication/proliferation
模块既可能从其他模块接收数据，也可能向其他模块输出数据。也就是说，模块既可以是数据的消费者也可以是数据的生产者。如果一个模块只从其他块接收数据，那这个模块是consumer-only模块；如果一个模块只向其他模块输出数据，那这个模块是producer-only模块。
很多模块组合在一起就构成了一个数据流系统。
下面将给出一些数据流模块worker实现，这些实现它们可能既不高效也不灵活，仅用于教学目的。

1 data generating/collecting/loading
对于数据流系统中的producer-only模块，它们会数据流并输出给其他模块，这里的数据流可能：
- 通过文件加载、数据库加载，或者网络爬虫；
- 通过数据采集收集各种各样的硬件指标；
- 通过随机数生成器；
- 其他；
这里我们使用一个随机数生成器来模拟一个producer-only模块，示例代码如下：
func RandomGenerator() &lt;-chan uint64 {
	c := make(chan uint64)
	go func() {
		rnds := make([]byte, 8)
		for {
			_, err := rand.Read(rnds)
			if err != nil {
				close(c)
			}
			c &lt;- binary.BigEndian.Uint64(rnds)
		}
	}()
	return c
}
一个data producer可能会经过一段时间后就停止数据生成，或者不停生成，或者周期性生成。

2 data aggregation
一个数据聚合模块将来自多个不同模块的数据流聚合到同一个数据流里面，处理的多个数据流实现相同类型的。
示例代码如下：
func Aggregator(inputs ...&lt;-chan uint64) &lt;-chan uint64 {
	output := make(chan uint64)
	for _, in := range inputs {
		in := in // this line is important
		go func() {
			for {
				x, ok := &lt;-in
				if ok {
					output &lt;- x
				} else {
					close(output)
				}
			}
		}()
	}
	return output
}

3 data division
一个数据拆分模块做的工作与data aggregation（数据汇总模块）干的活完全是相反的，它将同一个数据流拆分成多个不同的数据流。
示例代码如下：
func Divisor(input &lt;-chan uint64, outputs ...chan&lt;- uint64) {
	for _, out := range outputs {
		out := out // this line is important
		go func() {
			for {
				out &lt;- &lt;-input // &lt;=&gt; out &lt;- (&lt;-input)
			}
		}()
	}
}

4 data composition
数据组合类似于数据聚合，只不过处理的数据类型不是相同类型的，而数据聚合处理的数据类型是相同的。
下面是是个示例，将两个数据流中的数据加工一下，将分属于两个数据流的uint64数组计算得到一个新数字写入最终的数据流。
func Composor(inA &lt;-chan uint64, inB &lt;-chan uint64) &lt;-chan uint64 {
	output := make(chan uint64)
	go func() {
		for {
			a1, b, a2 := &lt;-inA, &lt;-inB, &lt;-inA
			output &lt;- a1 ^ b &amp; a2
		}
	}()
	return output
}

5 data decomposition
数据取消组合操作，与4中描述的数据组合操作是完全相反的操作。示例代码略。

6 data duplication/proliferation
数据复制（激增）操作，是将一个数据流中的数据复制一份，然后写到不同的数据流中。
下面是一个示例：
func Duplicator(in &lt;-chan uint64) (&lt;-chan uint64, &lt;-chan uint64) {
	outA, outB := make(chan uint64), make(chan uint64)
	go func() {
		for {
			x := &lt;-in
			outA &lt;- x
			outB &lt;- x
		}
	}()
	return outA, outB
}

7 data calculation/analyzation
数据计算模块、数据分析模块是将一种形式的数据流转换成另一种形式，然后输出到输出数据流。
这里的转换过程与具体的计算、分析任务息息相关。下面举个例子，将一个数据流中的数字bit求反，示例代码如下：
func Calculator(input &lt;-chan uint64) (&lt;-chan uint64) {
	output := make(chan uint64)
	go func() {
		for {
			x := &lt;-input
			output &lt;- ^x
		}
	}()
	return output
}

8 data validation/filtering
数据验证模块、数据过滤模块，是对数据流中的数据进行校验，将不符合条件的数据丢弃。
如下示例代码中将数据流中的不是素数的数字丢弃，示例代码如下：
func Filter(input &lt;-chan uint64) (&lt;-chan uint64) {
	output := make(chan uint64)
	go func() {
		bigInt := big.NewInt(0)
		for {
			x := &lt;-input
			bigInt.SetUint64(x)
			if bigInt.ProbablyPrime(1) {
				output &lt;- x
			}
		}
	}()
	return output
}

9 data serving/saving
数据serving、saving模块，往往是整个数据流系统中的最后一个模块。
下面这个示例只是打印出输入数据流中的数据，示例代码如下：
func Printer(input &lt;-chan uint64) {
	for {
		x, ok := &lt;-input
		if ok {
			fmt.Println(x)
		} else {
			return
		}
	}
}

10 data flow system assembling
将上述模块组装成一个完整的数据流系统，就是创建每个数据流模块的worker实例，并为每个worker实例指定输入流、输出流。
func main() {
	Printer(
		Filter(
			Calculator(
				RandomGenerator(),
			),
		),
	)
}
这样就构建了一个完整的数据流系统：RandomGenerator -&gt; Calculator -&gt; Filter -&gt; Printer，当然还可以组件出一个更加复杂拓扑结构的数据流系统，这里就不介绍了。"
  - Other Concurrency Synchronization Techniques - the sync standard package.
    - sync.WaitGroup
"sync.WaitGroup（类似于Java里面的CountDownLatch）用来等待所有的协程执行结束。

使用方式是：
wg := &amp;sync.WaitGroup{}
开启一个新的协程前，调用wg.Add(1)，协程退出阶段调用defer wg.Done()
等待上述协程执行结束调用wg.Wait()

sync.WaitGroup里面维护一个计数器，值大于等于0，当调用sync.Wait()时将当前协程阻塞，直到其他协程通过wg.Done()将计数器的值更新为0才会恢复该阻塞协程的执行。


看个示例程序吧：
func() {
	var wg sync.WaitGroup
	wg.Add(1)

	for i := 0; i &lt; N; i++ {
		i := i
		go func() {
			wg.Wait()
			fmt.Printf("values[%v]=%v \n", i, values[i])
		}()
	}

	// The loop is guaranteed to finish before
	// any above wg.Wait calls returns.
	for i := 0; i &lt; N; i++ {
		values[i] = 50 + rand.Int31n(50)
	}
	wg.Done() // will make a broadcast
}
"
    - sync.Once
"sync.Once的Do(funval)只会执行一次

看个示例程序吧：
func main() {
	log.SetFlags(0)
	
	x := 0
	doSomething := func() {
		x++
		log.Println("Hello")
	}
	
	var wg sync.WaitGroup
	var once sync.Once
	for i := 0; i &lt; 5; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<a target="_blank" rel="nofollow" class="link " href="http://once.Do(doSomething)" data-auto="true">once.Do(doSomething)</a>
			log.Println("world!")
		}()
	}
	
	wg.Wait()
	log.Println("x =", x) // x = 1
}
上面hello知会打印一次，但是world会打印5次，x=1。"
    - sync.Mutex & sync.RWMutex
"互斥锁、读写锁，二者都实现了sync.Locker接口，都实现了方法Lock()和UnLock()，但是读写锁还实现了RLock()和RUnLock()。
"
    - sync.Cond
"条件变量sync.Cond可以实现多个goroutine之间的高效通知，sync.Cond内部维护一个锁L sync.Locker，c.L通常是一个*sync.Mutex或*sync.RWMutex实现。sync.Cond内部除了一个L sync.Locker，还维护了一个goroutine等待队列，队列中的所有goroutine都是因为等待该条件变量上的通知而被阻塞的。sync.Cond包括3个方法Wait()、Signal()、Broadcast()，执行这任意一个操作之前，都必须先持有锁L，因为这三个操作都涉及到对条件变量内部goroutine等待队列的修改，因此需要上锁。

下面总结下3个方法执行的操作：
1) c.Wait()
- 将当前执行的goroutine加入到c中的goroutine等待队列中；
- 修改c完毕，执行c.L.UnLock()释放c.L；
- 当前goroutine暂停执行，等待被其他goroutine执行c.Signal()或者c.Broadcast()来唤醒当前goroutine，该goroutine被唤醒后会立即执行c.L.Lock()，然后返回；
注意第一步要修改goroutine等待队列，所以要求先持有锁c.L，如果没有持有锁的话，第二步释放锁会导致panic。

2) c.Signal()
- 从c的gorotine等待队列中取出一个goroutine恢复其执行；
- 释放锁c.L；
这个操作也涉及到对内部结构的修改，需要先持有锁，否则会panic。

3) c.Broadcast()
- 从c的goroutine等待队列中取出所有的goroutine恢复其执行；
- 释放锁c.L；
这个操作也涉及到对内部结构的修改，需要先持有锁，否则会panic。

大多数情况下c.Signal()和c.Broadcast()是在c.Wait()执行结束后才执行的，这种情况下协程a因为等待c而阻塞，协程b执行c.Signal()或者c.Broadcast()唤醒a是没有任何问题的，但是：
- 假如a在执行c.Wait()过程中刚刚释放锁c.L就收到了协程b的c.Signal()，协程b可能不会进入阻塞状态；
- 假如a在执行c.Wait()过程中刚刚释放锁c.L就收到了协程b的c.Broadcast()，协程b不会进入阻塞状态；

下面是一个sync.Cond的示例：
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
"
  - Atomic Operations - the sync/atomic standard package.
  - Memory Order Guarantees In Go
  - Some Common Concurrent Programming Mistakes




