# Synchronizer介绍

synchronized、锁、信号量等，都属于Synchronizer（同步器），Synchronizer在并发场景中用来对临界资源进行保护，通常包括如下几个部分：

- State
- Access Condition
- State Changes
- Notification Strategy
- Test and Set Method
- Set Method

synchronized、锁、信号量，虽然字面上差异很大，但是其实现很相似，对这些相似之处进行归纳总结，有助于我们实现自己的同步器，有助于更好地设计、实现并发程序。

# State

Synchronizer的State（状态）会由Access Condition（访问条件）读取，并借此判断被Synchronizer保护的临界资源是否允许线程访问。

Synchronizer的状态可能保存在：
- 保存在**Lock**中，以一个boolean值来区分Lock是否被已被锁定；
- 保存在**Bounded Semaphore**中，状态保存一个int类型的计数器counter和int类型的计数上限bound中，来记录当前take的次数以及最大可take的次数；
- 保存在**Blocking Queue**中，状态保存在队列中的元素中，队列容量上限也要考虑在内。

下面是分别用Lock、BoundedSemaphore来记录state的示例：

```java
public class Lock{
	//state is kept here
	private boolean isLocked = false;
	public synchronized void lock()   throws InterruptedException{
		while(isLocked){
			wait();
		}
		isLocked = true;
	}
}

public class BoundedSemaphore {
	//state is kept here
	private int signals = 0;
	private int bound   = 0;
	public BoundedSemaphore(int upperBound){
		this.bound = upperBound;
	}
	public synchronized void take() throws InterruptedException{
		while(this.signals == bound)
			wait();
		this.signal++;
		this.notify();
	}
}
```

# Access Condition

Access Condition（访问条件）决定了一个线程是否允许执行test-and-set-state相关的操作。

这里的访问条件基于的Synchronizer的状态，通常在一个**while循环里面检查访问条件是否满足**，while中检查的目的是为了避免某些处理器下的**Spurious Wakeups**。

- 在**Lock**中，直接检查成员变量isLocked是否true就可以了;
- 在**Bounded Semaphore**中，根据是take操作还是release操作有两种不同的访问条件要检。如果线程执行take操作，要检查成员变量signals以及upper bound；如果线程执行release操作，要检查成员变量signals是否为0。

这里分别提供了一个通过Lock、BoundedSemaphore实现，来展示如何在while循环中检查状态是否满足。

```java
public class Lock{
	private boolean isLocked = false;
	public synchronized void lock()   throws InterruptedException{
		//access condition
		while(isLocked){
			wait();
		}
		isLocked = true;
	}
}

public class BoundedSemaphore {
	private int signals = 0;
	private int bound   = 0;
	public BoundedSemaphore(int upperBound){
		this.bound = upperBound;
	}
	public synchronized void take() throws InterruptedException{
		//access condition
		while(this.signals == bound)
			wait();
		this.signals++;
		this.notify();
	}
	public synchronized void release() throws InterruptedException{
		//access condition
		while(this.signals == 0)
			wait();
		this.signals--;
		this.notify();
	}
}
```

# State Changes

一旦某个线程成功进入了临界区，这个线程需要修改Synchronizer的状态来阻塞其他线程进入临界区。换言之，需要修改Synchronizer的状态来表名已经有线程进入了临界区，其他尝试进入临界区的线程必须等待。

- 在Lock中，状态改变就是isLocked修改为true或false；
- 在BoundedSemaphore中，状态就是修改signals—或者signals++；

这里是分别以Lock和BoundedSemaphore来修改状态的示例:

```java
public class Lock{
	private boolean isLocked = false;
	public synchronized void lock()   throws InterruptedException{
		while(isLocked){
			wait();
		}
		//state change
		isLocked = true;
	}
	public synchronized void unlock(){
		//state change
		isLocked = false;
		notify();
	}
}

public class BoundedSemaphore {
	private int signals = 0;
	private int bound   = 0;
	public BoundedSemaphore(int upperBound){
		this.bound = upperBound;
	}
	public synchronized void take() throws InterruptedException{
		while(this.signals == bound)
			wait();
		//state change
		this.signals++;
		this.notify();
	}
	public synchronized void release() throws InterruptedException{
		while(this.signals == 0)
		wait();
		//state change
		this.signals--;
		this.notify();
	}
}
```

# Notification Strategy

