# Channels

- Modern CPUs often have multiple cores, and some CPU cores support hyper-threading. In other words, modern CPUs can process multiple instruction pipelines simultaneously. To fully use the power of modern CPUs, we need to do concurrent programming in coding our programs.  [go101.org]

  > "现代处理器一般都是多核、支持超线程的处理器，通过并发变成可以更好的发挥现代处理器的计算能力。  1）并发，指的是宏观上并行，微观上串行；2）并行，指的是多个任务在同一时刻同时运行。  并发可以是发生在同一个程序中，或者一台机器上的不同程序中，甚至不同的计算节点上。我们这里所说的golang并发编程指的是单个程序中的并发。"

- Concurrent computations may share resources, generally memory resource.

  > "并发编程涉及到资源共享，例如内存资源，存在并发读写的情景，如果不通过同步措施来控制并发就很可能出现数据竞态（data race），导致并发的任务拿到不一致的数据。goroutine是golang里面提供的多种同步措施之一。"

- One suggestion (made by Rob Pike) for concurrent programming is don't (let goroutines) communicate by sharing memory, (let them) share memory by communicating (through channels). The channel mechanism is a result of this philosophy.  [go101.org]

  > "golang里面采用了类似CSP（通信串行处理）的设计哲学，即通过通信来共享内存，而不是通过共享内存来通信。这样可以很大程度上避免出现data race。"

- Along with transferring values, the ownerships of some values may be also transferred between goroutines.

  > "channel可以理解成一个fifo的队列，有的任务往里面写数据，有的任务从里面取数据。从逻辑视角来看，当一个任务将数据写到channel时就释放了对数据的所有权ownership，接收到数据的任务就拿到了数据的所有权。这只是逻辑视角来看，golang底层实现并不想Rust语言一言保证数据写入channel、离开channel时数据所有权的变更。但是我们在编程的时候可以模拟实现这种ownership的变更，如果我们这么写了那么就可以写出无data race的代码，如果不这么写就还是无法避免data race，也就是说channel可以“帮助”我们写data race free的代码，但是也无法避免我们写出错误的代码。"

- One problem of channels is, the experience of programming with channels is so enjoyable and fun that programmers often even prefer to use channels for the scenarios which channels are not best for.  [go101.org]

  > "golang提供了channel来进行并发控制，也提供了原始的一些基于mutex等的同步控制（sync/sync.atomic package下），每一种方式都有各自的适用场景，但是基于channel实现的并发更加清晰易懂，以至于在某些channel并不是最佳选择的情境下，也有很多开发者使用了channel来实现并发控制。"

- Channel types are composite types. Like array, slice and map, each channel type has an element type. All data to be sent to the channel must be values of the element type.  [go101.org]

  > "channel是一种组合类型，和array、slice、map一样其内部记录了要存储的元素的类型，channel分为双向、单向channel，要注意他们之间的转换关系。channel对应的零值是nil，通过make创建channel。"

- All channel types are comparable types.  From the article value parts, we know that non-nil channel values are multi-part values. After one channel value is assigned to another, the two channels share the same undrelying part(s). In other words, the two channels represent the same internal channel object. The result of comparing them is true  [go101.org]

  > "chan是可比较的类型，对于chan value，其包括direct value part和indirect value part，当把一个chan value赋值给另一个chan变量时，这两个chan将共享相同的内部存储，包括data buffer、recv goroutine queue，send goroutine queue等。因为内部成员都是可比较的，所以chan类型是可比较的。"

- Close the channel by using the following function call close(ch)  	where close is a built-in function. The argument of a close function call must be a channel value, and the channel value must not be a receive-only channel.  [go101.org]

  > "close(ch)这里的ch不能是一个recv only的单向channel，比如是可以send的才行，因为close定义的时候要求参数是chan&lt;-。"

- it can be viewed as a multi-valued 	expression and result a second optional untyped boolean value, 	which indicates whether or not the first result is sent 	before the channel is closed.  [go101.org]

  > "val, sentBeforeClosed := &lt;-ch，从chan中接收的时候可以返回多个值，表示val这个值是否是在chan被关闭之前发送到chan的。如果chan被关闭后会从chan中接收会一直返回val=0，sentBeforeClosed=false，我们就知道chan被关闭了，0其实是无效的。"

