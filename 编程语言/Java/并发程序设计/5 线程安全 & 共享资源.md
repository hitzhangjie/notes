# 介绍

能够安全地同时被多个线程调用的代码，是线程安全的。如果一段代码好是线程安全的，那么它就不含竞态条件。在多个线程更新共享资源的时候才会出现竞态条件。因此了解“线程执行过程中哪些资源会被共享”是非常重要的。

# Java内存模型

说到java中的线程安全，不得不提java中的内存模型（简称JMM），java虚拟机中，内存区域可以分成如下几个：

- 线程共享的区域：方法区、堆区；
- 线程私有的区域：虚拟机栈、本地方法栈（hotspot中将本地方法栈与虚拟机栈合二为一）、程序计数器；

在线程私有区域上的内存，与其他线程由于不会发生共享问题，因此不会出现线程安全问题，重点关注的就是线程共享的区域，即方法区和堆区。

# Local Variables

局部变量由于是存放在线程自己的虚拟机栈中，因此不存在与其他线程的共享问题，这就意味着所有的局部的基本类型变量，都是线程安全的。下面是一个线程安全的示例。

```java
public void someMethod(){
  // 变量在线程自己的栈上分配，肯定是线程安全的
  long threadSafeInt = 0;

  threadSafeInt++;
}
```

# Local Object References

局部的对象引用，这种引用变量类型，也是分配在线程栈上的，它是不涉及到与其他线程的共享问题，但是这个变量所引用的对象，并不是存储在线程自己的栈空间中的，而是存放在线程共享的堆区中的。

如果在某个方法中，我们new了一个对象，并且指向这个对象的引用，没有在此方法内逃逸出去，那么其他线程是不可能通过任何方法来访问这个对象的，因此虽然这个对象是在堆中，但是也是线程安全的。

注意这里提到了“**逃逸**”，其实在构造函数中如果发生了**this指针逃逸**，那将是一件非常糟糕的事情，因为对象还没有初始化完成，就有可能被外部使用，造成不可预期的后果。在jvm里面也常常利用逃逸分析技术，来判断是否存在潜在的线程安全问题。这里就不多讲了，详细信息可以自己google一下。

```java
public void someMethod(){
	LocalObject localObject = new LocalObject();
	localObject.callMethod();
    // 假定callMethod还未成功执行完成，method2就已经开始执行
	method2(localObject);
}  
public void method2(LocalObject localObject){   	
	localObject.setValue("value");
}
```

# Object Members

对象的成员，与对象一起，都是存放在堆区中的。因此，如果两个线程调用了同一个对象上的相同方法，而如果这个方法又会更新对象成员的话，那么这个方法就不是线程安全的。下面展示了一个示例，不是线程安全的：

```java
public class NotThreadSafe{     
	StringBuilder builder = new StringBuilder();
	public add(String text){
		this.builder.append(text);
	}
}
```

如果两个线程同时在相同的NotThreadSafe对象上调用add方法，就会产生竞态条件，请看以下示例示例：

```java
NotThreadSafe sharedInstance = new NotThreadSafe();

new Thread(new MyRunnable(sharedInstance)).start();
new Thread(new MyRunnable(sharedInstance)).start();

public class MyRunnable implements Runnable{
	NotThreadSafe instance = null;
	public MyRunnable(NotThreadSafe instance){
		this.instance = instance;
	}
	public void run(){     
		// 竞态条件     
		this.instance.add("some text");
	}
}
```

上面展示了在相同的对象NotThreadSafe对象上调用add方法产生了竞态条件，在不同的对象上调用的话，是不会产生竞态条件的，下面的代码在上面代码的基础上进行了修改，是线程安全的：

```java
new Thread(new MyRunnable(new NotThreadSafe())).start();
new Thread(new MyRunnable(new NotThreadSafe())).start();
```

# The Thread Control Escape Rule
当试图判断代码中访问的资源是否是线程安全的时，可以通过如下规则进行判断：

>If a resource is created, used and disposed within the control of the same thread, and never escapes the control of this thread, the use of that resource is thread safe.

