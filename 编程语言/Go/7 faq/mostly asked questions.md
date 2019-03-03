### go范型支持

go只有有限的范型支持，只有go内置的某些函数支持范型（如fmt.Println），用户自定义的函数都是不支持范型的。

go开发者被询问的最多的问题之一，也包括对go genercics的支持计划，但是go开发者表示，go的核心就是simplicity and powerful，并且在实际开发工作中，大司马写的越多越觉得没有必要支持范型。

> Q: Do you have plans to implement generics? 
>
> A: Many proposals for generics-like features have been mooted both publicly and internally, but as yet we haven't found a proposal that is consistent with the rest of the language. We think that one of Go's key strengths is its simplicity, so we are wary of introducing new features that might make the language more difficult to understand. Additionally, the more Go code we write (and thus the better we learn how to write Go code ourselves), the less we feel the need for such a language feature.

### go适用场景

go适合于那些场景？go设计之初，就将系统级编程考虑在内。开发网络server、client、database、cache、balancer、distributor都适合用go来进行开发，也是google内部最初使用go的地方。然而go发布之后，go community中的开发者们开始在不同的场景下使用go进行开发，使得go可以在更多的领域、场景内发光发热。由于go最开始将系统级编程的思想考虑在内，其设计的足够通用，可以说限制go语言应用的仅仅是go library的多少而已。

> Q: What can I use Go for?
>
> A: Go was designed with systems programming in mind. Servers, clients, databases, caches, balancers, distributors - these are applications Go is obviously useful for, and this is how we have begun to use it within Google. However, since Go's open-source release, the community has found a diverse range of applications for the language. From web apps to games to graphics tools, Go promises to shine as a general-purpose programming language. The potential is only limited by library support, which is improving at a tremendous rate. Additionally, educators have expressed interest in using Go to teach programming, citing its succinct syntax and consistency as well-suited to the task.

### go面向对象

go是面向对象语言吗？go是一门“**object-oriented but not type-oriented**”的语言，其实面向对象编程知识一种思想，C虽然是过程式编程语言，但是在Linux Kernel开发中还是可以看到很多**OO的设计思想**，C++支持面向对象，Java强制面向对象，但是这些特性使得语言变得过重了。

go里面提供了interface，允许其他type实现interface，以一种loose coupled的形式来近似实现了runtime polymorphism（运行时多态）；另外，go也提供了interface组合、struct组合能力，通过组合，近似实现了class inheritance（类继承）。

可以说go是一门在语言层面支持面向对象编程的语言，但是它不想C++、Java中这样强制implements、extends，是一种loose coupled的object-oritented、not type-oritented的语言，从这个层面上来讲，go兑现了simple & powerful的目标。

### go移动平台

go有支持Android的打算吗？go编译器是支持生成ARM代码的，因此它是支持移动平台开发的，尽管我们认为go是可以支持移动平台开发的，但是目前开发团队在这方面的投入还比较少（这是比较早的回答）。现在是2019年了，看现在的gomobile支持已经发布了，开发者可以用go开发移动平台的应用了，但是提供的多还是library的形式，然后再通过Java调用这里的library实现，iOS平台支持native开发。

> Q: Are there plans to support Go under Android? 
>
> A: Both Go compilers support ARM code generation, so it is possible. While we think Go would be a great language for writing mobile applications, Android support is not something that's being actively worked on.

### go代码风格

go为什么要统一风格？每个人都有不同的代码风格，尽管存在那么多的best practices。代码风格是重要的，代码写出来是给机器运行的，但是更可能是要给其他开发人员看的。代码风格一致可以减少开发者浪费在代码风格上的精力，专注于代码逻辑本身。gofmt会自动完成代码风格的处理，也便于提高代码的可读性、可维护性。

go程序中使用tab还是space的问题，go官方建议使用tab，但是某些code review平台对于tab、space混排的展示会有问题，鉴于此，我个人还是建议使用space。

> Indentation We use tabs for indentation and gofmt emits them by default. Use spaces only if you must.

### go Getters & Setters

go不会为结构体字段自动生成Getters & Setters，开发者需要自己按需定义。Setters方法名加“Set”这个没啥可讨论的，对于Gtters的方法名，函数名不要加“Get”，没必要，加了反而显得有点多余、累赘。