- Query the value buffer capacity of the channel 	by using the following function call cap(ch)  [go101.org]

  > "查看channel中data buffer的容量，cap(ch)。"

- Query the current number of values in the value buffer 	(or the length) 	of the channel by using the following function call len(ch)  [go101.org]

  > "查询channel的data buffer中现在有多少个元素。"

- All these operations are already synchronized, so no further synchronizations are needed to perform these operations. However, like most other operations in Go, channel value assignments are not synchronized. Similarly, assigning the received value to another value is also not synchronized, though any channel receive operation is synchronized.  [go101.org]

  > "chan上的close、cap、len、发送、接收操作都是包含了同步控制的，但是将一个chan value赋值给另一个chan变量并没有同步，同样的&lt;-ch这样接收到的一个元素值，赋值给另一个变量val := &lt;-ch这种操作也是没有同步的。 编程里面应避免多个goroutine收chan上的数据更新同一个全局变量的情况，良好的编程方式是不要在chan里面塞size太大的元素，考虑是否使用指针代替。"

- A Simple Summary Of Channel Operation Rules

  > "chan可以分为如下几种类型：nil chan、non-nil但是已经closed的chan，non-nil但是还未closed-chan，对他们可进行的操作如close、send、recv，在这3种不同类型的chan上表现是不同的。 
  > 1 close操作：nil chan会panic，non-nil &amp; closed chan会panic，只有non-nil &amp; non-closed chan才会正常关闭。 
  > 2 send操作：nil-chan会阻塞，non-nil &amp; closed chan会panic，只有non-nil &amp; non-closed chan才能发送成功（包括了等待发送、成功发送两种情况）。 
  > 3 recv操作：nil-chan会阻塞，non-nil &amp; closed chan永不阻塞，返回0值和sentbeforeclosed标记true，只有non-nil &amp; non-closed的chan才能接收数据（包括等待接收和接收成功两种情况）。"

- Sending a value to or receiving a value from a nil channel makes the current goroutine enter and stay in blocking state for ever.

  > "golang设计里面通过select-case来对chan上的读写就绪事件进行监听，但是select-case里面不能使用fallthrough，这个时候就有问题了，假如select-case里面有多个case分支，其中第一个分支是case &lt;-ch1，假如这个分支ch1被关闭了，那么这个分支将一直是ready的，其他case分支将永远无法执行到。
  > 如下所示：

  ```
  select {
  		case &lt;-ch1:
        	dosomething()
  		case &lt;-ch2:
         	dosomething()
  		case ch3&lt;-:
         	dosomething()
  }
  ```

  > 如何避免这种，如何在一个ch无用后禁用对应的case分支呢？将这个分支设置为nil就是一种解决方法。"

- To better understand channel types and values and to make the some explanations easier, knowing the rough internal structures of internal channel objects is very helpful. We can think each channel maintains three queues internally.

  > "理解channel类型的内部结构之后更容易理解channel的工作原理。
  > channel内部其实包括了3个队列：
  > 1 value buffer queue，这是一个环形队列，用于存储goroutine写进来的数据，该队列的size与创建channel时指定的capacity是相等的。如果环形队列满了，channel就处于full status，如果队列空了，channel就处于empty status。对于一个0-capacity的channel，常称为unbufferred channel，也是因为环形缓冲size为0无法存储数据，这种chan同时处于full和empty两种状态。
  > 2 等待接收goroutine queue，这个队列的是一个容量没有上限的链表实现的，里面存储的是等待从该channel上接收数据的goroutine，接收数据后要存储到的变量的地址也和goroutine一并进行记录。
  > 3 等待发送goroutine queue，这个队列也是一个容量没有上限的链表实现的，里面存储的都是等待向该channel上发送数据的goroutine，待发送数据的内存地址也和goroutine一并进行记录。"