如果一个资源被创建了，这个资源只在当前线程中被使用，并且资源的引用没有被暴露到外部的其他线程中，那么线程对这个资源的访问就是线程安全的。
资源可以是任何共享的资源类型，例如java对象，数组，文件，数据库连接，socket等。在java里面，你不用显示的释放对象，在java里面对象失去引用关系后，会自动被gc回收。

关于这方面，需要考虑java的自动内存回收机制。首先在java里面，定义了几种引用类型：
- 强引用，这种引用类型在程序代码中是普遍存在的，例如Object obj = new Object()，只要obj没有被设置成null，那么obj指向的对象是永远不会被gc进行回收的；

- 软引用，SoftReference，这种引用关系用于描述有用但是非必须的引用关系，当jvm中进行了minor gc，发现剩余内存不够用，然后就会进行full gc，full gc后发现还不够用的时候，才会抛出OutOfMemoryError。而这里的软引用引用的对象，可以在gc抛出OutOfMemoryError之前，被列入待回收对象范围，然后进行回收。

- 弱引用，WeakReference，这种引用关系描述的是非必须的引用关系，当jvm进行gc的时候，一定会回收弱引用所引用的对象内存空间。

- 虚引用，PantomReference，这种引用没有什么特别的用处，仅仅是用来，当对象被回收的时候，可以获得一个通知。

然后需要考虑，jvm如何发现失去引用关系的对象，一种是基于对象的引用计数法的，这在操作系统里面也广泛使用，但是在java里面，引用计数法不能解决环形依赖的问题，比如：

```java
class B {
    A a;
    public void setA(A a) { this.a = a; }
}
class A {
    B b;
    public void setB(B b) { this.b = b; }
}
B b = new B();
A a = new A();
b.setA(a);
a.setB(B);
```

这样a和b相互依赖，假如现在a、b的作用域已经到头了，然后变量a、b被销毁了，但是在a所引用的对象里面还引用着对象b引用的对象，在b引用的对象里面还继续引用着a引用的对象，即虽然栈变量a、b不存在了，但是由于堆上的两个对象存在**环形依赖**问题。

这两个对象，如果是按照引用计数法来判断的话，都存在引用关系，是活的对象，无法进行回收；

**jvm里面的垃圾回收，必须要解决判断对象是否存活的问题，采用的是基于GC Roots链的可达性分析算法，即通过可以作为GC Roots的对象进行可达性分析，无法到达的对象就被视为待回收对象，除非在第一次标记之后，第二次标记之前，通过finalize方法成功拯救了自己，即重新建立this与外部某个变量的引用关系。**

可以作为**GC Roots的对象**包括：

- 虚拟机栈（栈帧中的本地变量表）中变量引用的对象；
- 方法区中类静态属性引用的对象；
- 方法区中常量引用的对象；
- 本地方法栈中JNI（即一般所说的native方法）引用的对象；

**通过GC Roots对象，及其成员变量所引用的对象，……，我们可以得到一条链，叫做GC Roots链，在这条链上的对象，表示对象可达，是活的，如果是强引用则不会被回收，软引用要视情况而定，弱引用一定会被回收。**

那么是否应该提出另一个疑问？jvm中如何通过对象的引用变量，来定位对象在内存的位置。这里涉及到**对象的访问定位，主要包括两种方式，通过句柄访问对象、通过直接指针访问对象**。关于什么是通过句柄访问对象、什么是通过直接指针访问对象，请参见jvm中相关内容进行详细地了解。这里不再赘述。

尽管一个对象的访问是线程安全的，但是如果这个对象指向的是一个共享资源，例如文件或者数据库，你的应用程序整体上也可能不是线程安全的。例如，线程1\2都通过数据库连接建立了与数据库建立了连接，例如使用的连接分别为conn1、conn2，但是这些连接指向了同一数据库中的同一张表中的同一条记录，假定存在如下操作示例代码，并且有几个线程在并发访执行这段代码，那么应用就是不会是安全的：

```shell
check if record X exists
if not, insert record X // 多个线程操作，导致线程不安全：

Thread 1 checks if record X exists. Result = no
Thread 2 checks if record X exists. Result = no
Thread 1 inserts record X
Thread 2 inserts record X
```
