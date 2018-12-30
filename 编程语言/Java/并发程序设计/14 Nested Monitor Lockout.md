大家对DeadLock的原因应该都比较清楚了，造成DeadLock的常见原因就是多个线程没有按照相同顺序加锁，如线程1、2按照相反顺序加锁，如线程1先lock A、B、C、D，而线程2则lock D、C、B、A。我们也讲到了一些避免死锁的手段，其中就包括了Lock Ordering（按照相同的顺序加锁）。

现在考虑下，如果保证加锁顺序相同的前提下，多线程编程是否一定能够避免死锁呢？这就是本文要讨论的内容“**Nested Monitor Lockout**”，即嵌套monitor锁定。当出现嵌套monitor锁定时，程序也会表现出DeadLock类似的行为，线程无法获得锁、挂起。

# 认识“Nested Monitor Lockout”

结合下面这个Lock实现，我们来认识下Nested Monitor Lockout这个问题是什么（Lockout，表示加锁失败）。

```java
//lock implementation with nested monitor lockout problem  
public class Lock{
	protected MonitorObject monitorObject = new MonitorObject();
	protected boolean isLocked = false;
	
	public void lock() throws InterruptedException{
		synchronized(this){
			while(isLocked){
				synchronized(this.monitorObject){
					this.monitorObject.wait();
				}
			}
			isLocked = true;
		}
	}
	
	public void unlock(){
		synchronized(this){
			this.isLocked = false;
			synchronized(this.monitorObject){
				this.monitorObject.notify();
			}
		}
	}
}
```

先看下lock()的实现，它首先synchronized on this，然后再synchronized on this.monitorObject，如果isLocked是false，那么就没有问题，成功加锁。如果isLocked是true，线程将会通过调用this.monitorObject.wait()来挂起。

问题是，调用monitorObject.wait()的线程只释放了monitorObject上的monitor，而没有释放this的monitor。synchronized(obj)其实是持有了obj的monitor，而不是“锁”。换言之，线程调用lock()方法阻塞后并没有释a放this上的monitor，这将导致其他线程无法lock、unlock()，因为他们都必须先获取this上的monitor。

> monitor与lock的区别是什么？Java中每个Object都有一个关联的monitor，当我们synchronized(obj)时，这里的obj为任意对象，synchronized操作将会使得线程尝试获取obj关联的monitor上的锁。

假如有两个线程1、2，线程1尝试lock.Lock()成功，这个时候假如线程2也来尝试lock.Lock()这个时候失败，并且会阻塞在synchronzied(lock.monitorObject)上。线程2肯定是等待线程1来唤醒的，这个时候线程1尝试调用lock.unlock()方法，确发现线程1虽然当前是wait在lock.monitorObject上，但是与之关联的this上的锁线程1并没有释放，导致线程2执行synchronized(lock)时也会阻塞，导致无法成功释放锁。

简言之，因为lock而阻塞的线程需要另一个线程通过unlock()操作来唤醒它，但是，没有线程能够执行unlock()方法除非lock()阻塞的线程先退出。最终结果就是任何线程都不能再调用lock()或者unlock()，所有调用这些方法的都会阻塞。

这就是Nested Monitor Lockout，虽然上述示例中两个线程的的加锁顺序虽然是一致的，都是先synchronized(this)再synchronized(this.monitorObject)，但是却仍然会表现出DeadLock一样的问题。

# 再看一个更现实的例子

可能大家会说，我们几乎不会亲自自己去实现一个锁，我们即便是自己实现，可能也不会在一个对象关联的monitor上调用wait()或者notify()。尽管如此，问题是确实存在的，而且不能保证我们不会去实现一个锁。某些场景下，可能我们会设计出类似的锁，例如，如果我们要实现一个自定义的公平锁，我们要控制“公平”的判定规则，那就要自己去实现每次调用wait阻塞&记录调用线程，并在调用notify的时候选择一个阻塞的线程去唤醒。

来看下这个公平锁实现：

```java
//Fair Lock implementation with nested monitor lockout problem
public class FairLock {
    
    private boolean isLocked = false;
    private Thread lockingThread = null;
    private List < QueueObject > waitingThreads = new ArrayList < QueueObject > ();
    
    public void lock() throws InterruptedException {
        QueueObject queueObject = new QueueObject();
        synchronized(this) {
            waitingThreads.add(queueObject);
            // locked by others, or there's another thread trying lock() earlier
            while (isLocked || waitingThreads.get(0) != queueObject) {
                synchronized(queueObject) {
                    try {
                        queueObject.wait();
                    } catch (InterruptedException e) {
                        waitingThreads.remove(queueObject);
                        throw e;
                    }
                }
            }
            waitingThreads.remove(queueObject);
            isLocked = true;
            lockingThread = Thread.currentThread();
        }
    }
    public synchronized void unlock() {
        if (this.lockingThread != Thread.currentThread()) {
            throw new IllegalMonitorStateException("Calling thread has not locked this lock");
        }
        isLocked = false;
        lockingThread = null;
        if (waitingThreads.size() > 0) {
            QueueObject queueObject = waitingThread.get(0);
            synchronized(queueObject) {
                queueObject.notify();
            }
        }
    }
}
public class QueueObject {}
```

乍一眼看上去这个公平锁实现好像是ok的，但是仔细一看，lock的时候在一个嵌套两层的synchronized block里面竟然调用的是queueObject.wait()方法。外层的synchronized on this，内层的synchronized on queueObject局部变量。当一个线程调用queueObject.wait()的时候它释放了该局部变量的monitor锁，但是没有释放关联的this上的monitor锁。

还注意到，unlock方法也被声明为了synchronized方法，这类似于直接将方法体用synchronized(this)括起来，这意味着，如果一个线程尝试调用lock()而阻塞了，this上的monitor将不会被释放。其他已经lock()成功的线程如果再调用unlock()方法，该线程无法持有this上的monitor（因为被阻塞的线程霸占了）也就无法进入方法体执行唤醒逻辑。

与前面第一个示例类似地，这个公平锁实现也会导致Nested Monitor Lockout问题！在[Starvation和Fairness](http://tutorials.jenkov.com/java-concurrency/starvation-and-fairness.html)一节中有一个更加合理的公平锁实现，感兴趣的话可以参考一下。

# Nested Monitor Lockout 与 DeadLock

Nested Monitor Lockout与DeadLock会导致相同的问题：线程会因为彼此之间的相互等待而永远阻塞！

尽管它们引发的后果是相同的，但是这却是两个不能完全等同的问题：

- DeadLock，指的是当两个或者多个线程以不同的加锁顺序去申请加锁，线程之间可能会因为互相等待而无限阻塞。如线程1 lock A成功，等待lock B，线程2 lock B成功，等待lock A。
- Nested Monitor Lockout指的是两个或者多个线程以相同顺序加锁，但是其中一个线程1持有了某个锁的情况下，它还依赖一个通知来继续获取其他锁，但是能够发通知给1的线程又依赖线程1已经持有的锁。如线程1锁定了A，需要等待一个通知继续锁定B，但是线程2也需要锁定A、B之后才能通知线程1，但是A没有被线程1释放，线程2无限阻塞，线程1也无限阻塞。

在描述如何避免死锁问题时，有种办法就是保证所有线程以完全相同的加锁顺序去加锁，但是即便如此保证了加锁顺序相同，可能还会出现Nested Monitor Lockout问题，呵呵，不过Nested Monitor Lockout看起来更像是一个bug。



