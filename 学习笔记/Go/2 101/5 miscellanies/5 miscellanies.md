
# Some Simple Summaries

- Some Simple Summaries - Go 101 
    >这篇文章中对golang中的某些点进行了整理、总结，这里对其中比较有意思的几个进行了摘录。

- Types whose values may have indirect underlying parts  [go101.org]
    >回顾golang中哪些数据类型包含了indrect value part，主要包括引用类型和string，即：string、slice、map、interface、function、channel。

- Types which values can be represented with composite literals (T{...})  [go101.org]
    >"回顾golang中哪些类型创建值的时候可以通过T{...}来进行创建，主要包括：struct、array、slice、map"

-  Types which zero values can be represented with nil  [go101.org]
    >"回顾golang中哪些类型的零值可以为nil，这些类型主要是引用类型和指针类型，包括slice、map、channel、function、interface和pointer，不同类型T(nil)的size是不同的。

- interface(nil)占用2个byte （存了两dtype、dvalue字段）

- slice(nil)占用3个byte （存了data、cap、len字段）

-  Functions whose calls will/may be evaluated at compile time  [go101.org]
    >"回顾golang中unsafe这个包下的操作都是编译时可以确定的，可以为常量赋值。"

-  Values that can't be taken addresses  [go101.org]
    >"golang中有些变量是不允许取地址的，这里对不能取地址的情况进行了总结，这些情况在使用的时候避免就可以了：
    >- 字符串中的byte不可取地址，因为字符串是不可变的，所以不允许取地址，有地址就可以修改字符串了；
    >- map中的元素不允许取地址，因为有了地址就可以修改key的值，可能要rehash，增加复杂性；
    >- 接口值的动态值，因为该值其实是一个指针，对该指针字段取地址，假如通过修改该字段地址使其指向另一个值，那么动态类型可能与动态值类型不匹配；
    >- 常量类型不可取地址，既然是常量类型就没有修改的必要，所以也不必返回地址；
    >- 字面量不可取地址（但是对于某些符合类型字面量，实际上是允许我们对其取地址的，其实这只是编译器的一个syntax sugar，例如 a := &amp;struct{1,2,3}，这其实是先创建一个临时变量tmp := struct{1,2,3}然后再执行 a := &amp;tmp；
    >- 包级别函数不能取地址；
    >- 成员方法不能取地址；
    >- 立即数不能取地址，如函数调用、显示值转换、以及其他的如channel接收操作、sub string操作sub slice操作、加减乘除等。"

-  Types which don't support comparisons    [go101.org]
    >"map、slice、function以及包含了不可比较类型的时struct和array。"

-  Expressions which can return an optional additional bool return value  [go101.org]
    >"map读操作如 v,ok := anymap[key]；chan上的v,sentBeforeClosed = "

-  Ways to block current goroutine ‎forever by using the channel mechanism  [go101.org]
    >"- 读取一个不会写数据的匿名chan，如&lt;-make(chan int) or &lt;-make(&lt;-chan int);
    >- 读取一个不会读数据的匿名chan，如make(chan int) or &lt;-make(chan&lt;- int);
    >- 读一个nil chan，如&lt;-chan struct{}(nil);
    >- 写一个nil chan，如chan struct{nil} &lt;- struct{}{}；
    >- 使用一个空的select-case block，如select{}；"

# nil in Go

- In Go, nil can represent zero values of the following kinds of types
    >"go里面nil可以用于表示如下类型的的零值，pointer类型、map类型、slice类型、function类型、channel类型、interface类型。"

- nil Has Not A Default Type
    >"go里面有些预定义的标识符是有类型的，如true、false表示的是bool类型，iota是整型，但是nil没有默认的类型，上面也提到了，nil可以是多种引用类型的零值，必须要有足够的类型信息编译器才能推断出nil表示的数据类型。"

- The Sizes Of nil Values With Types Of Different Kinds May Be Different
    >"nil值占用的内存大小会随着nil表示的不同数据类型而有所不同，如nil map和nil slice，其占用内存大小是不同的。"

