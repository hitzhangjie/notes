

`package java.util.concurrent`提供了并发编程相关的一些工具，包括同步互斥相关的工具（如锁、条件变量）和并发数据结构，这里总结一下。

# 1 并发同步

## 1.1 锁

### 1.1.1 Lock接口

lock接口定义如下，lock提供了排他性访问能力：

```java
package java.util.concurrent.locks;

public interface Lock {
    // 申请加锁，如果已经被占用，则阻塞当前线程
    void lock();
    // 申请加锁，如果已经被占用，则阻塞当前线程，只有被中断才能被唤醒
    void lockInterruptibly() throws InterruptedExeption;
    // 尝试加锁，如果已经被占用，则立即返回加锁失败
    boolean tryLock();
    // 解锁操作
    unlock();
    // 创建新的monitor条件
    Condition newCondition();
}
```
不可重入的Lock接口实现在实际使用中是非常不友好的，jdk里面提供的Lock接口实现，都至少是锁可重入的。

ReentrantLock，是一个可重入锁实现，具有如下特点：

- 是可重入锁；
- 可要求同时持有多个锁，通过`newCondition()`方法；
- 可通过`new ReentrantLock(isFairLock)`中的参数来指定是否创建公平锁（该锁有公平、非公平两种实现）；
- 可以不用一直阻塞，通过`tryLock(time, unit)`来实现这一点，等待一段时间仍不能获得锁就返回加锁失败。

> 公平锁、非公平锁，指获得锁的顺序是否与申请加锁的顺序一致，一致就是公平锁实现，反之就是非公平锁实现。

### 1.1.2 ReadWriteLock接口

```java
public interface ReadWriteLock {
    // 返回一个用于read的读锁
    Lock readLock();
    // 返回一个用于write的写锁
    Lock writeLock();
}
```

`ReentrantReadWriteLock`，是一个可重入的读写锁实现。

## 1.2 条件变量

`Condition`接口，提供了同步操作的条件判断能力：

```java
package java.util.conconcurrent.locks;

public interface Condition {
    // 让线程进入waiting状态，除非被signal唤醒或者interrupt
    void await() throws InterruptedException;
    // 让线程进入waiting状态，除非被signale唤醒
    void awaitUninterruptibly();
    // 让线程进入timed_waiting状态，可以被signale唤醒或者interrupt，或等定时器超时
    void awaitNanos(long nanosTimeout) throws InterruptedException;
    // 让线程进入timed_waiting状态，与awaitNaos类似，区别是可以自己指定时间单位  
    void await(long time, TimeUnit unit) throws InterruptedExeption;
    // 让线程进入timed_waiting状态，与前两个区别是指定的超时时间是一个日期
    boolean awaitUntil(Date deadline) throws InterruptedException;
    // 唤醒在当前condition上等待的众多线程中的其中一个
    void signal();
    // 唤醒在当前condition上等待的所有的线程
    void signalAll();
}
```

# 2 并发调度

## 2.1 Executor接口

### 2.1.1 Executor

Executor，是最最基本的执行器接口，其他的都是这个的派生。这个接口只是定义了execute方法，并告知该接口的实现类应该可以接受一个任务（Runnable的实现类）并予以调度。但是调度的方式（比如是定时调度，还是周期性调度，是同步调度，还是异步调度，是并行调度，还是串行调度），以及调度的时间，这些都没有进行明确的规定。这给其他的Executor接口以及实现提供了扩展的空间。

```java
public interface Executor {

    /**
     * Executes the given command at some time in the future.  The command
     * may execute in a new thread, in a pooled thread, or in the calling
     * thread, at the discretion of the <tt>Executor</tt> implementation.
     *
     * @param command the runnable task
     * @throws RejectedExecutionException if this task cannot be
     * accepted for execution.
     * @throws NullPointerException if command is null
     */
    void execute(Runnable command);
}
```

### 2.1.2 ExecutorService

