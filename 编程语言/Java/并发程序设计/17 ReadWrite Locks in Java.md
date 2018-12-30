
读写锁，是比前面提到的java中的锁更加复杂的锁。它主要致力于解决这样的问题场景，假如一个程序里面有多个读线程，几个写线程，为了提高程序整体性能，我们希望多个线程可以同时读取共享变量的值，因此假如有一个线程正在读，另一个线程又发出了读请求，那么我们允许它读；然而在写的时候，只允许一个线程可以写，其他线程的读请求、写请求都会被阻塞。读写锁，在读线程比写线程数量多时，比较有优势。juc保重已经有了对应的实现，即ReentrantReadWriteLock。但是了解其背后的实现思想，还是非常重要的，接着往下学习吧。

# 读写锁-操作性质

首先，总结一下可以获取共享资源的读权限、写权限的条件。

| 操作请求 | 什么情况下允许该操作请求 |
|:-------:|:-------------------- |
| Read Access | If no threads are writing, and no threads have requested write access. |
| Write Access | If no threads are reading or writing.|

- 如果一个线程请求Read一个资源时，当没有其他线程正在进行写操作，又没有其他线程发出了写操作请求，这种情况下，就会允许当前线程的读操作请求；
- 如果一个线程请求Write一个资源，当没有其他线程正在读、写这个资源时，写操作就会被允许。


有时候我们要考虑**提高写请求的优先级**：

如果我们不提高写请求的优先级的话，假如有很多个线程读，只有少量的线程写，这种情况下，极有可能会发生读请求线程都被调度了，但是写请求线程迟迟得不到响应，写请求线程就会被starvation，饿死了。所以我们有必要将写请求线程的优先级提高。因此，如果有两个线程分别请求读锁、写锁，都刚发出请求，还没有持有该锁，则优先给申请写锁的线程放行，避免其被饿死。

# 读写锁-简单实现

通过上面的总结，我们了解了读写锁的一般性质，根据这些一般性质，我们可以实现一个简单的读写锁。下面是一个读写锁的示例。

```java
public class ReadWriteLock { // 正在执行读操作的线程数量   
    
    private int readers = 0; // 正在执行写操作的线程数量   
    private int writers = 0; // 发出写请求的线程数量   
    private int writeRequests = 0;

    // 获取读锁
    public synchronized void lockRead() throws InterruptedException {
        // 没有线程正在写，或者与当前线程同期发出写请求的情况下，才会授予读锁  
        while (writers > 0 || writeRequests > 0) {
            wait();
        }
        readers++;
    }
    
    // 释放读锁   
    public synchronized void unlockRead() {
        readers--;
        notifyAll();
    }
    
    // 获取写锁   
    public synchronized void lockWrite() throws InterruptedException { 
        // 写请求的线程数量++ 
        writeRequests++; // 没有线程正在读，没有线程正在写的情况下，才会授予写锁     
        while (readers > 0 || writers > 0) {
            wait();
        }
        // 获取了写锁之后，写请求方变成了真正的writer     
        writeRequests--;
        writers++;
    }
    
    // 释放写锁   
    public synchronized void unlockWrite() throws InterruptedException {
        writers--;
        notifyAll();
    }
}
```

# 读写锁-支持可重入

可重入的读写锁，上面我们给出的读写锁示例，不是可重入的。一个锁要真正地发挥作用，能被大规模、放心地使用，必须保证锁的可重入性。因此，我们需要实现一个可重入的读写锁。

为什么说它是不可重入的呢？我们构造了一个操作场景：

```bash
Thread 1 gets read access. 
Thread 2 requests write access but is blocked because there is one reader. 
Thread 1 re-requests read access (re-enters the lock), but is blocked because there is a write request
```

在该操作场景中，线程1在第一步已经成功获取了读锁，但是在第三步，重新申请读锁的时候却失败了，原因是第2步中有一个线程发出了写请求。

**读写锁，是一个锁，不是说它包含了读锁、写锁2个锁。读写锁既可以用于锁定读，也可以用于锁定写。为了描述方便，我们使用了申请读锁来表示锁定读，使用申请写锁来表示锁定写。**

## 读写锁-读可重入

下面需要针对读锁的可重入，进行完善，首先我们要明确，**什么时候读锁可以重入**：

- 当一个线程申请读锁的时候，如果该线程已经持有了读锁，那么授予其读锁；
- 当一个线程申请读锁的时候，如果该线程还没有持有读锁，此时又没有线程正在写，也没有线程发出写请求，就可以被授予读锁； 

为了判断一个线程是否已经获得了读锁，我们通过一个Map来记录，Map中的key就是获得了读锁的线程对象的引用，value就是该线程当前持有读锁的计数。

