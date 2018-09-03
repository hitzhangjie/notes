# Introduction Of Source Code Elements

- Simply speaking, what is programming
>"编程，就是借助编程语言组合一系列的对计算机各种硬件设备的操作，来完成特定的任务。"

- High-level programming, many words are reserved to prevent them being used as identifiers. Such words are called keywords.
>"编程语言里面的keywords用来定义类型、函数等等，这些东西可以帮助编译器解析源代码。称这些特殊的word为关键字。"

- golang semicolons ";" rules
>"golang中很多时候是不需要手动插入分号';'的，这是因为golang编译器编译前会自动插入分号。插入分号是有两个规则的，仅当满足这两个规则时才会自动插入分号，否则不插入分号。
当输入字符序列被转换成token序列后，遇到如下情形时，会自动将一个分号插入到token stream中一行的结束位置：
1）遇到的token是一个integer、floating-point，imaginary，rune、string字面量或者关键字break、continue、fallthrough、return之一；
2）遇到的token是运算符或++ -- ) ] }标点之一；
有时复杂语句会写在一行中，这种情况下，需要忽略结束括号)或者}前面的分号，比如for {fmt.Println("hello")}，本来如果正常断行的情况下，编译器会自动在语句fmt.Println("hello")后面加一个分号，但是现在写在同一行的时候编译器不会自动插入，也不需要手动插入。"