ExecutorService是Executor的派生接口，它扩展了Executor的具体功能，表现在添加了很多有用的函数，描述了完整的异步（不在调用线程中执行提交的任务）并发任务调度能力。可以向其提交一个或者多个任务，可以调度其中的任意一个或者所有的任务，并可以设定超时时限。submit函数还可以返回一个或者一系列的Future对象，用于跟踪任务执行的状态，并可以控制任务继续执行、取消等动作。

```java
public interface ExecutorService extends Executor {

    // 不再接受新的task；
    // 对于已经提交的task，会允许其执行完成；
    void shutdown();

    // 不再接受新的task；
    // 对于正在执行的tasks，尽最大努力让其停止；
    // 对于正在waiting的tasks，阻止其执行；
    // 返回未完成的tasks列表。
    List<Runnable> shutdownNow();

	// 当前executor service是否已经shutdown
    boolean isShutdown();

    // executor service调用了shutdown或shutdownNow之后才会返回true；
    // 表示的是所有的线程都被停止了；
    boolean isTerminated();

	// 调用了shutdown之后，再调用该方法，会阻塞调用线程，直到executor中所有线程结束
    boolean awaitTermination(long timeout, TimeUnit unit) throws InterruptedException;

    // 提交任务；
    // 通过返回的Future对象可以跟踪任务的执行状态；
    Future<T> submit(Callable<T> task);
    Future<T> submit(Runnable task, T result);

    // 激活所有的或任意的一个任务，在指定时间内如果没有完成，则返回；
    // 通过返回的Future对象，可以跟踪任务的执行状态；
    List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks, 
                            long timeout, TimeUnit unit) 
        					throws InterruptedException;
    T invokeAny(Collection<? extends Callable<T>> tasks, 
                			long timeout, TimeUnit unit)
        					throws InterruptedException, ExecutionException, TimeoutException;
}
```

### 2.1.3 ScheduledExecutorService

它是ExecutorService的派生接口，在ExecutorService的基础上，添加了**延时调度**、**周期性调度**的功能。

```java
public interface ScheduledExecutorService extends ExecutorService {

	// 延时指定时延之后，调度一次command（线程池中线程调用command.run）
    public ScheduledFuture<?> schedule(Runnable command,
                                       long delay, TimeUnit unit);
	// ………………………………………………………………………………（线程池中线程调用callable.call)
    public ScheduledFuture<V> schedule(Callable<V> callable,
                                           long delay, TimeUnit unit);
	// 在指定时延之后，按指定地周期，周期性地调度command；
    public ScheduledFuture<?> scheduleAtFixedRate(Runnable command,
                                                  long initialDelay,
                                                  long period,
                                                  TimeUnit unit);
	// 在指定时延之后，按指定地时延，周期性地调度command
    public ScheduledFuture<?> scheduleWithFixedDelay(Runnable command,
                                                     long initialDelay,
                                                     long delay,
                                                     TimeUnit unit);
}
```

上述几个方法都可以根据返回的**ScheduledFuture**对象来跟踪被调度任务的执行状态。

注意：需要对上面的2个方法进行一下特别说明：

**1）scheduleAtFixedRate**

- 这方法会创建一个动作，并在指定的时延initialDelay之后激活这个动作；
- 这个方法在初始时延之后会周期性地调度这个动作，这里的周期性调度的参考开始时间是initialDelay，即如果第一次在initialDelay时刻调度，那么在initialDelay+1*period时刻第二次调度，在initialDelay+2*period时刻发生第三次调度……；
- 如果当这个动作调度一次的执行时间，大于period时，此时后续的调度会被延迟，至于怎么延迟，看具体实现。不要以为调度一次时间大于period之后，executors会利用多个线程来并发地调度，不会的；
  如何实现周期性地调度，肯定是将这个动作，按照period插入到任务队列里面，如果其中的某次调度抛出了异常，则后续的动作都将不会被调度；
  只可以通过调用cancel或者terminate方法来终止调度；