Once a thread has changed the state of a synchronizer it may sometimes need to notify other waiting threads about the state change. Perhaps this state change might turn the access condition true for other threads.

一旦线程修改了Synchronizer的内部状态它就应该将这个状态改变通知其他线程，因为可能有其他线程正在等待Synchronizer上的状态改变。这里的状态改变，可能使得其他Access Condition为false的变为true，所以需要及时通知其他线程状态改变。

Notification Strategies（通知策略）可以分为如下三类：
- 通知所有等待线程；
- 随机选择一个等待线程并通知；
- 选择特定一个等待线程并通知；

通知所有线程时非常简单的，线程在某个对象上调用wait()后就阻塞了，如果有一个线程想唤醒在该对象上等待的所有线程，直接在该对象上调用notifyAll()就可以了。

随机选择一个等待线程并通知也非常简单，直接在该等待对象上调用notify()即可。

有时需要通知一个指定的等待线程唤醒，而不是随机选择一个等待线程并通知。例如，如果需要按照特定的顺序来唤醒等待线程，如按照调用wait()的顺序来唤醒，或者按照线程优先级由高到低来唤醒……为了实现这个目的，需要自己实现wait()、notify()方法。

下面给出一个通知状态改变的实现示例：

```java
public class Lock{
	private boolean isLocked = false;
	public synchronized void lock()   throws InterruptedException{
		while(isLocked){
			//wait strategy - related to notification strategy
			wait();
		}
		isLocked = true;
	}
	public synchronized void unlock(){
		isLocked = false;
		notify();
		//notification strategy
	}
}
```

# Test and Set Method

Synchronizer most often have two types of methods of which test-and-set is the first type (set is the other). Test-and-set means that the thread calling this method tests the internal state of the synchronizer against the access condition. If the condition is met the thread sets the internal state of the synchronizer to reflect that the thread has gained access.

The state transition usually results in the access condition turning false for other threads trying to gain access, but may not always do so. For instance, in a Read - Write Lock a thread gaining read access will update the state of the read-write lock to reflect this, but other threads requesting read access will also be granted access as long as no threads has requested write access.

It is imperative that the test-and-set operations are executed atomically meaning no other threads are allowed to execute in the test-and-set method in between the test and the setting of the state.

The program flow of a test-and-set method is usually something along the lines of:

- Set state before test if necessary
- Test state against access condition
- If access condition is not met, wait
- If access condition is met, set state, and notify waiting threads if necessary

The lockWrite() method of a ReadWriteLock class shown below is an example of a test-and-set method. Threads calling lockWrite() first sets the state before the test (writeRequests++). Then it tests the internal state against the access condition in the canGrantWriteAccess() method. If the test succeeds the internal state is set again before the method is exited. Notice that this method does not notify waiting threads.

```java
public class ReadWriteLock{
	private Map<Thread, Integer> readingThreads =         new HashMap<Thread, Integer>();
	private int writeAccesses    = 0;
	private int writeRequests    = 0;
	private Thread writingThread = null;
	...
	public synchronized void lockWrite() throws InterruptedException{
		writeRequests++;
		Thread callingThread = Thread.currentThread();
		while(! canGrantWriteAccess(callingThread)){
			wait();
		}
		writeRequests--;
		writeAccesses++;
		writingThread = callingThread;
	}
	...
}
```

The BoundedSemaphore class shown below has two test-and-set methods: take() and release(). Both methods test and sets the internal state.

```java
public class BoundedSemaphore {
	private int signals = 0;
	private int bound   = 0;
	public BoundedSemaphore(int upperBound){
		this.bound = upperBound;
	}
	public synchronized void take() throws InterruptedException{
		while(this.signals == bound)
			wait();
		this.signals++;
		this.notify();
	}
	public synchronized void release() throws InterruptedException{
		while(this.signals == 0)
			wait();
		this.signals--;
		this.notify();
	}
}
```

# Set Method

The set method is the second type of method that synchronizers often contain. The set method just sets the internal state of the synchronizer without testing it first. A typical example of a set method is the unlock()method of a Lock class. A thread holding the lock can always unlock it without having to test if the Lock is unlocked.

The program flow of a set method is usually along the lines of:

- Set internal state
- Notify waiting threads

Here is an example unlock() method:

```java
public class Lock{
	private boolean isLocked = false;
	public synchronized void unlock(){
		isLocked = false;
		notify();
	}
}
```