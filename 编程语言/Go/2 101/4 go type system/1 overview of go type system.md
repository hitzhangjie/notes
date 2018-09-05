# Overview of Go Type System

- Built-in basic types in Go has been introduced in built-in basic types and basic value literals. For completeness of the current article, these buint-in basic types are re-list here. Built-in string type: string. Built-in boolean type: bool. Built-in numeric types: int8, uint8 (byte), int16, uint16, int32 (rune), uint32, int64, uint64, int, uint, uinptr. float32, float64. complex64, complex128. [go101.org]

  > golang内置的基本类型包括：
  >
  > - 字符串类型：string
  > - 布尔类型：bool
  > - 数值类型：int8, uint8 (byte), int16, uint16, int32 (rune), uint32, int64, uint64, int, uint, uinptr，float32, float64, complex64, complex128

- Go supports following composite types: pointer types - C pointer alike. struct types - C struct alike. function types - functions are first-class types in Go. container types: array types - fixed-length container types. slice type - dynamic-length and dynamic-capacity container types. map types - maps are associative arrays (or dictionaries). The standard Go compiler implements maps as hashtables. channel types - channels are used to synchronize data among goroutines (the green threads in Go). interface types - interfaces play a key role in reflection and polymorphism.   [go101.org]

  > golang内置的复合类型包括：
  >
  > - 指针类型：pointer
  > - 结构体类型：struct
  > - 容器类型：array, slice, map, channel, interface

- In Go, we can define new types by using the following syntaxes. In the following example, type is a keyword. // Define a solo new type. type NewTypeName SourceType  // Define multiple new types together. type ( 	NewTypeName1 SourceType1 	NewTypeName2 SourceType2 )   New type names must be identifiers.  Note, a new defined type and its respective source type in type definitions are two distinct types. two different defined types are always two distinct types. the new defined type and the source type will share the same underlying type (see below for what are underlying types), and their values can be converted to each other. types can be defined within function bodies.   [go101.org]

  > golang里面如何将原类型定义为新类型，以及新类型与原类型之间的关系。

- Since Go 1.9, we can declare custom type alias by using the following syntaxes. The syntax of alias declaration is much like type definition, but please note there is a = in each type alias declaratio type ( 	Name = string 	Age  = int )  type table = map[string]int type Table = map[Name]Age   Type alias names must be identifers. Like type definitions, type aliases can also be declared within function bodies.  [go101.org]

  > "golang 1.9开始，支持定义类型别名，别名与源类型是同一种类型。"

- In Go, if a type has a name, which must be an identifier, and its name is not the blank identifier _, then this type is called a named type. All basic types are named types. if a type can't be represented by a pure identifier, then the type is an unnamed type. The composite types denoted by their respective type literals in the above example are all unnamed types.   An unnamed type must be a composite type, It is not true vice versa, for composite types may be defined types and alias types.  [go101.org]

  > "golang里面类型分为有名类型（有标识符来识别的）和无名类型（没标识符来识别的）。无名类型一定是复合类型，但是反之不成立。"

- In the following example. alias type C and type literal []string are both non-defined types, but type A and alias type B are both defined types. type A []string type B = A type C = []string  [go101.org]

  > "go101这个文章系列里面，将类型分为已定义的类型和未定义的类型，未定义的类型指的是无名类型的别名，或者在无名类型别名之上建立的类型。golang spec里面并没有这样的概念。"

- At run time, many values are stored somewhere in memory. In Go, each of such values has a direct part, however, some of them each has one or more indirect parts. Each value part occupies a continuous memory segment. The indirect underlying parts of a value are referenced by its direct part through pointers.  [go101.org]

  > "golang里面的有些值可以分为direct part、indirect part，比如slice实际上是有个slice header来表述slice当前的状态，这就是它的direct part，在这个结构体里面，有个指针elements指向存储数据的内置数组，这个内置数组就是indirect part。direct part中有个指针field来引用indirect part。 value part这不是golang spec里面定义的，是go101为了让gophers更加理解golang的类型系统所提出来的。"

- When a value is stored in memory, the number of bytes occupied by the direct part of the value is called the size of the value. All values of the same type have the same value size, so the size of values of a type is often called as the size, of value size, of the type. We can use the Sizeof function in the unsafe standard package to get the size of any value.  Go specification doesn't specify values size requirements for non-numeric types. The requirements for value sizes of all kinds of basic numeric types are listed in the article basic Types and basic value literals.  [go101.org]

  > "golang spec里面没有指明非数值类型的值所占用内存大小的计算规则，比如计算一个slice的大小，是只考虑slice header的大小，还是也要把indirect part对应的内置数组大小考虑进来。某类型对应的值的大小，实际上只考虑direct part的大小，换言之一个slice只考虑slice header的大小，比如unsafe.Sizeof可以计算出值的大小，它计算的也只是direct part。"

