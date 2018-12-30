A lock is a thread synchronization mechanism like synchronized blocks except locks can be more sophisticated than Java's synchronized blocks. Locks (and other more advanced synchronization mechanisms) are created using synchronized blocks, so it is not like we can get totally rid of the synchronized keyword.

From Java 5 the package java.util.concurrent.locks contains several lock implementations, so you may not have to implement your own locks. But you will still need to know how to use them, and it can still be useful to know the theory behind their implementation. For more details, see my tutorial on the[java.util.concurrent.locks.Lock](http://tutorials.jenkov.com/java-util-concurrent/lock.html) interface.

# A Simple Lock

我们从一个简单的java synchronized代码块开始，一步一步了解java中的锁。

```java
public class Counter{
	private int count = 0;
	public int inc(){
		synchronized(this){
			return ++count;
		}
	}
}
```

注意这里的inc方法中的同步块，一次只允许一个线程执行++count操作，其他线程都会被阻塞，这段同步代码可能还可以更加高效，例如通过AtomicInteger，其使用了更加“乐观”的同步策略，基于“硬件CAS+数据版本”实现，效率更高。但是这里++count比较简单，我们认为它已经很高效了。后面我们重点关注引入各种锁的原因，以及如何实现，不再纠结++count的性能问题。

我们可以使用一个简单Lock，用这个Lock而非synchronized代码块来实现计数器，看下面这个例子：

```java
public class Counter{
	private Lock lock = new Lock();
	private int count = 0;
	public int inc(){
		lock.lock();
		int newCount = ++count;
		lock.unlock();
		return newCount;
	}
}
```

lock()方法锁定了当前lock实例对象，这样其他调用lock()方法的线程会被阻塞，直到当前线程调用unlock操作。下面是一个简单的锁的实现：

```java
public class Lock{
	// 这里的isLocked状态变量可以防止Missed Signaling，
	// 这里还可以用于处理Spurious Wakeup问题。
	private boolean isLocked = false;
	public synchronized void lock()  throws InterruptedException{  
		// 使用while-loop代替if，以正确处理Spurious Wakeup
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

## lock()

注意我们在lock操作里面使用了一个while循环来判断isLocked的状态，为什么要用while，而不是wait？感觉if就足够用了啊！
在前面的Thread Signaling这里，我们提到过了，**在某些处理器上，偶尔会出现Spurious Wakeup（假唤醒）的情况，即没有其他线程调用notify操作，当前线程也没有收到通知信号的情况下，就会从waiting状态异常退出**。这种情况在某些处理器上会出现，为了兼容性，这里一定要用while循环代替if，这样线程不管是被正常唤醒，还是假唤醒，通过重新检查一遍isLocked的状态，可以知道自己是被正常唤醒还是被假唤醒。如果是假唤醒，则继续wait()，是正常唤醒则继续进行后续的加锁操作。

## unlock()

当线程执行完了临界区中的代码，将继续执行unlock操作，将状态变量isLocked设定为false，然后通知其他等待的线程。

# Lock Reentrance

java中的**synchronized代码块是可重入的**。意味着，如果一个线程进入了一个同步代码块，那么这个线程肯定获得了这个synchronized(obj)的obj这个monitor上的锁，假如再这个synchronized块内还有synchronized(obj)来同步控制，线程也是可以进入执行的。就是说synchronized施加在obj monitor上的锁是可重入锁。简单理解，可重入锁就是线程持有了一个锁A，重复申请锁A是可以申请成功的、不会阻塞的！

结合下面这个类来说，如果一个线程持有了Reentrant对象上的锁，那么就可以进入outer方法中执行，此时在outer内部调用了inner方法，由于该线程已经持有了该对象上的锁，因此可以直接进入synchronized修饰的inner方法继续执行。

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

通过前面的两个示例，我们可以看出，synchronized是使用的可重入锁，但是我们自己用synchronized实现的简单锁Lock类却不是可重入的。结合下面的代码进行说明，如果一个线程获得了lock上的锁，并且成功执行了outer操作，当继续执行inner操作的时候，将会加锁失败，因为之前的lock实现中，只要前面被锁定了后面申请加锁的线程就会被阻塞。

```java
public class Reentrant2{
	Lock lock = new Lock();
	public outer(){
		lock.lock();
		inner();
		lock.unlock();
	}
	public synchronized inner(){
		lock.lock();
		//do something
		lock.unlock();
	}
}
```

问题出在哪里呢？
- 在线程申请加锁的时候，判断条件中没有判断当前申请加锁的线程，是否是当前已经持有锁的线程；
- unlock的时候，没有判断申请释放锁的线程是否是当前持有锁的线程。

针对这两点，对之前的Lock类进行完善，下面是修改后的代码。

```java
public class Lock{
	//  是否被锁定
	boolean isLocked = false;
	// 加锁成功的线程
	Thread  lockedBy = null;
	// 加锁成功的线程，在当前锁上申请加锁的次数；   
	// 当计数为0的时候，才会释放锁isLoked=false并notify，这样可以避免提前释放锁
	int     lockedCount = 0;
	public synchronized void lock()  throws InterruptedException{
		Thread callingThread = Thread.currentThread();
		// 修改拒绝加锁的判断条件
		while(isLocked && lockedBy != callingThread){
			wait();
		}
		isLocked = true;
		lockedCount++;
		lockedBy = callingThread;
	}
	
	public synchronized void unlock(){
		// 修改允许释放锁的判断条件
		if(Thread.curentThread() == this.lockedBy){
			lockedCount--;
			if(lockedCount == 0){
				isLocked = false;
				notify();
			}
		}
	}
}
```

现在我们修改了申请加锁、解锁的判断条件，使得Lock类变成了一个可重入的锁：
- 如果一个线程获得了锁lock，后续的重新加锁请求，将被允许通过，同时，我们将lock的加锁次数+1，其他线程的加锁请求则会被拒绝；
- 如果一个线程申请解锁lock，当该线程是当前加锁线程的情况下，才会被允许，首先将lock的加锁次数-1，当计数为0时，表示线程已经从嵌套的加锁请求里面完全退出来了，因此表示锁确实是被释放了，此时修改isLocked状态，并唤醒其他阻塞的线程。

# Lock Fairness

锁的公平，前面在Starvation和Fairness里面，我们提到了公平锁的实现，这里不再赘述了。
需要注意的是，**在java里面，synchronized不是一个公平锁，ReentrantLock是一个公平锁**。如果需要申请多个锁的话，synchronized需要嵌套多次，而ReentrantLock只需要调用newCondition方法就可以了。

公平锁，这里我们就不再提了，理解其思想就是了，即对于某个monitor上的锁，很多个线程来申请这个锁，**先申请这个锁的线程，将先获得这锁**。

# Call unlock() in finally{}

切记，lock、unlock保护的临界区中有可能会抛出异常，为了在出现异常之后，当前线程能够释放当前持有的锁，一定要在finllay子句中执行unlock操作，否则，当前线程没有释放持有的锁，将导致其他线程永远获取不了这些锁，可能会导致死锁的发生。

在finally中执行解锁操作：

```java
lock.lock();
try{
	//do critical section code, which may throw exception 
} finally {
	lock.unlock();
}