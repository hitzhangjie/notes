# Functions

- function is one kind of first-level citizen types in Go  [go101.org]

  > "function在golang里面算是一级公民，可以将function用作value。自定义函数和builtin、unsafe package下的内置函数有区别，自定义函数不支持范型，但是内置函数支持。"

- The literal of a function type is composed of the func keyword and a function signature literal. A function signature is composed of two type list, one is the input parameter type list, the other is the output result type lists.  [go101.org]

  > "函数类型字面量包括了func以及函数签名（参数列表、返回值列表），函数名称并不属于签名的一部分。参数列表中参数名字以及返回值列表中返回值的名字可以是blank identifier “_”。参数列表中如果某个参数有名称，那么其他的也必须有，要么都有要么都没有（可以为blank identifier），返回值列表也是。"

- The last parameter of a function can be a variadic parameter. Each function can has most one variadic parameter. To indicate the last parameter is variadic, just prefix three dots ... to its type in its declaration. Example: func (values ...int64) (sum int64) func (seperator string, tokens ...string) string  [go101.org]

  > "每个函数的最后一个参数可以是可变参数，用...来指明，每个函数最多有一个可变参数。带有可变参数的函数称为可变函数，可变函数在调用的时候，对应可变参数位置的实参必须是一个slice...的形式，如[]int{1,2,3}..."

- function types are uncomparable types  [go101.org]

  > "函数类型是不可比较类型，但一个函数类型的value可以与nil做比较。因为函数类型不可比较，所以不能用作map的key。"

- A function prototype is composed of a function name and a function signature. Its literal is composed of the func keyword, a function name and a function signature.  [go101.org]

  > "函数原型，包括func关键字、函数名、参数列表、返回值列表。"

- Generally, the names of the functions declared in the same code package can't be duplicated. But there are two exceptions. One exception is each code package can declare several functions with the same name init. The prototypes of all the init functions must be func init(). Each of these init functions will be called once and only once when that code package is loaded at run time. The other exception is functions can be declared with names as the blank identifier _, in which cases, the declared functions can never be called.   [go101.org]

  > "通常情况下，同一个package下面不允许出现两个函数名相同的函数，但是有两个例外：
  > 1）同一个package下允许出现多个init函数，且init函数必须声明为func init() {...}，参数列表、返回值列表必须为空，每个init函数在包初始化的时候都会执行且只执行一次。
  > 2）允许存在多个函数名为blank identifier的函数，这样的函数永远不会被执行。"

- Most function calls are evaluated at run time. But calls to the functions of the unsafe standard package are always evaluated at compile time. Calls to some other built-in functions, such as len and cap, may be evaluated at either compile time or run time, depending on the passed arguments. The results of the function calls evaluated at compile time can be assigned to constants.  [go101.org]

  > "有些函数时在编译时就能执行完成的，不一定要到运行时。unsafe这个包下的内置函数都是在编译时就完成的，其他的内置函数如len、cap可能在编译时完成也可能在运行时完成，比如len一个数组肯定就是编译时完成，但是len一个slice就要运行时。如果一个函数调用可以在编译时就执行完成，那么该函数的返回值可用于给constants赋值。"

- Let's repeat it again, like all value assignments in Go, all function arguments are passed by copy in Go. When a value is copied, only its direct part is copied.  [go101.org]

  > "函数调用过程中，所有的参数传递都是通过值拷贝来完成的，就是说不管是基本类型还是比较复杂的容器类型、引用类型都是通过值拷贝的形式，但是只拷贝direct value part这部分。"

- We can implement a function in Go assembly. Generally, Go assembly source files are stored in *.a files. A function implemented in Go assembly is still needed to be declared in a *.go file, but the only the prototype of the function is needed to be present. The body portion of the declaration of the function must be omitted in the *.go file.  [go101.org]

  > "golang里面有些函数声明是没有函数体的。一般这种都是以汇编的形式来定义的函数体，汇编代码存储在*.a文件中，而不是*.go。"

- A value of a function type is called a function value  [go101.org]

  > "函数类型的值称为函数值，一个function value的类型就是func+参数列表+返回值列表，它是可调用的。只有自定义函数类型才可以作为函数值，内置类型函数以及init不可以作为函数值。如果一个函数值funcV是nil，go funcV会触发严重错误（无法恢复）导致进程crash，如果是在当前协程里面调用该函数值则错误可恢复。"