- Two nil Values Of Two Same or Different Types May Be Not Comparable
    >"不同数据类型的nil值，或者相同数据类型的nil值，都有可能是不可比较的，这个注意下。"

- Retrieving Elements From Nil Maps Will Not Panic
    >"从nil map里面获取元素会直接导致panic"

- It Is Legal To Range Over Nil Channels, Maps, Slices, And Array Pointers
    >"在nil channel、map、slice、array pointer迭代是有效的，但是行为不完全相同。
    >- 迭代nil channel会永远阻塞；
    >- 迭代nil map和slice迭代0次；
    >- 迭代array pointer的时候迭代次数是array中元素的数量（go里面数组长度也是类型的一部分）。"

# Value Conversion, Assignment, and Comparison Rules

go101里面的类型转换与go spec里面的不同，go spec里面的类型转换描述的是显示类型转换，go101里的类型转换包括了显示类型转换和隐式类型转换。这里的值转换、赋值、比较相关的规则，可以参考原文：<a target="_blank" rel="nofollow" class="link " href="https://go101.org/article/value-conversions-assignments-and-comparisons.html">Value Conversion, Assignment And Comparison Rules In Go - Go 101</a>。

- value conversion rules
    - the apparent conversion rule
    - underlying type related conversion rules
    - channel specific conversion rule
    - implementation related conversion rule
    - type assertion conversion rules
    - untyped value conversion rule
    - constant number conversion rule
    - non-constant number conversion rule
    - string related conversion rules
    - unsafe.Pointer related conversion rules

- value assignment rules
    - comparison restrictions
    - how are two values compared

- value comparison rules

# Syntax/Semantics Exceptions

- 语法、语义例外，也就是go中的一些语法糖或者语法、语义上比较特殊的点

    >这篇文章介绍了go里面的一些语法糖和这门语言比较特殊的一些点，详细内容可以参考原文：<a target="_blank" rel="nofollow" class="link " href="https://go101.org/article/exceptions.html">Syntax/Semantics Exceptions In Go - Go 101</a>。

# Line Break Rules

- 断行规则，golang里面的断行规则要记住或者描述出来还是比较难，我们只要知道有这回事就行了。

    >这篇文章介绍了go里面断行break line的规则，<a target="_blank" rel="nofollow" class="link " href="https://go101.org/article/line-break-rules.html">Line Break Rules In Go - Go 101</a>。

# More about Deferred Function Calls

-  Calls To Many Built-in Functions With Return Results Can't Be Deferred  [go101.org]
    >"golang里面返回值列表不为空的内置函数，除了recover和copy这两个之外，不能直接defer，到go1.10为止这个条件依然成立。  主要原因是这些内置函数的返回值列表不允许忽略，而defer又要求defer调用的函数的返回值列表可以忽略，二者之间存在冲突。  如果确实要defer一个内置函数调用的话，可以将这个内置函数放在一个匿名函数里面，然后defer调用这个匿名函数。"

-  The Evaluation Moment Of Deferred Function Values  [go101.org]
    >"defer调用的func以及对应的参数，在将该函数放入deferred function stack的时候进行对它们的值进行计算，然后写入这个stack。  
    >像下面这个示例： 
    >
    ```
    var f func() 
    defer f()  
    ```
    >这样是有问题的，因为f入栈的时候还没有给f赋值，func是引用类型，所以为nil，导致defer f()对nil解引用导致goroutine panic。但是这里的panic并不会让之前入栈的函数都不执行了。比如： 
    >
    ```
    defer fmt.Println("hello world") 
    var f func() 
    defer f() 
    fmt.Println("xxxx") 
    ```
    >
    >程序会panic之后仍然会执行defer fmt.Println语句，然后对应的goroutine才会被杀死。假如改成下面这样： 
    >
    ```
    var f func() 
    defer f() 
    defer f() 
    defer f() 
    ```
    >
    >那么会出现3次panic，然后函数返回后goroutine再被杀死。"