下面是一个修改后的示例，注意看lockRead()和unlockRead()的变化：

```java
public class ReadWriteLock{
	
	private Map<Thread, Integer> readingThreads = new HashMap<Thread, Integer>(); 						  // 记录持有读锁的线程，及其读锁计数
	private int writers        = 0;	// 持有写锁的线程数量
	private int writeRequests  = 0;	// 发出写请求的线程数量
	
	// 锁定读
	public synchronized void lockRead() throws InterruptedException{
		Thread callingThread = Thread.currentThread();
		while(! canGrantReadAccess(callingThread)){
			wait();
		}
		// 记录线程，及其读锁计数
		readingThreads.put(callingThread, (getAccessCount(callingThread) + 1));   
	}
	
	// 释放读锁
	public synchronized void unlockRead(){
		Thread callingThread = Thread.currentThread();
		int accessCount = getAccessCount(callingThread);
		if(accessCount == 1){
			readingThreads.remove(callingThread);
		} else {
			readingThreads.put(callingThread, (accessCount -1));
		}
		notifyAll();
	}
	
	// 判断指定线程是否可以授予读锁
	private boolean canGrantReadAccess(Thread callingThread){
		if(writers > 0) 
			return false;	// 有正在写的线程，不可以授予读锁
		if(isReader(callingThread)) 
			return true;  	// 当前线程已经持有读锁，可以授予读锁
		if(writeRequests > 0)      
			return false;   // 有线程发出了写请求，不可以授予读锁     
		return true;        // unreachable
	}
	
	// 获取指定线程的读锁计数
	private int getReadAccessCount(Thread callingThread){
		Integer accessCount = readingThreads.get(callingThread); 
		if(accessCount == null) 
			return 0;
		return accessCount.intValue();
	}    
	
	// 判断指定线程是否已经持有读锁
	private boolean isReader(Thread callingThread){
		return readingThreads.get(callingThread) != null;
	}
}
```



## 读写锁-写可重入

下面要针对写锁的可重入，进行完善，我们再重新明确一下，**什么时候写锁可以重入**：

- 只有当一个线程持有了写锁的时候，再次申请写锁的时候，才能授予写锁。

下面我们对之前的代码进行了修改，请注意看lockWrite()和unlockWrite()部分的变化:

```java
public class ReadWriteLock{      
	private Map<Thread, Integer> readingThreads = new HashMap<Thread, Integer>();
	private int writeAccesses    = 0;
	private int writeRequests    = 0;  
	private Thread writingThread = null;
	
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
	
	public synchronized void unlockWrite() throws InterruptedException{
		writeAccesses--;
		if(writeAccesses == 0){     
			writingThread = null;
		}
		notifyAll();
	}
	
	// 判断指定线程能否授予写锁   
	private boolean canGrantWriteAccess(Thread callingThread){
		if(hasReaders())
			return false;       // 有reader，不能授予写锁
		if(writingThread == null)
			return true;   		// 没有正在写的线程，可以授予写锁
		if(!isWriter(callingThread))
			return false;
		return true;            // 当前线程已持有写锁，可重入，重新授予锁
	}
	
	private boolean hasReaders(){
		return readingThreads.size() > 0;
	}
	
	// 判断指定线程是否是正在写的线程   
	private boolean isWriter(Thread callingThread){
		return writingThread == callingThread;
	}
}
```



## 读写锁-持有读锁申请写锁

有时候如果只有一个线程持有读锁，其他线程都没有持有锁，这个时候，这个线程申请写锁，也是可以的才对。
要满足这一点，需要修改一下申请写锁的判定条件，假如readers数量为1，且reader线程就是当前线程，那么当其申请写锁的时候，允许授予写锁。

我们对canGrantWriteAccess()方法进行了一点修改，如下所示：

```java
public class ReadWriteLock{
	private Map<Thread, Integer> readingThreads = new HashMap<Thread, Integer>();      
	private int writeAccesses    = 0;
	private int writeRequests    = 0;
	private Thread writingThread = null;      
	
	// 申请写锁
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
	
	public synchronized void unlockWrite() throws InterruptedException{
		writeAccesses--;
		if(writeAccesses == 0){
			writingThread = null;
		}
		notifyAll();
	}
	
	private boolean canGrantWriteAccess(Thread callingThread){
		if(isOnlyReader(callingThread))
			return true;      // 当前线程是唯一的reader，允许授予写锁
		if(hasReaders())
			return false;
		if(writingThread == null)
			return true;
		if(!isWriter(callingThread))
			return false;
		return true;
	}
	
	private boolean hasReaders(){
		return readingThreads.size() > 0;
	}
	
	private boolean isWriter(Thread callingThread){
		return writingThread == callingThread;
	}
	
	// 判断指定线程是否是唯一的reader线程
	private boolean isOnlyReader(Thread thread){
		return readers == 1 && readingThreads.get(callingThread) != null;
	}
}
```



