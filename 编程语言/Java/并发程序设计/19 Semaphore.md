Semaphores（信号量）是一种用于线程之间进行同步的结构：
- 可用来在线程之间传递信号（因为其通过状态变量记录通知，可以避免通知丢失问题）；
- 也可以像锁一样，被用来保护临界区。

java 5中，juc包中引入了信号量实现，我们没必要自己实现信号量，但如果了解信号量背后的实现细节，对我们理解、应用非常有帮助。

# Simple Semaphore

下面是一个简单的信号量的实现（其中的take、put可以理解为取苹果、放苹果，signal表示是否有苹果剩余）：

```java
public class Semaphore {
	// 记录通知的发送，避免通知丢失问题（在完善的锁实现中，也考虑了避免通知丢失问题） 
	private boolean signal = false;
	public synchronized void put () {
		this.signal = true;
		this.notify();
	}
	public synchronized void take() throws InterruptedException{
		while(!this.signal)
			wait();
		this.signal = false;
	}
}
```

这里的put()方法发送了一个信号，这个信号是存储在Semaphore对象里面的，这里的take方法等待这个信号，当收到这个信号的时候，就把信号标记signal清空，然后退出take()方法。使用信号量可以避免信号丢失问题。顾名思义，**信号量，就是信号的数量**……

**信号量，可以记录接收到的信号的数量**，这是其最基本的要求，其内部通过状态变量可以记录，当然了，根据具体实现的不同，有**“简单信号量”、“计数信号量”、“带计数上限的信号量”**等。

对于“*信号通知丢失*”问题，如果用锁来实现的话，需要专门考虑，而信号量由于其基本要求便是“记录信号的数量”，因此可以保证不会发生信号丢失。

# Using Semaphores for Signaling

以下是两个线程使用我们上面定义的信号量进行信号发送的示例。

```java
Semaphore semaphore = new Semaphore();
SendingThread sender = new SendingThread(semaphore);
ReceivingThread receiver = new ReceivingThread(semaphore); receiver.start();
sender.start();

public class SendingThread {
	Semaphore semaphore = null;
	public SendingThread(Semaphore semaphore){
		this.semaphore = semaphore;
	}
	public void run(){
		while(true){
			//do something, then signal
			this.semaphore.put();
		}
	}
}

public class RecevingThread {
	Semaphore semaphore = null;
	public ReceivingThread(Semaphore semaphore){
		this.semaphore = semaphore;
	}
	public void run(){
		while(true){
			this.semaphore.take();
			//receive signal, then do something...
		}
	}
}
```

# Counting Semaphore

本节介绍计数信号量，前面的简单信号量，不能记录接收到的信号的数量，put方法中通过设置signal的值发送信号通知。我们这里对简单信号量进行一下修改，使其能够记录接收信号的数量。以下是修改后的版本，我们将boolean signal修改成了int signal，并针对对signal的操作进行了修改。

```java
public class CountingSemaphore {
	private int signals = 0;
	public synchronized void put() {
		this.signals++;
		this.notify();
	}
	public synchronized void take() throws InterruptedException{
		while(this.signals == 0)
			wait();
		this.signals--;   
	}
}
```

# Bounded Semaphore

本节介绍有计数上限的信号量，前面见到的计数信号量，没有一个上界限制，即信号量的值可以无限增加，但是我们有的时候希望它能有一个上限，比如我们设置一个上限10，来表示最多可以放10个苹果。

对此，我们可以对上面的计数信号量进行一些修改，修改后的代码如下所示：

```java
public class BoundedSemaphore {
	private int signals = 0;	// 信号量，记录接收到的信号的数量
	private int bound   = 0;	// 信号量的计数上限
	public BoundedSemaphore(int upperBound){
		this.bound = upperBound;
	}
	public synchronized void put() throws InterruptedException{ 
		// 自旋锁，避免假唤醒
		while(this.signals == bound)
			wait(); 
		// 信号量++，表示又放了一个苹果
		this.signals++;
		this.notify();
	}
	public synchronized void take() throws InterruptedException{
		// 自旋锁，避免假唤醒
		while(this.signals == 0)
			wait();
		// 信号量--，表示取走了一个苹果
		this.signals--;
		this.notify();
	}
}
```

# Using Semaphores as Locks

当创建了一个计数上限为1的信号量时，实际上是创建了一个互斥量，可以将它当做是一个排它性锁来使用。

```java
BoundedSemaphore semaphore = new BoundedSemaphore(1);
...  
semaphore.take();

try{
	// critical section
	// 临界区有可能抛出异常，一定要try-catch
} finally {
	// 记得在finally里面释放信号量，因为信号量本质上还是通过synchronized来实现的， 
	// 当前线程如果不执行put释放semaphore上的锁，其他线程会出现死锁   	
	semaphore.put();
} 
```