- [Channel rule case A]: when a goroutine tries to receive a value from a not-closed non-nil channel, the goroutine first tries to acquire the lock accociated with the channel, then do the following steps until one condition is satisfied.

  > "chan操作规则1：当一个goroutine要从一个non-nil &amp; non-closed chan上接收数据时，goroutine首先会去获取chan上的锁，然后执行如下操作直到某个条件被满足：
  > 1）如果chan上的value buffer不空，这也意味着chan上的recv goroutine queue也一定是空的，该接收goroutine将从value buffer中unshift出一个value。这个时候，如果send goroutine队列不空的情况下，因为刚才value buffer中空出了一个位置，有位置可写，所以这个时候会从send goroutine queue中unshift出一个发送goroutine并让其恢复执行，让其执行把数据写入chan的操作，实际上是恢复该发送该goroutine执行，并把该发送goroutine要发送的数据push到value buffer中。然后呢，该接收goroutine也拿到了数据了，就继续执行。这种情景，channel的接收操作称为non-blocking操作。
  > 2）另一种情况，如果value buffer是空的，但是send goroutine queue不空，这种情况下，该chan一定是unbufferred chan，不然value buffer肯定有数据嘛，这个时候接收goroutine将从send goroutine queue中unshift出一个发送goroutine，并将该发送goroutine要发送的数据接收过来（两个goroutine一个有发送数据地址，一个有接收数据地址，拷贝过来就ok），然后这个取出的发送goroutine将恢复执行，这个接收goroutine也可以继续执行。这种情况下，chan接收操作也是non-blocking操作。
  > 3）另一种情况，如果value buffer和send goroutine queue都是空的，没有数据可接收，将把该接收goroutine push到chan的recv goroutine queue，该接收goroutine将转入blocking状态，什么时候恢复期执行呢，要等到有一个goroutine尝试向chan发送数据的时候了。这种场景下，chan接收操作是blocking操作。"

- [Channel rule case B]: when a goroutine tries to send a value to a not-closed non-nil channel, the goroutine first tries to acquire the lock accociated with the channel, then do the following steps until one step condition is satisfied.

  > "当一个goroutine常识向一个non-nil &amp; non-closed chan发送数据的时候，该goroutine将先尝试获取chan上的锁，然后执行如下操作直到满足其中一种情况。
  > 1）如果chan的recv goroutine queue不空，这种情况下，value buffer一定是空的。发送goroutine将从recv goroutine queue中unshift出一个recv goroutine，然后直接将自己要发送的数据拷贝到该recv goroutine的接收地址处，然后恢复该recv goroutine的运行，当前发送goroutine也继续执行。这种情况下，chan send操作是non-blocking操作。
  > 2）如果chan的recv goroutine queue是空的，并且value buffer不满，这种情况下，send goroutine queue一定是空的，因为value buffer不满发送goroutine可以发送完成不可能会阻塞。该发送goroutine将要发送的数据push到value buffer中然后继续执行。这种情况下，chan send操作是non-blocking操作。
  > 3）如果chan的recv goroutine queue是空的，并且value buffer是满的，发送goroutine将被push到send goroutine queue中进入阻塞状态。等到有其他goroutine尝试从chan接收数据的时候才能将其唤醒恢复执行。这种情况下，chan send操作是blocking操作。"

- [Channel rule case C]: when a goroutine tries to close a not-closed non-nil channel, both of the following two steps will be performed by the following order.

  > "当一个goroutine尝试close一个non-nil &amp; non-closed chan的时候，close操作将依次执行如下操作。
  > 1）如果chan的recv goroutine queue不空，这种情况下value buffer一定是空的，因为如果value buffer如果不空，一定会继续unshift recv goroutine queue中的goroutine接收数据，直到value buffer为空（这里可以看下chan send操作，chan send写入数据之前，一定会从recv goroutine queue中unshift出一个recv goroutine）。recv goroutine queue里面所有的goroutine将一个个unshift出来并返回一个val=0值和sentBeforeClosed=false。
  > 2）如果chan的send goroutine queue不空，所有的goroutine将被依次取出并生成一个panic for closing a close chan。在这close之前发送到chan的数据仍然在chan的value buffer中存着。"