**2）scheduleWithFixedDelay**

- 这个方法，要更加明确一点，它指的是在指定时延之后开始对任务的调度，当这个任务当前次调度执行结束之后，从结束时刻开始计时，直到过了delay的时间长度，然后再调度下一次执行；
- 当前面一次调度出现异常之后，后续的调度也是不再被调度；
- 只可以通过调用cancel或者terminate方法来终止调度；

从这里可以看到，ScheduledExecutorService并不能真正精确地按照FixedRate调度或者FixedDelay调度，只能尽最大能力来模拟，程序员还是要知道Executor的实现细节才能选择出更好的调度方案、实现预设的并发任务调度。

## 2.2 Executor实现

### 2.2.1 ThreadPoolExecutor

```java
public class ThreadPoolExecutor extends AbstractExecutorService {
    // 这个阻塞队列中存储着要执行的任务，poll取出一个任务交给worker线程进行处理
    private final BlockingQueue<Runnable> workQueue;

    // 可重入锁
    private final ReentrantLock mainLock = new ReentrantLock();

    // worker线程集合，访问workers时必须持有mainLock
    private final HashSet<Worker> workes = new HashSet<Worker>();

    // 跟踪线程池中线程数量的峰值，访问时，需要持有mainLock
    private int largestPoolSize;

    // 已经完成的任务数量，当worker线程结束之后才会执行+1操作，需要持有mainLock
    private long completedTaskCount;

    // 所有worker线程的创建都是通过这里的线程工厂，然后调用addWorker方法加入workers
    private volatile ThreadFactory threadFactory;
    
    // 线程池中要求保持alive状态的线程数量的最小值
    private volatile int corePoolSize;
    // 线程池中允许创建的线程数量的最大值
    private volatile int maximumPoolSize;

    // 添加一个worker线程，新创建的worker线程被加入到workers这个集合中，添加成功返回true。
    private boolean addWorker(Runnable firstTask, boolean core) {
        // ……
        w = new Worker(firstTask);
        Thread t = w.Thread;

        workers.add(w);
        if(workerAdded) {
        	// addWorker的时候，线程就启动了，启动之后就开始执行任务队列中的任务
        	t.start();
        }
        // ……
    }
    
    // 获取一个任务
    private Runnable getTask() {
        // ……
        // 如果允许超时，则用poll，poll可以指定超时参数，此时如果没有task可以获取，
        // 超出corePoolSize的线程超时候将保持alived状态；
        // 如果不允许超时，则用take，take会一直阻塞，直到task可以获取。
        Runnable r = timed ?
        workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
        workQueue.take();
        // ……
    }
    
    // 运行一个worker线程
    final void runWorker(Worker w) {
        Thread wt = Thread.currentThread();
        Runnable task = w.firstTask;
        w.firstTask = null;
        w.unlock();	// allow interrupts

        try {
            while(task!=null || task=getTask()!=null) {
                w.lock()
                // ……
                task.run();	// 在当前线程上执行
                // ……
                w.unlock
                // ……
            }
	    }
    }
    
    // 内部类Worker线程
    private final class Worker extends AbstractQueuedSynchronizer implements Runnable {
        public void run() {
        	// 父类的runWorker方法中可以不停地获取到任务并在当前Worker线程上执行
        	runWorker(this);
        }
    }
}
```
**线程池数量如何控制？合适创建、销毁新线程？**

1. 当线程池中线程数量 < corePoolSize的时候，如果新任务到达，会创建一个Thread加入线程池；

2. 当线程池子中线程数量 > corePoolSize，并且 < maxiumPoolSize的时候，只有workQueue中task已满的情况下，才会创建新线程，否则不创建。

	> 因为如果task不满表示当前线程数就可以处理完，如果task已满的情况下为了避免后续任务无法提交，需要立即对task进行消费、处理，因此需要创建新线程。