-  Deferred Calls Make Code Cleaner And Less Bug Prone  [go101.org]
    >"defer函数调用使得程序代码更加clean，比如可以defer文件关闭、锁释放等等。"

-  Performance Losses Caused By Deferring Function Calls  It is not always good to use defered function calls. Up to now (Go 1.10), for the offical Go compiler, deferred function calls will cause some performance losses at run time, in particular for deferred function calls within loop code blocks.  For example, in the following example, the methods CounterB and IncreaseB are much more efficient than the methods CounterA and IncreaseA.  [go101.org]
    >"使用defer确实改善了程序的可读性、健壮性，避免了资源泄露、死锁等问题，但是使用不当的话也会降低性能，例如defer时才解锁可能导致的锁范围扩大问题降低并发效率。
    >另外defer调用函数需要入栈存储，如果同一个函数里面有大量的defer调用的话，可能导致内存申请、内存拷贝操作过多，也会影响程序整体性能，不过这里的时间损耗都是以纳秒来统计的。 
    >相比于这点性能损耗，却改善了可读性，我觉得应该是值得的。当然如果非常在乎性能的话，也可以考虑减少defer调用。  
这里有篇支持使用defer的文章： <a target="_blank" rel="nofollow" class="link " href="https://kylewbanks.com/blog/when-to-use-defer-in-go">https://kylewbanks.com/blog/when-to-use-defer-in-go</a> 
    >这里有篇分析defer性能的文章： <a target="_blank" rel="nofollow" class="link " href="https://bytes-and-bites.com/posts/defer-go-performance/">https://bytes-and-bites.com/posts/defer-go-performance/</a>"

# Some Panic/Recover Use Cases

- Use Case 1: Avoid Panics Crashing Programs  [go101.org]
    >"如果通过go funcName()创建了一个goroutine，只要在这个funcName函数的defer里面通过recover捕获了panic并进行了处理，那么即便该goroutine真的出现了panic也不会影响到整个进程的正常执行；但是假如没有recover处理，那么整个进程就会挂掉。  所以对于开发一个服务而言，recover处理时必须的，某些异常情况会出现panic。"

- Use Case 2: Automatically Restart A Crashed Goroutine  [go101.org]
    >"goroutine里面如果出现了panic，可以借助recover捕获panic的同时重启goroutine。因为已经走到defer函数执行这里了，执行完之后肯定是要函数退出，goroutine销毁了，所以要在defer里面先recover，然后捕获到panic后再次执行go funcName(...)来重启一个goroutine。"

- Use Case 3: Use Panic/Recover To Simulate Long Jump Statements  [go101.org]
    >"c、c++里面提供了goto语句来实现函数内跳转，linux libc库也提供了jmp_buf、setjmp、longjmp来实现函数间跳转。golang没有提供这样的语句，但是借助panic、defer其实也可以达到类似的效果。"

- Use Case 4: Use Panic/Recover To Reduce Error Checkings  [go101.org]
    >"panic、recover是用来处理运行时错误信息的，一般是捕获某些运行时未知异常。 如果单从使用方面来讲，也可以利用panic、recover来缩减错误检查相关的代码，比如panic里面打印错误信息，实际执行过程中有逻辑错误直接panic。 虽说是一种方法，但是不建议使用，有违设计初衷。"

# The Right Places To Call The Built-in recover Function