- [Channel rule case D]: after a channel is closed, channel receive operations on the channel will never block. The values in the the value buffer of the channel can still be received. Once all the values in the value buffer are taken out and received, infinite zero values of the element type of the channel will received by any of following receive operations on the channel. As above has mentioned, the second return result of a channel receive operation is an untype boolean value which indicates whether or not the first result (the received value) is sent before the channel is closed.

  > "一旦chan被关闭了，chan recv操作就永远也不会阻塞，chan的value buffer中在close之前写入的数据仍然存在。一旦value buffer中close之前写入的数据都被取出之后，后续的接收操作将会返回val=0和sentBeforeClosed=true。"

- Knowing what are blocking and non-blocking channel send or receive operations is important to understand the mechanism of select control flow blocks which will be introduced in a later section.

- In the above explanations, if a goroutine is unshifted out of a queue (either the sending goroutine queue or the receiving goroutine queue) of a channel, and the goroutine was blocked for being pushed into the queue at a select control flow code block, then the goroutine will be resumed to running state at the step9 of the select control flow code block execution. It may be dequeued from the corresponding goroutine queues of several goroutines involved in the the select control flow code block.

  > golang select-case实现机制
  >
  > 理解这里的goroutine的blocking、non-blocking操作对于理解针对chan的select-case操作是很有帮助的。
  > select-case中假如没有default分支的话，一定要等到某个case分支满足条件然后将对应的goroutine唤醒恢复执行才可以继续执行，否则代码就会阻塞在这里，即将当前goroutine push到各个case分支对应的ch的recv或者send goroutine queue中，对同一个chan也可能将当前goroutine同时push到recv、send goroutine queue这两个队列中。
  > 不管是普通的chan send、recv操作，还是select chan send、recv操作，因为chan操作阻塞的goroutine都是依靠其他goroutine队chan的send、recv操作来唤醒的。前面我们已经讲过了goroutine被唤醒的时机，这里还要再细分一下。
  > chan的send、recv goroutine queue中存储的其实是一个结构体指针*sudog，成员gp *g指向对应的goroutine，elem unsafe.Pointer指向待读写的变量地址，c *hchan指向goroutine阻塞在哪个chan上，isSelect为true表示select chan send、recv，反之表示chan send、recv。g.selectDone表示select操作是否处理完成，即是否有某个case分支已经成立。
  > 下面我们简单描述下chan上某个goroutine被唤醒时的处理逻辑，假如现在有个goroutine因为select chan 操作阻塞在了ch1、ch2上，那么会创建对应的sudog对象，并将对应的指针*sudog push到各个case分支对应的ch1、ch2上的send、recv goroutine queue中，等待其他协程执行(select) chan send、recv操作时将其唤醒：
  > 1）源码文件chan.go，假如现在有另外一个goroutine对ch1进行了操作，然后对ch1的goroutine执行unshift操作取出一个阻塞的goroutine，在unshift时要执行方法 func (q *waitq) dequeue() *sudog，这个方法从ch1的等待队列中返回一个阻塞的goroutine。

  ```
  func (q *waitq) dequeue() *sudog {
        for {
             sgp := q.first
             if sgp == nil {
                return nil
             }
             y := sgp.next
             if y == nil {
                 q.first = nil
                 q.last = nil
             } else {
                 y.prev = nil
                 q.first = y
                 sgp.next = nil // mark as removed (see dequeueSudog)
             }
             // if a goroutine was put on this queue because of a
             // select, there is a small window between the goroutine
             // being woken up by a different case and it grabbing the
             // channel locks. Once it has the lock
             // it removes itself from the queue, so we won't see it after that.
             // We use a flag in the G struct to tell us when someone
             // else has won the race to signal this goroutine but the goroutine
             // hasn't removed itself from the queue yet.
             if sgp.isSelect {
                if !atomic.Cas(&amp;sgp.g.selectDone, 0, 1) {
                    continue
                }
             }
             return sgp
        }
    }
  ```

  > 假如队首元素就是之前阻塞的goroutine，那么检测到其sgp.isSelect=true，就知道这是一个因为select chan send、recv阻塞的goroutine，然后通过CAS操作将sgp.g.selectDone设为true标识当前goroutine的select操作已经处理完成，之后就可以将该goroutine返回用于从value buffer读或者向value buffer写数据了，或者直接与唤醒它的goroutine交换数据，然后该阻塞的goroutine就可以恢复执行了。
  > 这里将sgp.g.selectDone设为true，相当于传达了该sgp.g已经从刚才阻塞它的select-case块中退出了，对应的select-case块可以作废了。有必要提提一下为什么要把这里的sgp.g.selectDone设为true呢？直接将该goroutine出队不就完了吗？不行！考虑以下对chan的操作dequeue是需要先拿到chan上的lock的，但是在尝试lock chan之前有可能同时有多个case分支对应的chan准备就绪。看个示例代码：

