# Goroutines, Deferred Function Calls And Panic/Recover

**1 Go doesn't support creating system threads in user code. So using goroutines is the only way to do concurrent programing (program scope) in Go.  [go101.org]**

Linux下c、c++创建物理线程都是借助pthread线程库来实现的，pthread线程库也是借助系统调用clone或者fork来创建的线程（本质上是轻量级进程LWP）。golang里面对用户暴露的只有green线程模型的goroutine创建接口，并没有对创建物理线程的操作进行封装。如果要想在golang里面创建物理线程，可以借助cgo来实现。

**2 All the result values of a goroutine function call (if the called function has return results) must be discarded in the function call statement. The following is an example which creates two new goroutines in the main goroutine. In the example,  [go101.org]**

go funcName(...)这样在一个协程里面执行这个函数的话，是不能获取到函数的返回值的。`val := go funcName(...)`这样编译的时候就会报错的。

**3 this program uses the Println function in the log standard package instead of the corresponding function in the fmt standard package. The reason is the print functions in the log standard package are synchronized, so the texts printed by the two goroutines will not be messed up in one line (though the chance the printed texts being messed up by using the print functions in the fmt standard package is low for this specified program).  [go101.org]**

log这个包里面的打印语句做了同步处理，多个goroutine的打印语句不会出现在同一行里面，fmt里面的打印语句没有做同步处理，打印语句有可能会出现错乱的可能，尽管可能性比较小。

**4 The WaitGroup type has three methods, Add, Done and Wait  [go101.org]**

WaitGroup可以用来对多个goroutine的执行做同步，启动一个goroutine之前调用add方法，goroutine结束的时候掉done方法，如果想等到多个goroutine执行结束再继续执行可以调用wait。这个是非常常用的。

**5 A blocking goroutine can only be unblocked by an operation made in another goroutine. If all goroutines in a Go program are in blocking state, then all of they will stay in blocking state for ever. This can be viewed as an overall deadlock. When this happens in a program, the standard Go runtime will try to crash the program.  [go101.org]**

如果程序启动后创建的所有的goroutine（包括main goroutine）都sleep了，那么golang的运行时就会直接crash程序。

**6 At runtime. we can call the runtime.GOMAXPROCS function to get and set the number of logical processors (Ps). For the standard Go runtime, before Go 1.5, the default initial value of this number is 1, but since Go 1.5, the default initial value of this number is equal to the number of logical CPUs avaiable for the current running program. The default initial value (the number of logical CPUs) is the best choice for most programs. The default initial value can also be set through the GOMAXPROCS environment variable.  [go101.org]**

获取cpu cores数量： `cat /proc/cpuinfo | grep "cpu cores" | head -n 1`，

- goenv local 1.4.3，GOMAXPROCS==1； 
- goenv local 1.5.4，GOMAXPROCS==cores数量；

**7 A deferred function call is a function call which follows a defer keyword. Like goroutine function calls, all the result values of the function call (if the called function has return results) must be discarded in the function call statement.  [go101.org]**

deferred function的返回值也必须忽略，原因与go function是一样的。但是有两个函数内置函数比较特殊，recover和panic。

**8 When a function call is deferred, it is not executed immediately. It will be push into a defer-call stack maintained by its caller goroutine. When a function call fc returns and enters its exiting phase, all the deferred function calls pushed in the function call (fc) (which has not exited yet) will be executed, by their inverse orders being pushed into the defer-call stack. Once all these deferred calls are executed, the function call fc exits.  [go101.org]**

golang里面function有一个exit phase阶段，函数里面defer function并不立即执行，而是先push到一个函数栈中，等到函数return后进入exit phase阶段时，就按照LIFO的顺序执行defer入栈的函数，所有deferred的函数执行完毕后，函数才真正地退出。

**9 Deferred Anonymous Functions Can Modify The Named Return Results Of Nesting Functions  [go101.org]**

如果一个函数的返回值有名字的，比如func X() (n int)这种，那么在这个函数的defer函数里面可以修改返回值n。比如: 

```go
func X() (n int) {    
	defer func() {     
		fmt.Println(n)    // 输出1，return 1设置返回值n为1
		n = 2   		  // 修改返回值n为2
	}()   
	return 1 
} 
x := X() 
```
这里`x := X()`的值其实是2而不是1，尽管return 1，但是defer里面修改n为2了。

**10 the deferred function call feature is a necessary feature for the panic and recover mechanism which will be introduced below.  Deferred function calls can also help us write more clean and robust code.  [go101.org]**

对于异常处理：panic、recover必须要借助defer function； 对于资源释放：defer可以避免我们因为遗忘释放资源或者异常分支考虑不周导致的资源泄露、死锁等问题。

**11 The arguments of a deferred function call or a goroutine function call are all evaluated at the moment when the function call is invoked. For a deferred function call, the invocation moment is the moment when it is pushed into the defer-call stack of its caller goroutine. For a goroutine function call, the invocation moment is the moment when the corresponding goroutine is created.   [go101.org]**

go funcName(args), defer funcName(args)，go函数以及defer函数的参数的计算时间，go函数是在goroutine创建的时候就计算完参数，defer函数是在函数入栈的时候就完成参数计算。切记，并不是对应的函数实际执行的时候才开始计算。

**12 Go doesn't support exception throwing, instead, explicit error handling is preferred to use in Go programming. However, in fact, Go supports an exception throw/catch alike mechanism. The mechanism is called panic/recover.  [go101.org]**

golang中没有像c++或java那样的try-catch异常处理能力，但是提供了一种更加类似的、更轻量的panic、recover处理机制。 同一个goroutine里面panic，只可以在同一个goroutine的函数调用栈中借助defer函数recover。如果一个goroutine中panic了，并且没有recover，那么就会导致该goroutine被kill掉，进而真个进程被kill掉。

