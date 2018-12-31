Java是天然的多线程程序，哈哈，即便我们没有显示地创建多个线程，JVM GC等等也会额外地创建其他线程。Java中提供了丰富的线程控制能力使得我们开发多线程程序更加容易，我们经常会编写多线程程序来处理并发事务。

由于线程的创建、切换、销毁都会带来一定的系统开销，程序中不能无限制地创建线程，必须对线程总量进行限制，考虑到线程创建、启动的开销，一般也会预先创建好一定数量的线程备用……基于这样的考虑，程序中一般会使用线程池。

每一个任务（Thread的子类，或者实现了Runnable接口的类），如果我们都直接调用其start方法的话，jvm实际上是为其创建了一个线程，Linux里面每一个java线程都是对应着内核的一个KLT线程，然后再由内核调度线程。当线程多了之后，开销还是比较大的。我们希望能对此加以改进，减少程序执行过程中，创建线程、启动线程的开销。

我们可以将一个任务，交给线程池中的一个空闲线程来执行，这样我们就避免了重新创建线程、启动线程的开销。那么怎么做呢？这里需要首先提一下线程的start()方法和run()方法。我们已经知道启动一个新线程要用start()方法，调用run()方法只是在callingThread上执行了某个线程实例的run方法，之前我们对此特别予以了说明，希望大家千万不要调用run方法，而是调用start方法。现在呢？我们反其道而行之，我们要直接调用run方法了。

我们创建一个线程池，线程池中包含了2个重要的东西：
1）一个是BlockingQueue，用它来存储待处理的任务；
2）另一是线程列表List，里面记录了线程池中包含的线程。

线程池中的每一个线程在启动之后，就会自己从BlockingQueue这个任务队列里面通过dequeue方法取出任务，任务就是一个Runnable实现类或者Thread的子类，记为t，然后线程中的线程调用t.run()，注意我们这里调用的是run而不是start，因为我们希望这个任务直接在当前线程上执行，而不是让jvm创建新的虚拟机线程，看到直接调用run方法的作用了吧。

当前线程执行完了任务t之后，可以继续在队列上取任务并处理；如果线程在dequeue的时候，如果队列为空，那么当前线程就会阻塞，直到其他线程将任务放入了阻塞队列中，并将阻塞的线程唤醒。

好了，说的已经够清楚了，下面看实现。

下面的线程池实现中，使用了BlockingQueue，注意这里的BlockingQueue不是juc包中的，是作者自己实现的，前面的一节中，我们已经描述过了，看线程池源代码：

```java
public class ThreadPool {
	// 任务队列，BlockingQueue实现
	private BlockingQueue taskQueue = null;
	// 当前线程池中包括的线程
	private List<PoolThread> threads = new ArrayList<PoolThread>();
	// 是否停止当前线程池
	private boolean isStopped = false;
	
	/**
	 * 线程池构造函数
	 * @param noOfThreads 线程池中待创建的线程数量
	 * @param maxNoOfTasks 线程池中可以容纳的最大任务数量
	 */
	public ThreadPool(int noOfThreads, int maxNoOfTasks){
		// 创建任务队列，容量为……
		taskQueue = new BlockingQueue(maxNoOfTasks);
		// 创建……个线程
		for(int i=0; i<noOfThreads; i++){
			threads.add(new PoolThread(taskQueue));
		}
		// 依次启动创建的线程
		for(PoolThread thread : threads){
			thread.start();
		}
	}
	// 执行任务task，实际上是将其丢到任务队列里面
	public synchronized void  execute(Runnable task) throws Exception{
		if(this.isStopped)
			throw new IllegalStateException("ThreadPool is stopped");
		// 入队操作，请查看BlockingQueue中的enqueue方法实现，便于理解
		this.taskQueue.enqueue(task);
	}
	// 停止线程池，将停止池中的所有线程
	public synchronized void stop(){
		this.isStopped = true;
		for(PoolThread thread : threads){
			thread.stop();
		}
	}
}

// 线程池中的线程
public class PoolThread extends Thread {
	// 持有一个指向任务队列的引用，共享变量，BlockingQueue内部含不同措施
	private BlockingQueue taskQueue = null;
	private boolean       isStopped = false;
	public PoolThread(BlockingQueue queue){
		taskQueue = queue;
	}
	public void run(){
		while(!isStopped()){
			try{
				// 从任务队列dequeue一个任务，可能会阻塞；
				// 阻塞后要么从ThreadPool.execute中被唤醒(实际上是BlockingQueue唤醒）；
				// 要么从this.doStop中被中断，也起到唤醒的作用吧！
				Runnable runnable = (Runnable) taskQueue.dequeue();
				// 直接调用任务的run方法，在当前线程上完成任务
				runnable.run();
			} catch(Exception e){
				//log or otherwise report exception,
				//but keep pool thread alive.
			}
		}
	}
	public synchronized void doStop(){
		isStopped = true;
		// PoolThread有可能会阻塞在任务队列dequeue操作上，中断线程，相当于唤醒的作用
		this.interrupt();
	}
	public synchronized boolean isStopped(){
		return isStopped;
	}
}
```

关于该线程池的使用方式，代码中已经注释的非常清楚了，这里就不再细述其具体应用了。