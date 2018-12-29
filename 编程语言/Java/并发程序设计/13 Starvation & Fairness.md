**讲了线程饿死的原因，以及公平的实现。**

# Starvation & Fairness

- **Starvation**

  If a thread is not granted CPU time because other threads grab it all, it is called "starvation". The thread is "starved to death" because other threads are allowed the CPU time instead of it. 

- **Fairness**

  The solution to starvation is called "fairness" - that all threads are fairly granted a chance to execute.

# Causes of Starvation in Java

The following **three common causes** can lead to starvation of threads in Java:

- Threads with high priority swallow all CPU time from threads with lower priority.
- Threads are blocked indefinately waiting to enter a synchronized block, because other threads are constantly allowed access before it.
- Threads waiting on an object (called wait() on it) remain waiting indefinitely because other threads are constantly awakened instead of it.

下面进行详细描述。

## Thread Priority

**Threads with high priority swallow all CPU time from threads with lower priority**. You can set the thread priority of each thread individually. The higher the priority the more CPU time the thread is granted. You can set the priority of threads between 1 and 10. Exactly how this is interpreted depends on the operating system your application is running on. For most applications you are better off leaving the priority unchanged.

## Blocked on `synchronized{}`

**Threads are blocked indefinitely waiting to enter a synchronized block**. Java's synchronized code blocks can be another cause of starvation. Java's synchronized code block makes no guarantee about the sequence in which threads waiting to enter the synchronized block are allowed to enter. This means that there is a theoretical risk that a thread remains blocked forever trying to enter the block, because other threads are constantly granted access before it. This problem is called "starvation", that a thread is "starved to death" by because other threads are allowed the CPU time instead of it.

## Blocked on `wait()`

**Threads waiting on an object (called wait() on it) remain waiting indefinitely**. The notify() method makes no guarantee about what thread is awakened if multiple thread have called wait() on the object notify() is called on. It could be any of the threads waiting. Therefore there is a risk that a thread waiting on a certain object is never awakened because other waiting threads are always awakened instead of it.

> 需要了解的是，synchronized不是公平锁，而ReentrantLock是公平锁。

为了解决上述问题，我们希望能够实现一个公平的同步类。下面看看可以怎么做。

# Implementing Fairness in Java

While it is not possible to implement 100% fairness in Java we can still implement our synchronization constructs to increase fairness between threads.

## simple synchronized block

First lets study a simple synchronized code block:

```java
public class Synchronizer{
	public synchronized void doSynchronized(){
		//do a lot of work which takes a long time
	}
}
```

If more than one thread call the doSynchronized() method, some of them will be blocked until the first thread granted access has left the method. If more than one thread are blocked waiting for access there is no guarantee about which thread is granted access next.

## Using Locks, instead of synchronized

Using Locks Instead of Synchronized Blocks, to increase the fairness of waiting threads first we will change the code block to be guarded by a lock rather than a synchronized block:

```java
public class Synchronizer{   
	Lock lock = new Lock();
	public void doSynchronized() throws InterruptedException{
		this.lock.lock();
		//critical section, do a lot of work which takes a long time
		this.lock.unlock();
	}
}
```

Notice how the doSynchronized() method is no longer declared synchronized. Instead the critical section is guarded by the lock.lock() and lock.unlock() calls.

A simple implementation of the Lock class could look like this:

```java
public class Lock {   
	private boolean isLocked      = false;
	private Thread  lockingThread = null;
	public synchronized void lock() throws InterruptedException{
		while(isLocked){
			wait();
		}
		isLocked      = true;
		lockingThread = Thread.currentThread();
	}
	public synchronized void unlock(){
		if(this.lockingThread != Thread.currentThread()){
			throw new IllegalMonitorStateException("Calling thread has not locked this lock");
		}
		isLocked      = false;
		lockingThread = null;
		notify();
	}
}
```

If you look at the Synchronizer class above and look into this Lock implementation you will notice that threads are now blocked trying to access the lock() method, if more than one thread calls lock() simultanously. Second, if the lock is locked, the threads are blocked in the wait() call inside the while(isLocked) loop in the lock() method. Remember that a thread calling wait() releases the synchronization lock on the Lock instance, so threads waiting to enter lock() can now do so. The result is that multiple threads can end up having called wait() inside lock().