## 读写锁-持有写锁申请读锁

一个持有写锁的线程，本来就已经是排它性访问共享资源了，现在其申请读锁，也是可以的，不会出现竞态条件。
需要做的就是，修改一下允许授予写锁的判定条件，如果当前线程是持有写锁的线程，即writer，那么可以直接授予读锁。

我们对canGrantReadAccess()进行了一点修改，请注意查看源码的变化：

```java
public class ReadWriteLock{
	private boolean canGrantReadAccess(Thread callingThread){
		if(isWriter(callingThread)) 
			return true;    // 如果当前线程是writer，允许授予读锁       
		if(writingThread != null)   
			return false;
		if(isReader(callingThread)
			return true;
		if(writeRequests > 0)
			return false;
		return true;
	}
}
```



## 读写锁-完整版

完整的可重入的读写锁实现，源码如下：

```java
public class ReadWriteLock {
    private Map < Thread, Integer > readingThreads = new HashMap < Thread, Integer > ();
    private int writeAccesses = 0;
    private int writeRequests = 0;
    private Thread writingThread = null;
    public synchronized void lockRead() throws InterruptedException {
        Thread callingThread = Thread.currentThread();
        while (!canGrantReadAccess(callingThread)) {
            wait();
        }
        readingThreads.put(callingThread, (getReadAccessCount(callingThread) + 1));
    }
    private boolean canGrantReadAccess(Thread callingThread) {
        if (isWriter(callingThread)) return true;
        if (hasWriter()) return false;
        if (isReader(callingThread)) return true;
        if (hasWriteRequests()) return false;
        return true;
    }
    public synchronized void unlockRead() {
        Thread callingThread = Thread.currentThread();
        if (!isReader(callingThread)) {
            throw new IllegalMonitorStateException("Calling Thread does not" + " hold a read lock on this ReadWriteLock");
        }
        int accessCount = getReadAccessCount(callingThread);
        if (accessCount == 1) {
            readingThreads.remove(callingThread);
        } else {
            readingThreads.put(callingThread, (accessCount - 1));
        }
        notifyAll();
    }
    public synchronized void lockWrite() throws InterruptedException {
        writeRequests++;
        Thread callingThread = Thread.currentThread();
        while (!canGrantWriteAccess(callingThread)) {
            wait();
        }
        writeRequests--;
        writeAccesses++;
        writingThread = callingThread;
    }
    public synchronized void unlockWrite() throws InterruptedException {
        if (!isWriter(Thread.currentThread()) {
                throw new IllegalMonitorStateException("Calling Thread does not" + " hold the write lock on this ReadWriteLock");
            }
            writeAccesses--;
            if (writeAccesses == 0) {
                writingThread = null;
            }
            notifyAll();
        }
        private boolean canGrantWriteAccess(Thread callingThread) {
            if (isOnlyReader(callingThread)) return true;
            if (hasReaders()) return false;
            if (writingThread == null) return true;
            if (!isWriter(callingThread)) return false;
            return true;
        }
        private int getReadAccessCount(Thread callingThread) {
            Integer accessCount = readingThreads.get(callingThread);
            if (accessCount == null) return 0;
            return accessCount.intValue();
        }
        private boolean hasReaders() {
            return readingThreads.size() > 0;
        }
        private boolean isReader(Thread callingThread) {
            return readingThreads.get(callingThread) != null;
        }
        private boolean isOnlyReader(Thread callingThread) {
            return readingThreads.size() == 1 && readingThreads.get(callingThread) != null;
        }
        private boolean hasWriter() {
            return writingThread != null;
        }
        private boolean isWriter(Thread callingThread) {
            return writingThread == callingThread;
        }
        private boolean hasWriteRequests() {
            return this.writeRequests > 0;
        }
    }
```

# Call unlock() in finally{}

lock和unlock操作之间的代码就是临界区的代码了，这部分代码有可能会抛出异常，为了避免异常抛出之后，仍能够保证其他线程正常执行，当前线程应该在finally子句中执行unlock操作。如果不这么做的话，当前线程持有的锁不会被释放，其他线程无法获取到该锁，就会引起死锁。

```java
lock.lockWrite();
try{
	//do critical section code, which may throw exception
} finally {
	lock.unlockWrite();
}
```