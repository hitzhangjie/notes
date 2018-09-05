# Constants And Variables

- In Go, some values are untyped. An untyped value means the type of the value has not been confirmed yet. On the contrary, the type of a typed value is determined.  [go101.org]

> "golang里面，有些值是有无类型的，一个无类型的值表示这个值的类型还没有确定下来，一个有类型的值自然表示其类型已经确定下来了。举个例子：const s = "hello"，这里的s就是无类型的，虽然根据字面量“hello”还是会赋给它一个默认类型string。再看：const s = string("hello")，这里的s是有类型的，是string类型。"

- The default type of a literal constant is determined by its literal form. The default type of string literal is string. The default type of a boolean literal is bool. The default type of integer literal is int. The default type of rune literal is rune (a.k.a, int32). The default type of a floating-point literal is float64. If a literal contains an imaginary part, then its default type is complex128.   [go101.org]

> "golang里面，无类型的值一般都是有一个默认类型的，就如这里列出的一样。但是值nil比较特殊，它是没有默认类型的，因为通过nil这个字面量无法推断其类型应该是谁，是map还是slice还是interface还是func？无法确定的。"

- Please note that, there is no the implicit conversion concept in Go specification.  [go101.org]

> "golang spec里面没有隐式类型转换的概念"

- When the predeclared iota constant is used in a custom constant declaration, at compile time, within the custom constant declaration, its value will be reset to 0 at the first logic line and will increase 1 logic line by logic line.  [go101.org]

> "const block里面iota常用来定义枚举值或者定义常量。注意这里的iota比较特殊，在一个const block里面，iota出现第N行，iota的值就为N-1。  从go规范上来细讲，就是const block由一个ConstSpec列表构成，ConstSpec表述const block中的一行。iota代表的是const声明里ConstSpec的序数，该序数是0-based，ConstSpec的文法定义是一个list，同一行里的多个常量定义算作是同一个ConstSpec，其引用iota值的时候，iota值是相同的。"

- All variables are typed values. When declaring a variable, there must be sufficient information provided for compilers to deduce the type of the variable.  [go101.org]

> "所有变量都是有类型的值，之前讨论的有类型值、无类型值都是针对常量const来说的。实际上，无类型值说的都是常量，有类型值包括常量和变量。"

- x, y = 69, 1.23           // okay  [go101.org]

> "golang允许在一个赋值操作中同时对多个变量赋值，也支持交换变量的值。如x, y, z = y, z, x。这里其实可以反汇编看下golang如何实现的多变量同时赋值的，dlv里面直接反汇编即可，多变量同时赋值确实非常方便，尤其是交换变量值。"

- a = b = 123 // syntax error  [go101.org]

> "golang中不支持链式赋值操作。"

- Dependency Relations Of Package-Level Variables Affect Their Initialization Order

> "包级别变量的初始化顺序不是按照声明的顺序，它们是按照依赖关系进行初始化的，如果A依赖B，那么B一定是先于A进行初始化。另外，包级别变量不能存在环形依赖，一个包级别变量也不能初始化自身。"

- In Go, some values are addressable, some are not

> "所有的变量都是可寻址的，所有的常量都是不可寻址的。"

- variables declaration and ":="

> 注意短变量声明语句:=，当我们使用:=的时候，左边的变量如果没有在当前所处的scope中定义过的话，就会创建新的变量实例。以这里的例子说明，var x是在main中定义的，虽然在后续的block {...}中具有可见，但是var x并不是在这个block {...}中创建的，所以x,y := x,y这条语句会在当前block {...}中创建新的变量x、y，block {...}中后续的x隐藏了var x。

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