```
    // g1
    go func() {
      ch1 &lt;- 1 }()
    // g2
    go func() {
      ch2 &lt;- 2
    }
    select {
      case &lt;- ch1:
        doSomething()
      case &lt;- ch2:
        doSomething()
    }
```

> 协程g1在 chan.chansend方法中执行了一般，准备lock ch1，协程g2也执行了一半，也准备lock ch2;
>
> > 协程g1成功lock ch1执行dequeue操作，协程g2页成功lock ch2执行dequeue操作；
> >
> > > 因为同一个select-case块中只能有一个case分支允许激活，所以在协程g里面加了个成员g.selectDone来标识该协程对应的select-case是否已经成功执行结束（一个协程在某个时刻只可能有一个select-case块在处理，要么阻塞没执行完，要么立即执行完），因此dequeue时要通过CAS操作来更新g.selectDone的值，更新成功者完成出队操作激活case分支，CAS失败的则认为该select-case已经有其他分支被激活，当前case分支作废，select-case结束。
> > > 源文件select.go中方法 selectgo(sel *hselect) ，实现了对select-case块的处理逻辑，但是由于代码篇幅较长，这里不再复制粘贴代码，感兴趣的可以自己查看，这里只简要描述下其执行流程。
> > > selectgo逻辑处理简述：
> > > 0）预处理部分，对各个case分支按照ch地址排序，保证后续按序加锁，避免产生死锁问题；
> > > 1）pass 1部分处理各个case分支的判断逻辑，依次检查各个case分支是否有立即可满足ch读写操作的。如果当前分支有则立即执行ch读写并回，select处理结束；没有则继续处理下一分支；如果所有分支均不满足继续执行以下流程。
> > > 2）没有一个case分支上chan操作立即可就绪，当前goroutine需要阻塞，遍历所有的case分支，分别构建goroutine对应的sudog并push到case分支对应chan的对应goroutine queue中。然后gopark挂起当前goroutine，等待某个分支上chan操作完成来唤醒当前goroutine。怎么被唤醒呢？前面提到了chan.waitq.dequeue()方法中通过CAS将sudog.g.selectDone设为1之后将该sudog返回并恢复执行，其实也就是借助这个操作来唤醒。
> > > 3）整个select-case块已经结束使命，之前阻塞的goroutine已被唤醒，其他case分支没什么作用了，需要废弃掉，pass 3部分会将该goroutine从之前阻塞它的select-case块中各case分支对应的chan recv、send goroutine queue中移除，通过方法chan.waitq.dequeueSudog(sgp *sudog)来从队列中移除，队列是双向链表，通过sudog.prev和sudog.next删除sudog时间复杂度为O(1)。

- Channel Element Values Are Transferred By Copy

  > "从一个goroutine向另一个goroutine借助chan传数据，涉及到数据的两次拷贝操作，value的direct part将被拷贝。
  > 这里value或者chan中元素的size不能超过65536字节，这是gc的硬性规定，因为chan send、recv实际上都涉及到值的拷贝，为了性能也不应该传递size特别大的元素，如果size比较大可以考虑传递指针。"