- Generally, we should only break a code line just after a binary operator, an assignment sign, a single dot (.), a comma, a semicolon, or any opening brace ({, [, ().  [go101.org]
>"有的时候容易因为错误的换行导致编译器插入分号后编译失败，如何避免这个问题呢？有个简单的方法，我们平时换行的时候，只在二元操作符、赋值符号、单元操作符'.'以及逗号、分号、{、[、（之后换行就可以了。 有些人喜欢这种规则，有些人不喜欢，但是官方介绍这可以保证风格一致，也可以加快编译速度。"

# Keywords And Identifiers

- keywords can be categorized as four groups
>"golang 1.10现在包括25个keywords，他们可以划分成如下4类。
1）const, func, import, package, type and var are used to declare all kinds of code elements in Go programs. 
2）chan, interface, map and struct are used as parts in some composite type denotations.
3）break, case, continue, default, else, fallthrough, for, goto, if, range, return, select and switch are used to control code flows.
4）defer and go can also be viewed as control flow keywords. But they are some special. They are modifiers of function calls."

- identifier naming and _ (underscore)
>"标识符命名规则，字母(unicode字符也可以)、数字、下划线，起始字符必须是字母或者下划线。注意blank identifier _ 是一个特殊的标识符，可以用于初始化包，也可以用于drop某个变量。"

- exported identifier
>"标识符首字母大写表示是一个导出的标识符，可以在外部package中被引用，类似于其他语言中的public访问修饰符，golang 1.10中东亚字符是非导出的。"

# Basic Types And Their Value Literals

- Types can be viewed as value templates, and values can be viewed as type instances.  [go101.org]
>"类型是值的模板，值是类型的实例。"

-  Go supports following built-in basic types
>"golang中包括了如下17个基本数据类型，1个bool类型，11个整数类型（包括一个特殊的uintptr）、2个浮点类型，2个复数类型，1个字符串类型。  这些类型名虽然都不是首字母大写，不是导出类型，但是可以不用import任何包就可以使用。这是编译层面做的工作，不需关心。  每种类型都有对应的0值，也就是默认值，对于bool类型是false，对于数值类型是0，对于字符串类型是空串。"

- type definition and type alias
>"type B b，这是定义一个新类型B；type C = c，这是定义一个类型的别名C，与类型c完全是同一个类型。这样定义类型会继承方法吗？好像不会。"

# Constants And Variables

- In Go, some values are untyped. An untyped value means the type of the value has not been confirmed yet. On the contrary, the type of a typed value is determined.  [go101.org]
>"golang里面，有些值是有无类型的，一个无类型的值表示这个值的类型还没有确定下来，一个有类型的值自然表示其类型已经确定下来了。举个例子：const s = "hello"，这里的s就是无类型的，虽然根据字面量“hello”还是会赋给它一个默认类型string。再看：const s = string("hello")，这里的s是有类型的，是string类型。"
  
- The default type of a literal constant is determined by its literal form. The default type of string literal is string. The default type of a boolean literal is bool. The default type of integer literal is int. The default type of rune literal is rune (a.k.a, int32). The default type of a floating-point literal is float64. If a literal contains an imaginary part, then its default type is complex128.   [go101.org]
>"golang里面，无类型的值一般都是有一个默认类型的，就如这里列出的一样。但是值nil比较特殊，它是没有默认类型的，因为通过nil这个字面量无法推断其类型应该是谁，是map还是slice还是interface还是func？无法确定的。"

- Please note that, there is no the implicit conversion concept in Go specification.  [go101.org]
>"golang spec里面没有隐式类型转换的概念"

- When the predeclared iota constant is used in a custom constant declaration, at compile time, within the custom constant declaration, its value will be reset to 0 at the first logic line and will increase 1 logic line by logic line.  [go101.org]
>"const block里面iota常用来定义枚举值或者定义常量。注意这里的iota比较特殊，在一个const block里面，iota出现第N行，iota的值就为N-1。  从go规范上来细讲，就是const block由一个ConstSpec列表构成，ConstSpec表述const block中的一行。iota代表的是const声明里ConstSpec的序数，该序数是0-based，ConstSpec的文法定义是一个list，同一行里的多个常量定义算作是同一个ConstSpec，其引用iota值的时候，iota值是相同的。"

- All variables are typed values. When declaring a variable, there must be sufficient information provided for compilers to deduce the type of the variable.  [go101.org]
>"所有变量都是有类型的值，之前讨论的有类型值、无类型值都是针对常量const来说的。实际上，无类型值说的都是常量，有类型值包括常量和变量。"

- x, y = 69, 1.23           // okay  [go101.org]
>"golang允许在一个赋值操作中同时对多个变量赋值，也支持交换变量的值。如x, y, z = y, z, x。这里其实可以反汇编看下golang如何实现的多变量同时赋值的，dlv里面直接反汇编即可，多变量同时赋值确实非常方便，尤其是交换变量值。"

- a = b = 123 // syntax error  [go101.org]
>"golang中不支持链式赋值操作。"

- Dependency Relations Of Package-Level Variables Affect Their Initialization Order
>"包级别变量的初始化顺序不是按照声明的顺序，它们是按照依赖关系进行初始化的，如果A依赖B，那么B一定是先于A进行初始化。另外，包级别变量不能存在环形依赖，一个包级别变量也不能初始化自身。"

- In Go, some values are addressable, some are not
>"所有的变量都是可寻址的，所有的常量都是不可寻址的。"

- variables declaration and ":="
>注意短变量声明语句:=，当我们使用:=的时候，左边的变量如果没有在当前所处的scope中定义过的话，就会创建新的变量实例。以这里的例子说明，var x是在main中定义的，虽然在后续的block {...}中具有可见，但是var x并不是在这个block {...}中创建的，所以x,y := x,y这条语句会在当前block {...}中创建新的变量x、y，block {...}中后续的x隐藏了var x。
>
```
var x = 1
var y = 2
func main() {
    var x = true      // package level variable x is shadowed
    {
        x,y := x,y       // variables x,y on the left side are not defined in this nested block scope when using :=,
                             // so they'll be newly defined variables, which shadow package-level variables x,y
    }
}
```

# Common operators

- 常见运算符类型
>"golang中常见的运算：算术运算符、位运算符、比较运算符、bool运算符、string连接运算符。"

- 运算符优先级
>"这个都是老生常谈的问题了，这里不再赘述了。"

# Function Declarations And Calls

- Function calls can be deferred and invoked in new goroutines (green threads) in Go.  [go101.org]

- In Go, each function call has an exiting phase.
>golang里面可以每个func都有一个exit阶段，在这个阶段defer入栈的函数将被按照LIFO的顺序依次被调用。这个exit阶段进入之前，函数的返回值就已经设置好了，但是如果函数返回值是有名变量的话，defer函数里面依然可以对其进行修改。 比如如下示例函数：  
>
```go
func testDefer() (n int) { 	
    defer func() { 		
        fmt.Println(n) 		
        n = 2 	
     }()
    return 1; 
}
```
- Go support anonymous functions.  [go101.org]

- There are some built-in functions in Go, for example, the println and print functions. We can call these functions without importing any packages.  [go101.org]

# Code Packages And Package Imports

## Package Imports

### 导入路径

- The official Go tools recommend, and often require, the folder containing a third-party package to be put in the src folder under any path specified in the GOPATH environment variable. The import path of the third-party package is the relative path of the package folder to the src folder. The seperators in the path must be always / and can't be \. For example, if the path of a package is OneGoPath/src/a/b/pkg (or OneGoPath\src\a\b\pkg on Windows), then its import path is /a/b/pkg.  [go101.org]
    
  >go中package的导入路径分隔符只能用符号“/”，不管是在windows、linux还是其他平台下。导入的第三方库中的包，这个库必须放在GOPATH/src下，导入路径是相对于这里的src的。
        
### 导入形式

- import importname "path/to/package"  [go101.org]
>package导入的完整形式是这样的，importname是可选的，其默认是导入的包的名字。以fmt为例，假如通过import f "fmt"导入fmt，那么fmt.Println就会报错，必须通过f.Println来调用。 有时可能引入了多个同名包，可以借助这种方式避免歧义。

- The importname in the full form import declaration can be blank identifier (_). Such imports are called anonymous imports. The importing source files can't use the exported resources in anonymously imported packages. The purpose of anonymous imports is to initialize the imported packages (each of init functions in the anonymously imported packages will be called once).  [go101.org]  
>"有时导入时importname定义成blank identifier "_"，这种方式是不想在当前包中使用导入包中的导出变量或函数，只是完成导入包的初始化（执行导入包的init函数）。"

- vendor
    - golang里面引入的第三方库一般是放在GOPATH下的，但是有些三方库并不是全局共享库，可能只会被几个工程用到，这样的话，把这个三方库放在GOPATH下就不是特别合适了，那怎么办呢？  把这个三方库放到工程目录下，rewrite导入路径，但是工程里面可能很多个地方都引用了这个包，全部修改一遍也很麻烦。
        
        >go 1.5开始提供了vendor支持，将项目独享的依赖放到工程下面子目录中的vendor目录下，goimports及其他go tool会自动搜索这个路径，同时，不需要rewrite包导入路径。
        
    - 我发现个问题，这里的vendor下面的库，要放到引用它的那个package的目录下。
    
        >比如工程结构是：
        >
        ```
        src/
            |- pkga
            |- pkgb
        ```
        >如果要在pkga中引用这个vendor中的包，就需要将vendor文件夹放置到pkga/这个目录下，那么如果pkga和pkgb都需要使用这个vendor中的包怎么办呢？那就放到src目录下！"

## 命名方式

- A standard package has a higher import priority than a third-party package if their import paths are identical. So please try to avoid using the import path of a standard package as the import path of a third-party package.  [go101.org]
>go标准库中的package import时优先级更高，我们自定义的库尽量不要导入路径与标准库中的相同。

- The name of folder containing a package is not required to be the same as the package name. However, for library packages, it will make package users confused if the name of a package is different from the name of the package folder.  [go101.org]
>自定义的pkg位于某个文件夹下，应该使得文件夹路径名与pkgname完全一致，避免让使用者产生困惑。

## 加载顺序

-  Go doesn't support circular dependency. If package a imports package b and package b imports package c, then package c can't import package a and b, package b also can't import package a.  A package also can't import itself.  At run time, packages are loaded by their dependency orders. A package will be loaded before all the packages which import it. Each Go program contains only one program package, which is the last package being loaded at run time.  [go101.org]

    >go package导入的时候不能存在环形依赖，比如package a不能导入自身；a导入b，b导入c，c不能导入a或b等。运行时包根据package的导入声明构建依赖关系，并决定哪些package先加载哪些后加载（main最后加载）。

## 包初始化

-  There can be multiple functions named as init declared in one package, even in one source code file. The functions named as init must have no any input parameters and return results.  The init functions in a package will be called once and only once sequentially when the package is loaded. However, the invocation order of these init functions is not specified in Go specification. So there shouldn't be dependency relations between the init functions in one package.  All init functions in all involved packages in a program will be called sequentially. An init function in an importing package will be called after all the init functions declared in the dependency packages of the importing package for sure. All init functions will be called before invoking the main entry function.  For the standard Go compiler, the init functions in a source file will be called from top to down.  [go101.org]

    >同一个package下面可以定义多个init函数（即使是同一个go文件下），这些init函数必须不接收参数、也不返回值。每个init函数在包加载的时候执行且执行一次，相互之间也没有明确的依赖关系。同一个go文件中往往是从上往下执行。 调用main.main之前所有的包的init函数必须先执行完。

# Expressions, Statements And Simple Statements

- Some Expression Cases  Value literals, named constants and variables are all expressions. They also called elementary values.  The operations (without the assignment part) using the operators introduced in the article common operators are all expressions. There are more operator operations which will be introduced in other articles are also expressions.  If a function returns exact one result, then its calls (without the assignment parts) are expressions. Calls of functions without results are not expressions. We have learned that a function call may return multiple results in the article function declarations and calls. Such function calls are called multi-valued expressions. Multi-value expressions can only be be used at some specific senarios.Most expressions in Go a single-valued expression. Later, out of the currrent article, unless otherwise specified, when an expression is mentioned, we mean it is a single-valued expression.  Methods can be viewed as special functions. So the above mentioned function cases also apply to methods. Methods will explained detailedly in the article method in Go later.  In fact, later we will learn that custom functions, including methods, are all function values, so they are also expressions. We can learn more about function types and values later.  Channel receive operations (without the assignment parts) are also expressions. Channel operations will be explained in the article channels in Go later.  Some expressions may have optional results in Go. We can learn such expressions in other Go 101 articles later.  [go101.org]

    >"golang中表达式定义"
    
- Simple Statement Cases  There are six kinds of simple statements. short variable declaration forms pure value assignments (not mixing with variable declarations), including x op= y operations. function/method calls and channel receive operations without the assignment parts. Some of these simple statements can also be used as expressions. channel send operations. nothing. This is called blank statement. x++ and x--.   [go101.org]

    >"golang中简单语句定义，这个要了解下，以为后续很多分支控制、循环控制结构的某些部分要求必须是简单语句。"
    
- Yes, Go supports the two syntaxes. However, the two forms can't be used as values. In other words, they are not expressions. x++ is equivalent to x = x + 1, and x-- is equivalent to x = x - 1, where expression x will only be evaludated once. Go doesn't support the ++x and --x syntaxes.  [go101.org]

    >"golang虽然支持x++和x--，但是不能将其用做赋值，在golang中，++和--都是简单语句，并且没有返回值的，所以不能用于赋值操作。golang中没有前置++、--这种形式。"

# Basic Control Flows

- The control flow code blocks in Go are much like other popular programming languages, but there are also many differences. This article will show these similarities and differences.  An Introduction Of Control Flows In Go  There are three kinds of basic control flow code blocks in Go: if-else two-way conditional execution block. for loop block. switch-case multi-way conditional execution block. There are also some control flow code blocks which are related to some certain kinds of types in Go. for-range loop block for container types. type-switch multi-way conditional execution block for interface types. select-case block for channel types. Like many other popular languages, Go also supports break, continue and goto code execution jump statements. Beside these, there is a special code jump statement in Go, fallthrough.  Among the six kinds of control flow blocks, execept the if-else control flow, the other five are call breakable control flow blocks. We can use break statements to make executions jump out of breakable control flow blocks.  for and for-range loop blocks are called loop control flow blocks. The other four kinds of control flow blocks can all be called as conditional execution control flow blocks. We can use continue statements to end a loop step in advance in a loop control flow block.    [go101.org]
    >"golang中提供了如下6种形式的控制流。 if-else分支控制，for循环，switch-case分支控制，还有三种与数据类型相关的，for-range遍历slice、map、chan，type-switch判断interface动态type，select-case判断chan读写就绪。除了if-else，其他5种都可以使用break跳出，但是对于switch-case、type-switch、select-case不需要显示地写break，这一点不同于c、c++。如果希望某个case的logic执行后，希望继续走到下一个case logic，可以使用fallthrough以达到类似c、c++的效果。"
    
- if InitSimpleStatement; Condition { 	// do something } else { // do something }  [go101.org]
- for InitSimpleStatement; Condition; PostSimpleStatement { // do something }  [go101.org]
- switch InitSimpleStatement; CompareOperand0 { case CompareOperandList1: 	// do something case CompareOperandList2: 	// do something ... case CompareOperandListN: 	// do something default: 	// do something }  [go101.org]
- a fallthrough statement must be the final statement in a branch. And a fallthrough statement can't show up in the final branch in a switch-case control flow block.  [go101.org]
>"fallthrough必须是case分支的最后一条语句，且不能在最后一个分支中出现（最后一个分支可能是case或者default）。"
- Like many other languages, Go also supports goto statement. A goto keyword must be followed a label to form a statement. A label is declared with the form LabelName:, where LabelName must be an identifier. A label which name is not the blank identifier must be used at least once.  [go101.org]
>"golang也支持goto，形式类似于c、c++，但是定义的label必须至少使用一次。"
- A goto statement must contain a label. A break or continue statement can also contain a label, but the label is optional.  [go101.org]
>"golang也支持break label、continue label这种形式。"

# Goroutines, Deferred Function Calls And Panic/Recover

- Go doesn't support creating system threads in user code. So using goroutines is the only way to do concurrent programing (program scope) in Go.  [go101.org]
>"Linux下c、c++创建物理线程都是借助pthread线程库来实现的，pthread线程库也是借助系统调用clone或者fork来创建的线程（本质上是轻量级进程LWP）。golang里面对用户暴露的只有green线程模型的goroutine创建接口，并没有对创建物理线程的操作进行封装。如果要想在golang里面创建物理线程，可以借助cgo来实现。"

- All the result values of a goroutine function call (if the called function has return results) must be discarded in the function call statement. The following is an example which creates two new goroutines in the main goroutine. In the example,  [go101.org]
>"go funcName(...)这样在一个协程里面执行这个函数的话，是不能获取到函数的返回值的。val := go funcName(...)这样编译的时候就会报错的。"

- this program uses the Println function in the log standard package instead of the corresponding function in the fmt standard package. The reason is the print functions in the log standard package are synchronized, so the texts printed by the two goroutines will not be messed up in one line (though the chance the printed texts being messed up by using the print functions in the fmt standard package is low for this specified program).  [go101.org]
>"log这个包里面的打印语句做了同步处理，多个goroutine的打印语句不会出现在同一行里面，fmt里面的打印语句没有做同步处理，打印语句有可能会出现错乱的可能，尽管可能性比较小。"

- The WaitGroup type has three methods, Add, Done and Wait  [go101.org]
>"WaitGroup可以用来对多个goroutine的执行做同步，启动一个goroutine之前调用add方法，goroutine结束的时候掉done方法，如果想等到多个goroutine执行结束再继续执行可以调用wait。这个是非常常用的。"

- A blocking goroutine can only be unblocked by an operation made in another goroutine. If all goroutines in a Go program are in blocking state, then all of they will stay in blocking state for ever. This can be viewed as an overall deadlock. When this happens in a program, the standard Go runtime will try to crash the program.  [go101.org]
>"如果程序启动后创建的所有的goroutine（包括main goroutine）都sleep了，那么golang的运行时就会直接crash程序。"

- At runtime. we can call the runtime.GOMAXPROCS function to get and set the number of logical processors (Ps). For the standard Go runtime, before Go 1.5, the default initial value of this number is 1, but since Go 1.5, the default initial value of this number is equal to the number of logical CPUs avaiable for the current running program. The default initial value (the number of logical CPUs) is the best choice for most programs. The default initial value can also be set through the GOMAXPROCS environment variable.  [go101.org]
>"获取cpu cores数量： 
>cat /proc/cpuinfo | grep "cpu cores" | head -n 1， 
>goenv local 1.4.3，GOMAXPROCS==1 
>goenv local 1.5.4，GOMAXPROCS==cores数量"

- A deferred function call is a function call which follows a defer keyword. Like goroutine function calls, all the result values of the function call (if the called function has return results) must be discarded in the function call statement.  [go101.org]
>"deferred function的返回值也必须忽略，原因与go function是一样的。但是有两个函数内置函数比较特殊，recover和"

- When a function call is deferred, it is not executed immediately. It will be push into a defer-call stack maintained by its caller goroutine. When a function call fc returns and enters its exiting phase, all the deferred function calls pushed in the function call (fc) (which has not exited yet) will be executed, by their inverse orders being pushed into the defer-call stack. Once all these deferred calls are executed, the function call fc exits.  [go101.org]
>"golang里面function有一个exit phase阶段，函数里面defer function并不立即执行，而是先push到一个函数栈中，等到函数return后进入exit phase阶段时，就按照LIFO的顺序执行defer入栈的函数，所有deferred的函数执行完毕后，函数才真正地退出。"

- Deferred Anonymous Functions Can Modify The Named Return Results Of Nesting Functions  [go101.org]
>"如果一个函数的返回值有名字的，比如func X() (n int)这种，那么在这个函数的defer函数里面可以修改返回值n。比如: func X() (n int) {    defer func() {     fmt.Println(n)    // 输出1，return 1设置了n==1     n = 2   }()   return 1 } x := X() 这里x的值其实是2而不是1，尽管return 1，但是defer里面修改n为2了。"

- the deferred function call feature is a necessary feature for the panic and recover mechanism which will be introduced below.  Deferred function calls can also help us write more clean and robust code.  [go101.org]
>"对于异常处理：panic、recover必须要借助defer function； 对于资源释放：defer可以避免我们因为遗忘释放资源或者异常分支考虑不周导致的资源泄露、死锁等问题。"

- The arguments of a deferred function call or a goroutine function call are all evaluated at the moment when the function call is invoked. For a deferred function call, the invocation moment is the moment when it is pushed into the defer-call stack of its caller goroutine. For a goroutine function call, the invocation moment is the moment when the corresponding goroutine is created.   [go101.org]
>"go funcName(args), defer funcName(args)，go函数以及defer函数的参数的计算时间，go函数是在goroutine创建的时候就计算完参数，defer函数是在函数入栈的时候就完成参数计算。切记，并不是对应的函数实际执行的时候才开始计算。"

- Go doesn't support exception throwing, instead, explicit error handling is preferred to use in Go programming. However, in fact, Go supports an exception throw/catch alike mechanism. The mechanism is called panic/recover.  [go101.org]
>"golang中没有像c++或java那样的try-catch异常处理能力，但是提供了一种更加类似的、更轻量的panic、recover处理机制。 同一个goroutine里面panic，只可以在同一个goroutine的函数调用栈中借助defer函数recover。如果一个goroutine中panic了，并且没有recover，那么就会导致该goroutine被kill掉，进而真个进程被kill掉。"