- The Right Places To Call The recoverFunction
    >"recover只有在defer函数中调用的时候才有作用，在其他地方调用会返回nil没有任何效果。虽然说recover在defer函数中调用的时候才有作用，但是并不是说recover可以捕获所有的panic，比如除零异常；另外呢，recover函数如果不是defer直接调用的，或者不是在defer调用的匿名函数中直接调用的，也捕获不到panic。
    >
    ```
    func main() {
        defer func() {
                defer fmt.Println("8:", recover())
        }()
        defer func() {
                defer func() {
                        defer fmt.Println("7:", recover())
                }()
        }()
        defer func() {
            defer func() {
                fmt.Println("6:", recover())
            }()
        }()
        defer func() {
            func() {
                fmt.Println("5:", recover())
            }()
        }()
        func() {
            defer func() {
                fmt.Println("1:", recover())
            }()
        }()
        func() {
            defer fmt.Println("2:", recover())
        }()
        func() {
            fmt.Println("3:", recover())
        }()
        fmt.Println("4:", recover())
        panic(1)
        defer func() {
            fmt.Println("0:", recover()) // never go here
        }()
    }
    ```
    >上面这个示例中没有一个recover可以捕获panic。
    >golang spec里面是有描述的：
    >The return value of recover is nil if any of the following conditions holds:
    >1 panic's argument was nil;
    >2 the goroutine is not panicking;
    >3 recover was not called directly by a deferred function.
    >上面panic(1)之后的defer语句不可达；上面第1、2、3、4个recover对应着第2条recover规则，因为goroutine中没有panic，所以recover返回nil；
    >上面第5、6、7个recover执行时并不是defer直接调用的，所以recover也返回nil。
    >第8条比较特殊，形式上看也不是直接在defer语句中调用的，也不是在defer的函数里面直接调用的，但是8确是可以捕获到的。
    >最主要的就是第三条，recover不是在deferred函数里面直接调用的。"

- Concept: Function Call Depth, Goroutine Execution Depth & Panic Depth
    >"每一个函数都有一个调用深度，这个调用深度是相对于goroutine入口函数的。对于main goroutine，函数调用深度是相对于main.main这个函数的；对于其他goroutine，函数调用深度是相对于该goroutine入口函数的。
    >可以看下下面这个示例，这个示例描述了main goroutine和其他goroutine的函数调用深度。
    >
    ```
    func main() { // depth 0
        go func() { // depth 0
            func() { // depth 1
            }()
            defer func() { // depth 1       
                defer func() { // depth 2
                }()
            }()
        }()
        func () { // depth 1
            func() { // depth 2
                go func() { // depth 0
                }()
            }()
            go func() { // depth 0
            }()
        }()
    }
    ```
    >
    >goroutine在执行过程中当前所处的位置称为执行点（execution point），这个执行点所处的函数调用深度称为当前goroutine的执行深度。
    >还有个概念panic深度，panic深度描述的是panic产生时所处的函数调用深度，该panic只能从这个深度向上层调用者传播。当产生panic的func里面没有recover可以捕获，那么panic就会传送到上一级函数调用深度，……重复处理，直到调用深度为0。注意panic只会往上级调用者传，传播到了上级调用者，就不会再往下级函数调用中传播，当然也不可能被下级调用深度中的defer func() {recover()}给捕获到。
    >在一个goroutine里面，如果调用recover的函数深度是d，那么它可以捕获深度d-1处生成的panic。而recover函数是否有defer没影响。简而言之就是defer函数中直接调用recover就可以。
如下面这两种形式都可以：
    >
    ```
    func main() { // depth 0
        test()
    }
    func test() { // depth 1
        defer func() { // depth 2
            defer recover()
        }
        panic(1) // depth 1
    }
    或：
    func test() {
        defer func() {
            recover()
        }
        panic(1)
    }
    ```
    defer函数指的是上面的defer调用的匿名函数，defer函数中直接调用recover的意思是，并不是defer函数中调用某个函数，这个函数里面再调用recover，如下面这种形式，这种就不能捕获到panic了。
    >
    ```
    func test() {
        defer func() {
            defer func() {
                recover()
            }
        }
    }
    ```

- Fact: Panics Can Only Propagate To The function Calls With Shadow Depths
    >"panic只会向调用者传播，不会从shadow call depth传播到deeper call depth。"

