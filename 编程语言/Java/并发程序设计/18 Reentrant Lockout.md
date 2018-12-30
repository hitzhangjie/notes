
Reentrant Lockout，重入锁失败。指的是某些锁不是可重入的，当一个线程已经持有了该对象上的锁之后，又试图进行再次的加锁操作，此时由于这些锁不是可重入的，就会lockout的问题，**lockout可以翻译为，被关在门外，被锁在门外**……总之就是申请加锁失败的意思，线程还会因此阻塞。

为了避免这个问题，可以采用如下两种方案：
- 采用可重入的锁；
- 对于不可重入的锁，不要试图重入这个锁；

下面是一个简单的描述，感兴趣的话，可以看一下，如果对锁的可重入问题已经理解的比较清楚了，可以跳过。

**Reentrance lockout** is a situation similar to [deadlock](http://tutorials.jenkov.com/java-concurrency/deadlock.html) and [nested monitor lockout](http://tutorials.jenkov.com/java-concurrency/nested-monitor-lockout.html). Reentrance lockout is also covered in part in the texts on [Locks](http://tutorials.jenkov.com/java-concurrency/locks.html) and [Read / Write Locks](http://tutorials.jenkov.com/java-concurrency/read-write-locks.html).
Reentrance lockout may occur if a thread reenters a [Lock](http://tutorials.jenkov.com/java-concurrency/locks.html), [ReadWriteLock](http://tutorials.jenkov.com/java-concurrency/read-write-locks.html) or some other synchronizer that is not reentrant. Reentrant means that a thread that already holds a lock can retake it. Java's synchronized blocks are reentrant. Therefore the following code will work without problems:

```java
public class Reentrant{
	public synchronized outer(){
		inner();
	}
	public synchronized inner(){
		//do something
	}
}
```

Notice how both outer() and inner() are declared synchronized, which in Java is equivalent to asynchronized(this) block. If a thread calls outer() there is no problem calling inner() from insideouter(), since both methods (or blocks) are synchronized on the same monitor object ("this"). If a thread already holds the lock on a monitor object, it has access to all blocks synchronized on the same monitor object. This is called reentrance. The thread can reenter any block of code for which it already holds the lock.
The following Lock implementation is not reentrant:

```java
public class Lock{
	private boolean isLocked = false;
	public synchronized void lock() throws InterruptedException{
		while(isLocked){
			wait();
		}
		isLocked = true;
	}
	public synchronized void unlock(){
		isLocked = false;
		notify();
	}
}
```

If a thread calls lock() twice without calling unlock() in between, the second call to lock() will block. A reentrance lockout has occurred.

To avoid reentrance lockouts you have two options:
- Avoid writing code that reenters locks
- Use reentrant locks

Which of these options suit your project best depends on your concrete situation. Reentrant locks often don't perform as well as non-reentrant locks, and they are harder to implement, but this may not necessary be a problem in your case. Whether or not your code is easier to implement with or without lock reentrance must be determined case by case.