1）信号，不是通过中断来实现的，信号是在进程的进程描述符表项里面添加了一个队列，用于接收进程收到的信号。当进程被调度的时候，如果进程接收到了不可屏蔽的信号，那么调度进程就会首先执行信号对应的信号处理函数。这根本就不是什么软中断。

2）中断、异常
中断，可以细分为硬中断和软中断，就是硬件触发的中断和软件触发的中断。

硬件中断：
- 可屏蔽中断，设备控制器向cpu引脚intr上发送的中断请求；
- 不可屏蔽中断，设备控制器向cpu引脚nmi发送的中断请求。

异常指的是，因为某些其他的错误、异常等触发的内部抛出的错误，如除0。

其实中断跟异常很相似，他们都是通过中断类型码、中断处理句柄，或者异常类型码、异常处理句柄来处理的。

软中断，不是设备控制器发出去的，是软件通过int指令发出去的。

比较常见的软中断就是bios中断服务int 80h，其实这里的中断向量已经不是bios本身初始化的那一坨了，linux内核初始化的时候已经重新设置了这里的中断向量了。

linux中的信号处理，不是通过软中断实现的。
中断、异常，这里的中断包括了软的、硬的之分。他们都是有严格的说明的：
0~31：这些都是异常或者不可屏蔽的中断
32~47：这些都是可屏蔽的中断
48～：这些都是软中断
应该根据中断类型码（包括了异常码），及其所属的范围，来判断到底是硬件中断，还是软件中断。同时要根据具体情况判断是异常还是中断。

 