If you look back at the doSynchronized() method you will notice that the comment between lock() and unlock() states, that the code in between these two calls take a "long" time to execute. Let us further assume that this code takes long time to execute compared to entering the lock() method and calling wait() because the lock is locked. This means that the majority of the time waited to be able to lock the lock and enter the critical section is spent waiting in the wait() call inside the lock() method, not being blocked trying to enter the lock() method.

As stated earlier synchronized blocks makes no guarantees about what thread is being granted access if more than one thread is waiting to enter. Nor does wait() make any guarantees about what thread is awakened when notify() is called. So, the current version of the Lock class makes no different guarantees with respect to fairness than synchronized version of doSynchronized(). But we can change that.

The current version of the Lock class calls its own wait() method. If instead each thread calls wait() on a separate object, so that only one thread has called wait() on each object, the Lock class can decide which of these objects to call notify() on, thereby effectively selecting exactly what thread to awaken.

## A Fair Lock

**实现一个公平锁，所谓的公平锁，指的是线程获得锁的顺序，与线程申请加锁的顺序是一致的。即先申请加锁的线程，将优先于其他线程获得锁。**

将前面的一个锁Lock类实现，加以修改，使其变成公平锁FairLock。这个公平锁FairLock类中的synchronization以及wait、notify与之前Lock的实现中有所区别。

可以看到，我们设计公平锁的过程，是一个增量式的改进的过程，我们**依次解决了Nested Monitor Lock问题（可能引发死锁）、Slipped Condition问题（状态丢失问题，应将test、update作为一个原子操作）、信号丢失问题（可能引起后续进入waiting状态的线程永远无法被唤醒）**。这些问题的解决我们在前面都一一描述过了，这里就不再多说了。

来考虑一下这里的公平锁的实现，**每一个线程调用了lock操作之后，都会将其入队**，这个队列可以反映出该锁的线程申请顺序，当将锁交给某个线程时，我们只将锁交给申请队列中的第一个线程，即可以保证线程获得锁的顺序，与申请加锁的顺序是相同的。

看下面的实现：

**1）QueueObject**
- 这个类描述了一个申请加锁的线程，及其wait、notify操作；
- 通过isNotified变量，解决了信号丢失的问题；
- 另外每一个申请加锁的线程都是在不同的QueueObject实例上等待，便于后面唤醒指定的线程。

```java
public class QueueObject {
	private boolean isNotified = false;
	public synchronized void doWait() throws InterruptedException {
		while(!isNotified){
			this.wait();
		}
		this.isNotified = false;
	}
	public synchronized void doNotify() {
		this.isNotified = true;
		this.notify();
	}
	public boolean equals(Object o) {
		return this == o;
	}
}
```

**2）FairLock**
这个类即我们的公平锁；
每一个申请加锁的线程都用一个QueueObject进行描述；
申请加锁的线程按照申请顺序被依次放入队列waitingThreads中，当一个线程让度出了锁，我们即将队头的第一个QueueObject对象上等待的线程唤醒即可。

```java
public class FairLock {     
	private boolean           isLocked       = false;
	private Thread            lockingThread  = null;  // 该数组列表充当队列，记录了申请锁的线程     
	private List<QueueObject> waitingThreads = new ArrayList<QueueObject>();
	public void lock() throws InterruptedException{
		QueueObject queueObject           = new QueueObject();
		boolean     isLockedForThisThread = true;
		synchronized(this){         
			waitingThreads.add(queueObject);     
		}   
		while(isLockedForThisThread){       
			synchronized(this){
				isLockedForThisThread = isLocked || waitingThreads.get(0) != queueObject;      
				if(!isLockedForThisThread){           
					isLocked = true;            
					waitingThreads.remove(queueObject);            
					lockingThread = Thread.currentThread();            
					return;
				}
			}
			try{
				queueObject.doWait();
			}catch(InterruptedException e){
				synchronized(this) {
					waitingThreads.remove(queueObject);
				}
				throw e;
			}
		}
	}    
	public synchronized void unlock(){
		if(this.lockingThread != Thread.currentThread()){
			throw new IllegalMonitorStateException("Calling thread has not locked this lock");
		}
		isLocked      = false;
		lockingThread = null; 
		if(waitingThreads.size() > 0){
			waitingThreads.get(0).doNotify();
		}
	}
}
```

**3）A Note on Performance**
性能方面的考虑，公平锁中的lock操作和unlock操作考虑的东西比非公平锁中考虑的东西要更多，将FairLock实现与Lock实现做个对比，就可以看出来。
这些额外的操作，也会导致FairLock的效率不如普通的Lock效率高，但是总归是比synchronized这个重量级锁要好点的。