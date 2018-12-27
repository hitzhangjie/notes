当多个线程访问相同的资源时，并且其中某个线程进行了资源的写操作时，才会出现竞态条件。如果多个线程都只是读取的话，那么就不会涉及到数据竞态这种情况。

我们假定在多个线程之间共享的对象，是不会被任何线程更新的，并且这个共享对象也是immune（不可变的，如const），那么这种情况下，线程肯定是安全的。下图是一个示例：

```java
public class ImmutableValue{
	private int value = 0;
	public ImmutableValue(int value){
		this.value = value;
	}
	public int getValue(){
		return this.value;   
	}
}
```

注意该免疫对象成员是private类型的，只能通过getter方法来读取，没有setter方法来设置。针对变量的初始化操作是在构造函数出实现的。这种情况下不管是几个线程来访问该对象，肯定都是线程安全的。

如果对一个该对象执行一个add操作的话，为了保证其immune的特性，可以稍作修改，如下图所示，每次add之后返回的都是一个新的immune对象，不影响原来对象的值，也就没有改变原来对象的状态，不可变性仍然保持。

```java
public class ImmutableValue{
	private int value = 0;
	public ImmutableValue(int value){
		this.value = value;   
	}
	public int getValue(){
		return this.value;   
	}  
	public ImmutableValue add(int newValue){
		return new ImmutableValue(this.value + newValue);
	}
}
```

**The Reference is not Thread Safe!**

需要记住的是，一个对象可能是immutable的，是线程安全的，但是指向它的引用，可能不是线程安全的。看下面这个例子：

```java
public class Calculator{   
	private ImmutableValue currentValue = null;   	 
	public ImmutableValue getValue(){     
		return currentValue;
	}
	public void setValue(ImmutableValue newValue){     
		this.currentValue = newValue;
	}
	public void add(int newValue){     
		this.currentValue = this.currentValue.add(newValue);
	}
}
```

上面这个例子中，我们假定ImmutableValue这个类对应的对象是线程安全的，按照之前的定义，确实是线程安全的，但是Calculator这个类在通过setValue方法、add方法对其进行操作时，却不是线程安全的。比如一个多个线程引用同一个Calculator对象，分别调用setValue和addValue则可能导致与预期不一致的状态。

**因此，通过这个例子，我们我们可以看出：一个对象本身可能是线程安全的（即调用对象中的方法是线程安全的），但是这不能保证在使用对象的整个场景中都是线程安全的。**

在深入理解jvm一书中，对此进行了更加详细的描述，线程安全可以细分为几类：

- 不可变
  在java里面，final修饰的变量是不可能被修改的，我们称之为不可变，任何线程都不能对其进行修改。对于基本数据类型，直接用final修饰就可以；如果是一个对象，需要将其中的成员全部修饰为final，如果其成员中包含了对象，那么对象中的成员也要修饰为final。不可变不可能引起线程安全问题。

- 绝对线程安全
  其定义是，“不管运行时环境如何，都不需要添加额外的同步措施”。这种绝对线程安全无法达到的，除非是前面的不可变类型。在我们jdk里面标注的某些类是线程安全的，指的都是相对线程安全。

- 相对线程安全
  相对线程安全，我们已经看过这样的例子了，例如上面的ImmutableValue类。某个类如果是相对线程安全的，指的是，如果多个线程在对象上面调用对象定义的方法时，可以达到线程安全的要求。但是，这不能保证，在用户定义的操作场景下，多个线程对其进行的操作依然是符合场景需要的线程安全。因此，相对线程安全，其实也是要根据场景需要对其施加必要的同步措施的。

- 线程兼容
  指的是，对象本身并不是线程安全的，但是我们可以通过施加某些必要的同步措施，来满足操作场景的需要，达到线程安全的目的。这种情况下，我们一般通过同步互斥措施来实现线程安全。

- 线程对立
  指的是，不管如何施加同步措施，都不可能保证多线程环境下的线程安全。线程对立这种排斥多线程的代码，在java中很少见的，但是确实存在。

  > 举个例子，Thread.suspend方法和Thread.resume方法，假如线程t持有某个对象m的monitor的锁，现在执行t.suspend之后，t会被挂起，但是t持有的锁却不会释放，当另一个线程中企图调用t.resume来恢复线程t的执行时，这个线程必须先获得t持有的对象m的monitor锁，之后才能调用resume。这种情况下，就会产生死锁。正式由于这个原因，suspend方法以及resume方法都已经被废弃了。其他的线程对立的方法还有System.setIn、System.setOut、System.runFinalizersOnExit等。