> Getters  Go doesn't provide automatic support for getters and setters. There's nothing wrong with providing getters and setters yourself, and it's often appropriate to do so, but it's neither idiomatic nor necessary to put Get into the getter's name. If you have a field called owner (lower case, unexported), the getter method should be called Owner (upper case, exported), not GetOwner. The use of upper-case names for export provides the hook to discriminate the field from the method. A setter function, if needed, will likely be called SetOwner. 
>
> Both names read well in practice:  
>
> ```go
> owner := obj.Owner() 
> if owner != user {     
> 	obj.SetOwner(user) 
> }
> ```

### go interface及method

接口名“*er*”结尾，方法名表示动作，尽量不要和接口名重复。

> Interface names  By convention, one-method interfaces are named by the method name plus an -er suffix or similar modification to construct an agent noun: Reader, Writer, Formatter, CloseNotifier etc.  There are a number of such names and it's productive to honor them and the function names they capture. Read, Write, Close, Flush, String and so on have canonical signatures and meanings. To avoid confusion, don't give your method one of those names unless it has the same signature and meaning. Conversely, if your type implements a method with the same meaning as a method on a well-known type, give it the same name and signature; call your string-converter method String not ToString.

### go identifiers

变量和结构体字段命名，不要用下划线分割的形式，使用MixedCaps风格（导出）或者mixedCaps（不导出）。

> MixedCaps  Finally, the convention in Go is to use MixedCaps or mixedCaps rather than underscores to write multiword names.

### go special operator

首先，go没有逗号运算符，在CC++中我们可以写下面这样的代码，逗号运算符分割开了变量i、j、k的赋值：

```c
for (i=0, j=1, k=2; i<100; i++) {
    ...
}
```

但是go中没有逗号运算符，如果要实现类似的逻辑，我们必须使用多重赋值：

```go
for i, j, k := 0, 1, 2; i<100; i++ {
    ...
}
```

另外，++、—在go中是statement而非operator，并且只有后置这一种写法（如i++，而不能是++i）。在CC++中我们可能会写这样的代码：

```c
int i, j;
printf("%d %d\n", i++ j++)
```

但是在go里面不行，因为++、—是语句，不是一个函数会有返回值，`fmt.Println(i++, j++)`编译时报错**# syntax error: unexpected ++, expecting )**。如果要实现类似的逻辑，可以这么写：

```go
i++
j++
fmt.Println(i, j)
```

> Finally, Go has no comma operator and ++ and -- are statements not expressions. Thus if you want to run multiple variables in a for you should use parallel assignment (although that precludes ++ and --).  // Reverse a for i, j := 0, len(a)-1; i < j; i, j = i+1, j-1 {     a[i], a[j] = a[j], a[i] }

### go defer func

defer入栈的函数f，在函数退出阶段f执行的时候，它的参数才会开始进行计算，比如f(v int)是值传递的，实际入栈f的时候，入的是引用的变量的地址。

```go
package main
import "fmt"

func main() {
    i := 0
    defer func(v int) {
       fmt.Println(i) 
    }(i)
    i++
}
```

Output: `1`

> We can do better by exploiting the fact that arguments to deferred functions are evaluated when the defer executes. 

### go allocation func

go里面有两个内存分配的方法，new和make。前者会分配一块内存并将内存清零，并返回指向内存的指针，后者会分配内存并完成初始化过程。下面结合这个slice来详细说明下二者的区别。

> slice可以通过SliceHeader来描述，下面是SliceHeader的结构：
>
> ```go
> SliceHeader {
>     data *unsafe.Pointer
>     cap int
>     len int
> }
> ```
>
> make([]int, 10, 100) allocates an array of 100 ints and then creates a slice structure with length 10 and a capacity of 100 pointing at the first 10 elements of the array. (When making a slice, the capacity can be omitted; see the section on slices for more information.) 
>
> In contrast, new([]int) returns a pointer to a newly allocated, zeroed slice structure, that is, a pointer to a nil slice value.

### go reflection limits

go反射能力尽管很强大，但是还是强加了一些限制，比如出于安全性方面的考虑，不允许在**已经定义的类型**上添加方法。

>总的来说，有两方面的原因，一个是因为go语言本身不允许在一个已经定义的类型上再添加方法，go反射应该与此保持一致；另一个是因为如果在运行时给某个类型动态添加方法，会导致接口断言、转换时出现不一致。综上，不允许在已定义的类型上通过反射来添加新方法。详见go issue：https://github.com/golang/go/issues/20189
>
>As a general rule, the reflect package should provide exactly the capabilities of the language. In the language you can not define a method on an existing struct, so reflect shouldn't let you do it either.
>
>Also, if you could define a struct in one package and add methods in another the general handling of interface conversion would be inconsistent, depending on whether the methods had been added or not.