- Fact: Panics Will Suppress Old Panics At The Same Depth
    >"如果在同一个函数调用深度有多个panic，那么老的panic会被新的panic覆盖。
    >可以下面的示例代码：
    >
    ```
    func main() {
        defer fmt.Println("program will not crash")
        defer func() {
            fmt.Println( recover() ) // 4
        }()
        defer fmt.Println("now, panic 4 suppresses panic 3")
        defer func() {
            panic(4)
        }()
        test()
    }
    func test() {
        defer fmt.Println("now, panic 3 suppresses panic 2")
        defer panic(3)
        defer fmt.Println("now, panic 2 suppresses panic 1")
        defer panic(2)
        panic(1)
    }
    ```

- Fact: Multiple Active Panics May Coexist In A Goroutine
    >"同一个goroutine里面可能存在多个panic，传播到同一个深度的panic才会覆盖。因为panic不会向下传播，所以如果depth 0中生成的panic，不会传播到深度1，如果深度1的也产生了一个panic，这两个就会共存，不能发生覆盖。
    >
    ```
    func main() { // call depth 0
        defer func() {
            fmt.Println("depth 1 catch:",recover())
        }()
        defer fmt.Println("panic 3 is stll active")
        defer func() { // call depth 1
            defer func() { // call depth 2
                fmt.Println("depth 2 catch:", recover()) // 6
            }()
            defer fmt.Println("now, there are two active panics: 3 and 6")
            defer panic(6) // 6 suppress panic 5
            defer panic(5) // 5 suppress panic 4
            panic(4) // 4 not suppress panic 3,
                     // for they have differrent depths.
                     // The depth of panic 3 is 0.
                     // The depth of panic 4 is 1.
        }()
        defer fmt.Println("now, only panic 3 is active")
        defer panic(3) // 3 suppress panic 2
        defer panic(2) // 2 suppress panic 1
        panic(1)
    }
    ```  

- Then, What Is The Principal Rule To Make A recover Call Take Effect?
    >"在一个goroutine里面，如果调用recover的函数深度是d，那么它可以捕获深度d-1处生成的panic。而recover函数是否有defer没影响。简而言之就是defer函数中直接调用recover就可以。
如下面这两种形式都可以：
    >
    ```
    func main() { // depth 0
        test()
    }
    func test() { // depth 1
        defer func() { // depth 2
            defer recover()
        }
        panic(1) // depth 1
    }
    或：
    func test() {
        defer func() {
            recover()
        }
        panic(1)
    }
    ```
    >defer函数指的是上面的defer调用的匿名函数，defer函数中直接调用recover的意思是，并不是defer函数中调用某个函数，这个函数里面再调用recover，如下面这种形式，这种就不能捕获到panic了。
    >
    ```
    func test() {
        defer func() {
            defer func() {
                recover()
            }
        }
    }
    ```

# Code Blocks and Identifier Scopes

- 关于这部分的内容，这里只是做个简单的总结，可以进一步参考：Code Blocks And Identifier Scopes - Go 101。

- Code Blocks
golang中的code blocks包括多种不同的类型，比如universal block、package block、file block、local block。

    - universal block，包含所有的go工程源代码；
    - package block，包含这个package下面定义的所有源代码，除了import导入声明部分；
    - file block，包含一个file里面定义的所有源代码，包含包导入声明部分；
        - local block，就比较多了，通常来讲就是一对{}括起来的代码部分；
        - local block又可以分为显示的和隐式的，例如if v == 1 {}，它其实v==1就是一个隐式的local block，而条件后紧跟着的{}其实是嵌套在这个隐式block内部的一个block，对于for也是类似的设计。

- Identifier Scopes

    >理解了Code Blocks，才能更好地理解标识符的作用域问题，特别是local block中的隐式block。

    >
    ```
    for  k,v := range someMap {   // 这一行中的k,v其实是在隐式block里定义了新变量k,v
        k,v := k,v                // 这里的显示block实际上是内嵌在隐式block里面的，是两个不同的作用域
                                  // 因此短变量声明左边实际上是创建的新变量k,v，而右边的k,v则是引用的隐式block中的
    }
    ```

# Value Copy Costs in Go