- About Channel And Goroutine Garbage Collections

  > "什么时候才会垃圾回收器才会回收chan呢？当这个chan的send、recv goroutine queue不为空的时候，表示还有goroutine在等待该chan上的读写操作完成，说明这个chan还在被引用，这个时候垃圾回收器不会回收这里的chan。当没有goroutine还在引用这个chan的时候这个chan才会被回收。
  > goroutine的回收只有在它执行结束之后才会被回收。"

- select-case Control Flow Code Blocks features

  > "select-case的一些点：
  >
  > - 与switch-case不同，select后面不允许有表达式；
  > - 不允许在case分支中使用fallthrough；
  > - 每个case分支都只能是chan send或者chan recv操作；
  > - 如果有多个case分支读写就绪，那么将随机选择一个case分支执行（其实是CAS操作抢锁成功的一个分支执行，可参考上面的解析加以理解）。当前协程也会从其他各个分支的recv、send goroutine queue中移除。
  > - 如果没有case分支就绪，且提供了default分支，那么僵执行default分支；如果没有default分支，将把当前goroutine push到各个分支的recv、send goroutine queue中，当前goroutine进入blocking状态；
  > - 如果是select {}将会使当前协程永久阻塞；"

- The Implementation Of The Select Mechanism

  > select-case实现机制总结，这里的总结比较精炼，我上面的分析则更加侧重关键逻辑。这里还描述了对各个case分支channel排序以及加解锁的过程，该过程保证多个协程按序加解锁，避免产生死锁问题。详细执行流程如下:
  > 1 evaluate all involved channels and values to be potentially sent, from top to bottom and left to right.
  > 2 randomize the case orders for polling (the default branch is treated as a special case). The corresponding channels of the orders may be duplicate. The default branch is always put at the last position.
  > 3 sort all involved channels to avoid deadlock in the next step. No duplicate channels are in the first&nbsp;Nchannels of the sorted result, where&nbsp;N&nbsp;is the number of involved channels in the select block. Below,<span class="text-italic text-bold">the sorted lock order</span>&nbsp;mean for the the first&nbsp;N&nbsp;ones.
  > 4 lock all involved channels by the sorted lock order in last step.
  > 5 poll each cases in the select block by the randomized case orders:
  > 1)if the corresponding channel operation is a send-value-to-closed-channel operation, unlock all channels and panic. Go to step 12.
  > 2)if the corresponding channel operation is non-blocked, perform the channel operation and unlock all channels, then execute the corresponding&nbsp;case&nbsp;branch body. 
  > 3)The channel operation may wake up another blocked goroutine. Go to step 12.
  > 4)if the case is the default branch, then unlock all channels and execute the default body. Go to step 12.
  > 5 (Up to here, there must be not a default branch and all case channel operations are blocked.)
  > 6 push (enqueue) the current goroutine (with the case channel operation information) into the receiving or sending goroutine queue of the involved channel in each case operation. The current goroutine may be pushed into the queues of a channel multiple times, for the involved channels in multiple cases may be the same one.
  > 7 block the current goroutine and unlock all channels by the sorted lock order.
  > 8 …, in blocking state, waiting other channel operations to wake up the current goroutine, ...
  > 9 the current goroutine is waken up by another channel operation in another goroutine. The other operation may be a channel close operation or a channel send/receive operation. If it is a channel send/receive operation, there must be a case channel receive/send operation cooperating with it. In the cooperation, the current goroutine will be dequeued from the receiving/sending goroutine queue of the channel.
  > 10 lock all involved channels by the sorted lock order.
  > 11 dequeue the current goroutine from the receiving goroutine queue or sending goroutine queue of the involved channel in each case operation,
  > 1)if the current goroutine is waken up by a channel close operation, go to step 5.
  > 2)if the current goroutine is waken up by a channel send/receive operation, the corresponding case of the cooperating receive/send operation has already been found in the dequeuing process, so just unlock all channels by the sorted lock order and execute the corresponding case body.
  > 12 done