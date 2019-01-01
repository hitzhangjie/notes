# CAS介绍

**Compare and Swap（比较并交换）**，简称CAS，指的是将一个对象现在的值与一个期望值v进行比较，如果对象现在的值与期望值相等则表示这个对象从上次被读取之后还没有被其他线程修改，这种情况下可以用另一个新值来更新该对象。这个操作依赖CPU硬件的CAS操作支持，可以保证是原子的，是安全的，但是却无法避免ABA问题。

# CAS ABA

什么是ABA问题呢？

一个线程将对象值从A修改为B，然后再从B修改为A，修改操作都是CAS的，但是经过上述两次修改之后，对象的值又变成了A，与最开始的值是一样的，如果想判断到底有没有线程修改过该对象的值，只依赖处理器提供的指令是无法完成的，这就是CAS操作中的ABA问题。

Java中通过为值添加“**Stamp**”解决了计算机处理器中CAS指令的ABA问题，可以了解下AtomicStampedReference的相关实现细节，这里的Stamp可以理解为“版本”。

可以参考这里的教程来了解下Java中如何解决CAS ABA问题，[AtomicStampReference解决CAS ABA问题](http://tutorials.jenkov.com/java-util-concurrent/atomicstampedreference.html)。

# CAS解决什么问题

一个常见的使用场景就是并发程序、并发算法中的“**Check then Act**”模式，即**先检查对象状态、然后依赖对象状态执行某种动作**。

设计了如下程序，实现一个基本的CAS操作，即当锁locked=false的时候，我们执行lock方法的时候，希望将其设置为true，当为locked=true的时候，lock希望将其设计为false。

```java
class MyLock {
	private boolean locked = false;
	// 返回锁定是否成功
	public boolean lock() {
		if(!locked) {
			locked = true;
			return true;
		}
		return false;
	}
}
```

毫无疑问，上述代码在多线程环境中会出大乱子的，问题太多了，因为没有对其进行合适的同步，在Check以及Act的时候，我们没有将其封装为一个原子操作，导致在Check之后，执行Act之前，线程有可能出现Missed Condition的问题，即状态丢失问题。原因就是没有将Check和Act封装为一个原子操作。这个很好修改，修改后代码如下所示：

```java
class MyLock {
	private boolean locked = false;
	// 返回锁定是否成功
	public synchronized boolean lock() {
		if(!locked) {
			locked = true;
			return true;
		}
		return false;
	}
}
```

现在lock()方法首先检查是否已被锁定，没有则锁定并返回true，反之返回false。

现代的处理器都有内置的CAS操作支持，但是处理器中的CAS与Java中提供的CAS支持还是有区别的，处理器中无法解决ABA问题，需要程序通过额外措施提供解决方案，Java里面通过为数据添加不同的版本标记，解决了处理器中会出现的ABA问题。

从java 5开始，可以通过juc包中的atomic包，使用某些原子类型的对象了，例如AtomicBoolean、AtomicInteger等等。

下面是这个示例展示了AtomicBoolean的使用，通过对它的使用，对我们上述MyLock实现进行重写，大家可以学习下。

```java
public static class MyLock {
	private AtomicBoolean locked = new AtomicBoolean(false);
	public boolean lock() {
		return locked.compareAndSet(false, true);
	}
}
```

本文中首先是通过synchronized关键字实现了一个MyLock版本，达到了compareAndSwap的目的。然后我们又使用了juc.atomic包中的AtomicBoolean来重写了MyLock，直接使用原子类AtomicBoolean中的compareAndSwap，也达到了我们想要的目的。这两种方式哪种效率更好呢？使用AtomicBoolean效率更好，它利用处理器的CAS指令来完成，比基于synchronized这种重量级锁的实现效率高，前者是乐观的同步策略，后者是悲观的同步策略。以后遇到类似的CAS的场景，可以考虑使用juc包中的atomic包下的相应原子类型。