**线程池ThreadPoolExecutor中比较重要的几个点？**

1. 待执行的任务，都保存在阻塞队列BlockingQueue<Runnable>里面；

2. 执行任务的线程，都存放在线程池里面，这些线程都记录在一个集合Set<Worker> workers里面，称为工作线程；

3. 使用工厂模式来创建线程，这里依赖类ThreadFactory threadFactory，通过它来创建worker线程；

   什么时候创建线程？提交任务的时候，参考几个参数决定是否创建线程。

   - corePoolSize，为线程池中保持alive状态的线程的最小数量，线程start之后、terminated之前都是alive的；
   - maxiumPoolSize，表示线程池中允许创建的线程的最大数量；
   - largestPoolSize，记录线程池中出现的线程数量的峰值；

   创建线程的控制逻辑可以参考前面的问题，其中有提及线程池如何控制线程创建、销毁。线程创建之后启动执行，具体过程是由threadFactory new一个Worker线程对象，并调用其start方法，这个start方法调用run方法，run方法中调用的是外部类ThreadPoolExecutor中的runWorker(this)，这里的runWorker由于是外部类的函数，其中可以通过getTask从任务队列获取任务，并调用任务的run方法在worker线程上运行。runWorker中获取task并执行task.run()。

4. Worker线程内部类，Worker线程初始创建的时候，一般都有一个firstTask，执行了该task之后，就将firstTask设置为null，有点模仿进程调度idle进程的意思。

5. ThreadPoolExecutor在getTask中获取任务时，如果alive状态线程数量超过了corePoolSize，这个时候根据是否允许该部分线程进入idle状态：

   - 如果允许，这部分线程就用带超时限制的poll方法调用来获取task，如果获取不到就返回idle状态稍后再试；
   - 如果不允许，这部分线程获取不到任务就会进入waiting状态，直到有任务可以获取被唤醒。

### 2.2.2 ScheduledThreadPoolExecutor

这个Executor提供了延时调度、周期性调度方法。通过这两种方法调度时，一个任务被多次调度，这里的一次调度我们称为一个执行点，即一个周期性调度的任务有多个执行时间点。

- 同一个任务的不同执行点，可能由不同的线程进行调度；同一个任务的不同的执行点在被调度时，在时间序列上一定不会出现重叠（比如ScheduleAtFixedRate，task执行时间超过间隔时间，后续执行点将被推迟调度）！
- 并且调度队列中排在前面的执行点与排在后面的执行点，确立了一个happends-before关系，即前一个执行点时做的修改，对后续执行点调度时是可见的。

```java
public class ScheduledThreadPoolExecutor
        extends ThreadPoolExecutor
        implements ScheduledExecutorService {

    private class ScheduledFutureTask<V>
    	extends FutureTask<V> implements RunnableScheduledFuture<V> {
        
        private long time;		// 上次执行点时间	
        private long period;	// 调度周期

		// ……
    } 	
}
```

该Executor之所以能够实现周期性调度，是因为当一个task在某个worker线程上被执行了之后，就立即把task中的time修改一下，然后重新加入了任务队列tasks中。

当worker线程再次从tasks中取出这个task的时候，如果立即调度，可能不满足周期性调度、延时调度的条件，以周期性调度为例，它就会计算一下当前时间与期望的时间点之间的差值，period-(now-task.time)，如果这个值为正值，表示还没到期望调度的执行时间，此时当前worker线程执行awaitNanos，等待一定N纳秒后再次执行，以校准执行时间点。

**“按固定频率调度” 与 “按固定延时调度”，两种调度方式都需要在任务结束后处理下次调度时间task.time，只不过修改task.time时使用的参照物不一样：**

- scheduledAtFixedRate按固定频率执行，参考的是**task执行点开始的时间**；
- scheduledWithFixedDelay按固定延时执行，参考的是**task执行点结束的时间**。