- function的内部表示

  > 看下golang cmd/compile/internal/types/type.go中对Func类型的定义：
  > // Func contains Type fields specific to func types.

  ```
  type Func struct {
  	Receiver *Type  // function receiver，接受者类型，可以为nil或non-nil
  	Results  *Type   // function results，返回值类型
  	Params   *Type // function params，参数列表类型
  	Nname *Node   // function name，函数名
  	// Argwid is the total width of the function receiver, params, and results.
  	// It gets calculated via a temporary TFUNCARGS type.
  	// Note that TFUNC's Width is Widthptr.
  	Argwid int64
  	Outnamed bool // 是否是可导出的？
  }
  ```

  > 通过这个Func定义来看，其可以覆盖golang里面所有的函数类型声明了，不管是普通函数，还是成员方法等等。

- 闭包是怎么实现的？

  > “前段时间组内分享闭包使用的时候，觉得这玩意虽然轻巧但是太容易出错了，究其原因是因为不了解闭包的实现原理。那么闭包是如何实现的呢，抽时间扒拉了一下golang中实现闭包的代码，看完后瞬间觉得闭包很简单。来简单总结一下。
  > 闭包就是函数+环境，问题是这里的环境是如何与函数进行绑定的呢？一开始看了上面的Func类型定义之后，我以为是golang创建了一个虚拟的类型（里面各个字段值为闭包捕获的变量值）然后将该虚拟类型作为receiver-type来实现的呢，可是仔细一想这种思路站不住脚，因为闭包是golang里面的first-class citizen，闭包实现应该非常轻量才对，如果像我最初这种想法那实在是太复杂了，想想要创建多少虚拟类型及其对象吧。
  > 看了下源代码，总结一下golang中的实现思路，考虑到闭包对象是否能重复使用，分为两个场景进行处理：
  > 1）假如闭包定义后立即被调用，因为只会被使用一次，所以应该力图避免闭包对象的内存分配操作，那怎么优化一下呢，以下面的示例代码为例。

  ```
  func(a int) {
  	println(byval)
  	byref++
  }(42)
  ```

  > 上面的闭包将被转换为简单函数调用的形式：

  ```go
  func(byval int, &byref *int, a int) {
  		println(byval)
  		(*&byref)++
  }(byval, &byref, 42)
  ```

  > 注意看函数原型的变化，原来闭包里面捕获的变量都被转换成了通过函数参数来供值：
  >
  > - 因为println操作不涉及对byval变量的修改操作，所以是按值捕获；
  > - 而byref++涉及到对捕获变量的修改，所以是按引用捕获，对于按引用捕获的变量会进行特殊处理，golang编译器会在编译时将按引用捕获的变量名byref转换成“&amp;byref”，同时将其类型转换成pointer类型，捕获变量对应的写操作也会转换为通过pointer来操作。
  >
  > 2） 假如闭包定义后并不是立即调用，而是后续调用，可能调用多次，这种情况下就需要创建闭包对象，这种情况下如何实现呢？
  >
  > ```go
  > if v.Name.Byval() && v.Type.Width <= int64(2*Widthptr) {
  >     // If it is a small variable captured by value, downgrade it to PAUTO.
  >     v.SetClass(PAUTO)
  >     xfunc.Func.Dcl = append(xfunc.Func.Dcl, v)
  >     body = append(body, nod(OAS, v, cv))
  > } else {
  >     // Declare variable holding addresses taken from closure
  >     // and initialize in entry prologue.
  >     addr := newname(lookup("&" + v.Sym.Name))
  >     addr.Type = types.NewPtr(v.Type)
  >     addr.SetClass(PAUTO)
  >     addr.Name.SetUsed(true)
  >     addr.Name.Curfn = xfunc
  >     xfunc.Func.Dcl = append(xfunc.Func.Dcl, addr)
  >     v.Name.Param.Heapaddr = addr
  >     if v.Name.Byval() {
  >         cv = nod(OADDR, cv, nil)
  >     }
  >     body = append(body, nod(OAS, addr, cv))
  > }
  > ```
  >
  > - 如果变量是按值捕获，并且该变量占用存储空间小于2*sizeof(int)，那么就通过在函数体内创建局部变量的形式来shadow捕获的变量，相比于通过引用捕获，这么做的好处应该是考虑到减少引用数量、减少逃逸分析相关的计算。
  > - 如果变量是按引用捕获，或者按值捕获但是捕获的变量占用存储空间较大（拷贝到本地做局部变量代价太大），这种情况下就将捕获的变量var转换成pointer类型的“&amp;var”，并在函数prologue阶段将其初始化为捕获变量的值。
  >
  > 
  >
  > 这部分的代码详见：cmd/compile/gc/closure.go中的方法transformclosure(...)。闭包就是函数体+环境，环境就是像这样绑定的。"