- 哪些操作需要内存拷贝
    >"golang里面的赋值、传参、for-range遍历、chan send和rcv等都涉及到大大小小的内存拷贝操作。"

- 如何减少内存拷贝动作
    >"总之大的结构体要尽量传指针，可是呢传指针的时候也要考虑数据类型，没必要的传指针操作会加重gc的负担。

这里举了个for-range的例子，其中有三种方式 for _, v := range someSlice的方式，这种方式涉及到将slice中元素i拷贝到内存变量v的操作，如果slice中元素size比较大，或者for循环遍历的slice比较大，内存拷贝的代价还是要考虑的。前两种方式可以说是能够尽量减少内存拷贝的实现方式。

```go
type S struct{a, b, c, d, e int64}
var sX, sY, sZ = make([]S, 1000), make([]S, 1000), make([]S, 1000)
var sumX, sumY, sumZ int64

func Benchmark_Loop(b *testing.B) {
	for i := 0; i &lt; b.N; i++ {
		sumX = 0
		for j := 0; j &lt; len(sX); j++ {
			sumX += sX[j].a
		}
	}
}

func Benchmark_Range_OneIterVar(b *testing.B) {
	for i := 0; i &lt; b.N; i++ {
		sumZ = 0
		for j := range sY {
			sumZ += sY[j].a
		}
	}
}

func Benchmark_Range_TwoIterVar(b *testing.B) {
	for i := 0; i &lt; b.N; i++ {
		sumY = 0
		for _, v := range sY {
			sumY += v.a
		}
	}
}
```

关于Go Value Copy Costs的内容，可以参考下这篇文章：<a target="_blank" rel="nofollow" class="link " href="https://go101.org/article/value-copy-cost.html">Go Value Copy Costs - Go 101</a> 。"

# Bounds Check Elimination

- 编译器优化

    >"golang编译器1.7开始增加了一些代码优化措施，包括BCE（bounds checking elimination，边界检查消除）和CSE（common subexpression elimination，通用子表达式消除）"

- BCE

    >"BCE其实理解起来很简单，就是代码里面遍历slice的时候，编译器会安插一些代码来对访问越界进行检查，避免内存访问越界。这里BCE就增加了优化措施，如果前一次对slice的访问操作触发了边界检查且检查通过了，如果后续的slice访问的位置或者范围是介于上次检查的范围内的，那么本次就可以消除边界检查。通过benchmark测试来看，有一定的性能提升，不过是ns级的。但是在大型程序里面，积少成多，对时间的消耗可能就比较明显了。
    >这里举个简单的例子吧，比较直观一点
    >
    ```go
    func f1(s []int) {
    	_ = s[0] // line 5: bounds check
    	_ = s[1] // line 6: bounds check
    	_ = s[2] // line 7: bounds check
    }
    
    func f2(s []int) {
    	_ = s[2] // line 11: bounds check
    	_ = s[1] // line 12: bounds check eliminatd!
    	_ = s[0] // line 13: bounds check eliminatd!
    }
    
    func f3(s []int, index int) {
    	_ = s[index] // line 17: bounds check
    	_ = s[index] // line 18: bounds check eliminatd!
    }
    
    func f4(a [5]int) {
    	_ = a[4] // line 22: bounds check eliminatd!
    }
    
    func main() {}
    ```
    >
    >这里可以通过运行命令 go build -gcflags="-d=check_bce"来测试，输出应该显示如下内容，意思是这些行发生了边界检查：
    >
    ```
    ./example1.go:5: Found IsInBounds
    ./example1.go:6: Found IsInBounds
    ./example1.go:7: Found IsInBounds
    ./example1.go:11: Found IsInBounds
    ./example1.go:17: Found IsInBounds
    ```
    >
    >关于这里的详细内容，可以参考下文章：<a target="_blank" rel="nofollow" class="link " href="https://go101.org/article/bounds-check-elimination.html">Bounds Check Elimination - Go 101</a> 。
"

#  The runtime Standard Package
#  The reflect Standard Package


