# Slipped Conditions

## 介绍

Slipped Condition（状态丢失），指的是线程“**从检测到特定状态开始、到依据此状态执行特定动作之前**”这个状态已经被其他线程所修改，进而会导致线程执行了错误的处理。

## 原因

状态丢失的根本原因，是因为没有保证对状态的测试和更新是原子的，为了避免状态丢失，我们可以将对变量的testing和updating放到同一个synchronized代码块中。

## 示例

还是以锁的实现为例，来说明下Slipped Condition这个问题。

先看下这里的Lock实现：

```java
public class Lock {
    private boolean isLocked = true;
    public void lock() {
        synchronized(this) {
            while (isLocked) {
                try {
                    this.wait();
                } catch (InterruptedException e) { //do nothing, keep waiting           
                }
            }
        }
        // slipped condition 
        synchronized(this) {
            isLocked = true;
        }
    }
    public synchronized void unlock() {
        isLocked = false;
        this.notify();
    }
}
```

假定有两个线程t1，t2，一开始Lock对象中的isLocked is false，两个线程同时调用lock()方法，由于此时isLocked为false，t1，t2将先后执行完成第一个同步块中的代码。假定两个线程执行完了第一个同步块之后，都准备进入第二个同步块。状态丢失问题就来了。

两个线程都到达了第二个同步块，并将同时往后执行，此时isLocked=true会被赋值两次，但是实际上我们的希望是，只有第一个检测到isLocked=false的线程才会将其更新为true，但是第二个线程在前面的测试过程中检测到的也是false，虽然当第二个线程进入下面这个块的时候，isLocked已经被更新了（intel强一致，理论上应该加volatile），但是第二个线程仍以为其状态是之前测试的isLocked==false，所以又更新了一次（首次检测到的isLocked为false的状态丢失了）。

造成上述slipped condition发生的原因，是因为没有将对状态的测试和更新放在同一个原子性的操作中，应修改如下，这样问题就解决了，在平时编程的时候要注意这个问题，处理不好这样的细节可能会造成重大的安全事故。

```java
public class Lock {
    private boolean isLocked = true;
    public void lock() {
        synchronized(this) {
            while (isLocked) {
                try {
                    this.wait();
                } catch (InterruptedException e) { //do nothing, keep waiting       
                }
            }
            isLocked = true;
        }
    }
    public synchronized void unlock() {
        isLocked = false;
        this.notify();
    }
}
```