- The value boxed in an interface value is called the dynamic value of the interface value. The type of the dynamic value is called the dynamic type of the interface value. An interface value boxing nothing is a nil interface value.  [go101.org]

  > "非nil interface的值包括了两个重要部分，接口包括的动态值，以及该动态值的类型，称为接口的动态类型。这个可以在学习后面structs in go的时候了解到interface类型的结构定义，就更清楚这里的概念了。"

- The signature of a function type is composed of the input parameter definition list and the output result definition list of the function.  The function name and body are not parts of a function signature. Parameter and result types are important for a function signature, but parameter and result names are not important.  [go101.org]

  > "golang里面函数签名只包括入参列表、返回值列表，receiver type以及函数名、函数体都不是函数签名的一部分。在c、c++里面，函数签名包括函数名、参数列表，不包括返回值和函数体。二者之间有些差别，golang只限定入参列表、返回值列表。"

- In Go, some types can have methods. Methods can also be called member functions.  The methed set of a type is composed of all the methods of the type. If the method set of a type is the super set of the method set of an interface type, we say the type implements the interface type.  [go101.org]

  > "golang里面可以在某数据类型上定义方法，一个类型的所有方法构成方法集合；如果一个类型的方法集合实现了某个接口定义中的所有方法，就说该类型实现了这个接口。"

- A struct type is composed of a collection of member variables. Each of the member variables is called a field of the struct type.  [go101.org]

  > "struct就是一系列成员构成的符合类型，golang里面也借助struct定义了很多内置类型。"

- For a pointer type, assume its underlying type can be denoted as *T in literal, then T is called the base type of the pointer type.  [go101.org]

  > "golang中可以创建指针类型，指针类型指向的类型称为指针的基本类型，如ptr *T，ptr的基本类型就是T。"

- Array, slice and map can be viewed as formal built-in container types.  Informally, string and channel types can also be viewed as container types.  Each value of a container type has a length, either the container type is a formal one or an informal one.  [go101.org]

  > "golang里面，slice和map都是正儿八经的容器类型，其实string和channel也可以看作容器类型。每一个容器类型的值都有一个length属性。"

- If the underlying type of a map type can be denoted as map[Tkey]T, then Tkey is called the key type of the map type. Tkey must be a comparable type.  [go101.org]

  > "如果有个类型map[tkey]t，那么这个map的key类型就是tkey，tkey必须是可比较的。 在golang提供的内置类型里面，slice由于是间接的（浅拷贝），如果在slice[i]中存这个slice本身，并且将这个slice作为key就会导致比较时无穷递归，所以slice不能作为map的key，map与slice一样的道理也不能作为map的key；另外function也不能作为map的key。"

- Channel values can be viewed as synchronized first-in-first-out (FIFO) queues. Channel types and values have directions. A channel value which is both sendable and receivable is called a bidirectional channel. Its type is called a bidirectional channel type. Bidirectional channel types are denoted as chan T in literal. A channel value which is only sendable is called a send-only channel. Its type is called a send-only channel type. Send-only channel types are denoted as chan<- T in literal. A channel value which is only receivable is called a receive-only channel. Its type is called a receive-only channel type. Receive-only channel types are denoted as <-chan T in literal.   [go101.org]

  > "golang中的chan类型和值是有方向的，根据是否可读可写，可以分为双向chan、发送chan、接收chan。"

- Currently (Go 1.10), following types don't support comparisons (with the == and != operators): slice types map types function types any struct type with a field whose type is uncomparable and any array type which element type is uncomparable.   [go101.org]

  > "golang里面slice、map、function是属于不可比较的类型，编译器会报错，这也是为什么不能将其用作map的key的原因（map的key类型要求可比较）。另外某些符合类型如果包括了这样的不可比较类型，那么这个符合类型也是不可比较的。"

- Go is not a full featured object-oriented programming language, but Go really supports some object-oriented programming styles. Please read the following listed articles for details: methods in Go. implementations in Go. type embedding in Go.   [go101.org]

  > "golang并不完全支持OO的所有特性，但是它确实提供了一些OO的特性，可以学习下golang中方法的定义、接口实现、类型嵌套相关的内容。"

- The generic functionalities in Go are limited to built-in types and functions. Up to now (v1.10), Go doesn't support generic for custom types and custom functions. Please read built-in generic in Go for details.  [go101.org]

  > "golang里面的范型支持，是有的，但是只限于内置类型以及内置函数中。也就是说直到golang 1.10，go仍然不支持自定义类型、函数上的范型。"