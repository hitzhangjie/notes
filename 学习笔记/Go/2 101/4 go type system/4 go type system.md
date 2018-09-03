
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

  >"golang里面类型分为有名类型（有标识符来识别的）和无名类型（没标识符来识别的）。无名类型一定是复合类型，但是反之不成立。"

- In the following example. alias type C and type literal []string are both non-defined types, but type A and alias type B are both defined types. type A []string type B = A type C = []string  [go101.org]

	>"go101这个文章系列里面，将类型分为已定义的类型和未定义的类型，未定义的类型指的是无名类型的别名，或者在无名类型别名之上建立的类型。golang spec里面并没有这样的概念。"

- At run time, many values are stored somewhere in memory. In Go, each of such values has a direct part, however, some of them each has one or more indirect parts. Each value part occupies a continuous memory segment. The indirect underlying parts of a value are referenced by its direct part through pointers.  [go101.org]

	>"golang里面的有些值可以分为direct part、indirect part，比如slice实际上是有个slice header来表述slice当前的状态，这就是它的direct part，在这个结构体里面，有个指针elements指向存储数据的内置数组，这个内置数组就是indirect part。direct part中有个指针field来引用indirect part。 value part这不是golang spec里面定义的，是go101为了让gophers更加理解golang的类型系统所提出来的。"

- When a value is stored in memory, the number of bytes occupied by the direct part of the value is called the size of the value. All values of the same type have the same value size, so the size of values of a type is often called as the size, of value size, of the type. We can use the Sizeof function in the unsafe standard package to get the size of any value.  Go specification doesn't specify values size requirements for non-numeric types. The requirements for value sizes of all kinds of basic numeric types are listed in the article basic Types and basic value literals.  [go101.org]

	>"golang spec里面没有指明非数值类型的值所占用内存大小的计算规则，比如计算一个slice的大小，是只考虑slice header的大小，还是也要把indirect part对应的内置数组大小考虑进来。某类型对应的值的大小，实际上只考虑direct part的大小，换言之一个slice只考虑slice header的大小，比如unsafe.Sizeof可以计算出值的大小，它计算的也只是direct part。"

- The value boxed in an interface value is called the dynamic value of the interface value. The type of the dynamic value is called the dynamic type of the interface value. An interface value boxing nothing is a nil interface value.  [go101.org]

	>"非nil interface的值包括了两个重要部分，接口包括的动态值，以及该动态值的类型，称为接口的动态类型。这个可以在学习后面structs in go的时候了解到interface类型的结构定义，就更清楚这里的概念了。"

- The signature of a function type is composed of the input parameter definition list and the output result definition list of the function.  The function name and body are not parts of a function signature. Parameter and result types are important for a function signature, but parameter and result names are not important.  [go101.org]

	>"golang里面函数签名只包括入参列表、返回值列表，receiver type以及函数名、函数体都不是函数签名的一部分。在c、c++里面，函数签名包括函数名、参数列表，不包括返回值和函数体。二者之间有些差别，golang只限定入参列表、返回值列表。"

- In Go, some types can have methods. Methods can also be called member functions.  The methed set of a type is composed of all the methods of the type. If the method set of a type is the super set of the method set of an interface type, we say the type implements the interface type.  [go101.org]

	>"golang里面可以在某数据类型上定义方法，一个类型的所有方法构成方法集合；如果一个类型的方法集合实现了某个接口定义中的所有方法，就说该类型实现了这个接口。"

- A struct type is composed of a collection of member variables. Each of the member variables is called a field of the struct type.  [go101.org]

	>"struct就是一系列成员构成的符合类型，golang里面也借助struct定义了很多内置类型。"

- For a pointer type, assume its underlying type can be denoted as *T in literal, then T is called the base type of the pointer type.  [go101.org]

	>"golang中可以创建指针类型，指针类型指向的类型称为指针的基本类型，如ptr *T，ptr的基本类型就是T。"

- Array, slice and map can be viewed as formal built-in container types.  Informally, string and channel types can also be viewed as container types.  Each value of a container type has a length, either the container type is a formal one or an informal one.  [go101.org]

	>"golang里面，slice和map都是正儿八经的容器类型，其实string和channel也可以看作容器类型。每一个容器类型的值都有一个length属性。"

- If the underlying type of a map type can be denoted as map[Tkey]T, then Tkey is called the key type of the map type. Tkey must be a comparable type.  [go101.org]

	>"如果有个类型map[tkey]t，那么这个map的key类型就是tkey，tkey必须是可比较的。 在golang提供的内置类型里面，slice由于是间接的（浅拷贝），如果在slice[i]中存这个slice本身，并且将这个slice作为key就会导致比较时无穷递归，所以slice不能作为map的key，map与slice一样的道理也不能作为map的key；另外function也不能作为map的key。"

- Channel values can be viewed as synchronized first-in-first-out (FIFO) queues. Channel types and values have directions. A channel value which is both sendable and receivable is called a bidirectional channel. Its type is called a bidirectional channel type. Bidirectional channel types are denoted as chan T in literal. A channel value which is only sendable is called a send-only channel. Its type is called a send-only channel type. Send-only channel types are denoted as chan<- T in literal. A channel value which is only receivable is called a receive-only channel. Its type is called a receive-only channel type. Receive-only channel types are denoted as <-chan T in literal.   [go101.org]

	>"golang中的chan类型和值是有方向的，根据是否可读可写，可以分为双向chan、发送chan、接收chan。"

- Currently (Go 1.10), following types don't support comparisons (with the == and != operators): slice types map types function types any struct type with a field whose type is uncomparable and any array type which element type is uncomparable.   [go101.org]

	>"golang里面slice、map、function是属于不可比较的类型，编译器会报错，这也是为什么不能将其用作map的key的原因（map的key类型要求可比较）。另外某些符合类型如果包括了这样的不可比较类型，那么这个符合类型也是不可比较的。"

- Go is not a full featured object-oriented programming language, but Go really supports some object-oriented programming styles. Please read the following listed articles for details: methods in Go. implementations in Go. type embedding in Go.   [go101.org]

	>"golang并不完全支持OO的所有特性，但是它确实提供了一些OO的特性，可以学习下golang中方法的定义、接口实现、类型嵌套相关的内容。"

- The generic functionalities in Go are limited to built-in types and functions. Up to now (v1.10), Go doesn't support generic for custom types and custom functions. Please read built-in generic in Go for details.  [go101.org]

	>"golang里面的范型支持，是有的，但是只限于内置类型以及内置函数中。也就是说直到golang 1.10，go仍然不支持自定义类型、函数上的范型。"

# Pointers

- A memory address means an offset (number of bytes) from the start point of the whole memory managed by a system (generally, operation system).  Generally, a memory address is stored as an unsigned native (interger) word. The size of a native word is 4 (bytes) on 32-bit architectures and 8 (bytes) on 64-bit architectures. So the theoretical maximum memory space size is 232 bytes, a.k.a. 4GB (1GB == 230 bytes), on 32-bit architectures, and is 234GB (16 exibytes) on 64-bit architectures.  [go101.org]

	>"内存地址指的一个相对于系统管理内存起始地址的偏移量，对于一个处理器，其可寻址的内存地址空间是固定的，内存地址位宽必须要与处理器设计对齐，保证可以寻址与处理器一致的可寻址内存地址空间。"

- The address of a value means the start address of the memory segment occupied by the direct part of the value.  [go101.org]

	>"对于一个值value的地址，往往指的是这个value的direct part的起始地址。"

- A pointer is a special value, which can storage a memory address. In fact, we often call a memory address as a pointer, and vice versa.  Generally, the stored memory address in a pointer is the address of another value. Unlike C language, for safety reason, there are some restrictions made for Go pointers. Please read the following sections for details.  [go101.org]

	>"指针是存储内存地址的特殊类型，c、c++里面对指针不加限制，golang希望保证指针操作的安全性，对指针加了一些限制，比如不允许对指针进行计算，但是为了保证一定的灵活性，unsafe.Pointer提供了类似void *一样的指针计算能力。"

- We can declare named pointer types, but generally this is not recommended. Unnamed pointer types have better readabilities than named ones.  [go101.org]

	>"对于指针类型，更加推荐使用无名指针类型，因为这样代码可读性更强。"

- There are two ways to get a non-nil pointer value. The built-in new function can be used to allocate memory for a value of any type. new(T) will allocate memory for a T value and return the address of the T value. The allocated value is a zero value of type T. The returned address is viewed as a pointer value of type *T. We can also take the addresses of some values in Go. Values can be taken addresses are called addressable values. For an addressable value t of type T, we can use the expression &t to take the address of t, where & is the operator to take value addresses. The type of &t is viewed as *T.   All variables are addressable and all constants are unaddressable.  [go101.org]

	>"golang里面如何获得一个value的指针呢？有两种方式，一种是通过new(T)来获得类型T的指针，一种是通过对可寻址的value进行取地址运算&amp;value。与c、c++关键字new不同，golang里的new并不限定分配的内存空间是一定在heap里面，也可能在栈上。另外，变量一定是可寻址的，常量一定是不可寻址的。"

- Given a pointer value p of type Tp, how to get the value at the address stored in the pointer? Just use the expression *p, where * is called dereference operator. *p is call the dereference of poiner p. Pointer dereference is the inverse process of address taking. The result of *p is a value of the base type of Tp.  [go101.org]

	>"如何解除指针的引用，指针解引用相对于取地址运算来说是个相反的过程，跟c、c++类似，对于指针p，可以通过*p解引用。"

- Unlike C language, Go is a language supporting garbage collection, so return the address of a local variable is absolutely safe in Go.  [go101.org]

	>"golang编译器会根据对变量的逃逸分析决定是把变量分配在stack上海市heap上，在c、c++里面返回函数局部变量的指针是有问题的，解引用时变量已经被销毁。但是在golang里面，返回局部变量的指针是完全没问题的，因为逃逸的局部变量是被分配在heap上的。"

- Restrictions On Pointers In Go  For safety reasons, Go makes some restrictions to guarantee pointers in Go are always legal and safe. By applying these restrictions, Go keeps the benefits of pointers, and avoids the dangerousness of pointers at the same time.  [go101.org]

	>"golang希望保留指针的优势，去掉指针危险的一面，因此对指针加了一些限制：1）不允许对指针进行算术运算 2）某类型的指针值不允许转换成任意其他指针类型 3）某类型的指针值不允许与其他任意指针类型做比较 4）某类型的指针值不允许为其他任意指针类型赋值。尽管golang加了如下限制，但是unsafe package也提供了unsafe.Pointer可以允许你像c、c++中一样灵活地使用指针，从而绕过golang这里的限制。"

# Structs

- Consecutive fields with the same type can be declared together. struct { 	title, author string 	pages         int }  [go101.org]

	>"定义struct时，连续的字段如果类型相同，可以在同一行进行定义。"

- The size of a struct type is the sum of the sizes of all its field types. The size of a zero-field struct type is zero.  [go101.org]

	>"struct定义中如何没有包含任何field，这么这个struct实例的大小为0，unsafe.Sizeof返回0。unsafe.Sizeof注释提到这个函数不返回这个参数结构体中引用的其他内存空间，对于一个空的struct来说，很可能其内部表示是空的。"

- Each struct field can be bound with a tag when it is declared. Field tags are optional, the default value of each field tag is a blank string. Here is an example showing non-default field tags. struct { 	Title  string `json:"title"` 	Author string `json:"author,omitempty"` 	Pages  int    `json:"pages,omitempty"` }  [go101.org]

	>"struct中每个field可以为其指定tag，注释最好不要讲tag当做字段的注释来使用。tag默认为空串。在使用encoding/json进行marshal、unmarshal的时候这个tag是很有用的，比如字段名为大写的Title，如果指定了tag `json:"title"`，那么编码成json时字段名就是title，否则就与字段名相同；解码json的时候，如果有tag，就会假定json中字段名是title而非Title。"

- Given a struct type S and assume it has two fields, x int and y bool in order, then the zero value of S can be represented by the following two variants of struct composite literal forms: S{0, false}. In this form, none field names are present but all field values must be present by the field declaration orders. S{x: 0, y: false}, S{y: false, x: 0}, S{x: 0}, S{y: false} and S{}. In this form, each field item is optional to be present. The values of the absent fields will be set as the zero values of their respective types. But if a field item is present, it must be presented with the FieldName: FieldValue form. The order of the field items in this form doesn't matter. The zero value form S{} is used most often in practice.   If S is a struct type imported from library packages, it is recommended to use the second form, for the library maiatainers may add fields for the type S later, which will make the uses of first forms become invalid.  [go101.org]

	>"结构体初始化的方式有两种：
	>1）不指定字段名，但是需要按照结构体中字段定义顺序依次、全部提供字段的初始值 
	>2）指定字段名，可以只提供某几个字段的初始值。
	>如果引用的struct类型是从其他package import进来的，最好使用第二种初始化方式，因为packge的维护人员可能会在原有代码的基础上扩充struct的字段，万一调整了字段顺序，或者是在原有字段之间插入其他字段，使用第一种初始化方式的话势必会引入bug。"

- The last , in a compoiste literal is optional if the last item in the literal and the closing } are at the same line. Otherwise, the last , is required. (For more details, please read line break rules in Go.)  var _ = Book { 	author: "Go 101", 	pages: 256, 	title: "Go 101", // here, the "," can not be ommitted. }  // The last "," in the following line can be ommitted. var _ = Book{author: "Go 101", pages: 256, title: "Go 101",}  [go101.org]

	>"struct字段初始化的时候，为了可读性，有时会一行只初始化一个字段，每个字段后都需要加一个逗号。这里要注意的是golang里面的breakline rules，因为不需要程序员自己手动插入分号作为语句的结束，实际上是编译器来做的这个自动插入分号的工作，那么编译器如何判断是否该插入一个换行符呢？规则有好几条，但是我们只要记住什么时候可以换行就可以了，只在二元操作符、成员操作符.、赋值=、左半开括号后换行就不会有breakline问题。"

- Generally, only addressable values can be taken addresses. But there is a syntax sugar in Go, which allows us to take addesses on composite literals. A syntax sugar is an exception in syntax to make programming convenient.  [go101.org]

	>"一般地只有可寻址的value才可以对其进行取地址运算，golang增加了一种语法糖，允许对复合类型字面量进行取地址运算。如type struct Book{}; b := &amp;Book{}。这种对复合类型字面量进行取地址运算的方式，同样适用于对map、slice。"

- Unlike C, in Go, there is not the -> operator for accessing struct fields through struct pointers. In Go, the struct field acceessment operator for struct fields is also the dot sign ..  [go101.org]

	>"golang里面访问struct中的field使用成员操作符"."，而不是-&gt;。golang里面没有-&gt;这个运算符。"

- Struct Value Conversions  [go101.org]

  >"struct结构体类型转换，必须满足对应字段名称相同、类型相同、tag相同。"

# Value Parts

- Each values of the these kinds of types is often composed of one direct part and one or several underlying indirect parts, and the underlying value part is referenced by the direct value part. The following picture dipicts a mult-part value.    [go101.org]

	>"golang里面的数据类型可以分为两类，一类是只包括direct value part的数据类型，这部分对应于c风格中的一些数据类型如book、数值、数组、unsafe.Pointer等，另一类是包括direct value part和indirect value part这两部分的数据类型，其中indirect value part由direct value part引用，包括slice、map、chan、func、interface、string等。"

- We have learned Go pointers in the last article. The pointer types in that article are type-safe pointer types. In fact, Go also supports type-unsafe pointer types. The unsafe.Pointer type provided in the unsafe standard package is like void* in C language. Types whose underlying types are unsafe.Pointer are called unsafe pointer types in Go 101.  [go101.org]

	>golang支持两种类型的指针，一种是安全的，一种是不安全的。前一种就是说go对指针增加了各种安全限制的指针，后一种就是说的unsafe.Pointer指针。

- Internal Definitions Of Map, Channel And Function Types  The internal definitions of map, channel and function types are similar: // map types type _map *hashtableImpl // currently, for the standard Go compiler,                          // Go maps are hashtables actually.  // channel types type _channel *channelImpl  // function types type _function *functionImpl So, internally, types of the three families are just pointer types. The zero values of these types are all represented by the predeclared nil identifier. For any non-nil value of these types, its direct part (a pointer) references its indirect underlying implementation part.  In fact, the indirect underlying part of a value of the three kinds of types may also reference deeper indirect underlying parts.    [go101.org]

	>map、chan、func属于引用类型，其类型定义本质上是有名指针类型。slice也属于引用类型，但是一个slice是通过slice header来唯一确定的，为什么slice不定义成一个有名指针类型呢？这是因为slice要实现底层内存空间的共享，为了实现多个slice对底层内存空间的共享就只能分别通过各自的slice header来引用该底层内存空间，只是各个slice header的不同cap、len限定了访问内置数组的不同range。

- Internal Definition Of Slice Types  The internal definition of slice types is like: // slice types type _slice struct { 	elements unsafe.Pointer // underlying elements 	len      int            // number of elements 	cap      int            // capacity }   [go101.org]

	>"slice的内部定义，slice内部的elements是其存储数据的内置数组，len、cap限定了当前range可以访问的内置数组的range。通过一个slice可以衍生出其他的slice，其实就是对应的slice header里面cap、len设置了不同的值。"

- Internal Definition Of String Types  Below is the internal definition for string types: // string types type _string struct { 	elements *byte // underlying bytes 	len      int   // number of bytes }   [go101.org]

	>"string类型的定义，其实也是一个指针wrapper类型的struct。"

- Internal Definition Of Interface Types  Below is the internal definition for general interface types: // general interface types type _interface struct { 	dynamicType  *_type         // the dynamic type 	dynamicValue unsafe.Pointer // the dynamic value } Internally, interface types are also pointer wrapper struct types. The internal definition of an interface type has two pointer fields. The zero values of interface types are also represented by the predeclared nil identifier. Each non-nil interface value has two indirect underlying parts which store the dynamic type and dynamic value of that interface value. The two indirect parts are referenced by the dynamicType and dynamicValue fields of that interface value.  In fact, for the standard Go compiler, the above definition is only used for blank interface types. Blank interface types are the interface types which don't specify any methods. We can learn more about interfaces in the article interfaces in Go later. For non-blank interface types, a definition like the following one is used. // general interface types type _interface struct { 	dynamicTypeInfo *struct { 		dynamicType *_type       // the dynamic type 		methods     []*_function // implemented methods 	} 	dynamicValue unsafe.Pointer // the dynamic value } The methods field of the dynamicTypeInfo field of an interface value stores the implemented methods of the dynamic type of the interface value for the (interface) type of the interface value.    [go101.org]

	>"interface也是引用类型，本质上它也是指针wrapper的struct，对于一个空的interface定义而言，通过type _interface struct {*_type, unsafe.Pointer}这样的结构体来对其进行描述就足够了，只需要在两个字段中记录引用的动态类型指针、动态类型值就足够了。对于定义了方法的interface来说，除了上述内容，还需要定义这个动态类型中对接口方法的实现的func的指针。因此有接口方法的interface，需要下面这个结构体来定义。"

- Now we have learned that the internal definitions of the types in the second category are either pointer types or struct types. Certainly, Go compilers will never view the types in the second category as pointer types or struct types in user programs. These definitions are just used internally by Go runtimes.  [go101.org]

	>"前面描述了golang里面第二类数据类型的定义方式，要么是指针，要么是指针wrapper struct。当然了，golang的编译器并不会将用户程序中的第二类数据类型看做是指针类型或者struct类型，这些定义只是在golang运行时内部使用时使用。"

- In Go, each value assignment (including parameter passing, etc) is a shallow value copy if the involved destination and source values have the same type (if their types are different, we can think that the source value will be implicitly converted to the destination type before doing that assignment). In other words, only the direct part of the soruce value is copied to the destination value in an value assignment. If the source value has underlying value part(s), then the direct parts of the destination and source values will reference the same underlying value part(s), in other words, the destination and source values will share the same underlying value part(s).    [go101.org]

	>"golang里面的赋值操作，都是对数据类型对应值中的direct value part进行shadow copy，值中包括indirect value part的部分并不会进行拷贝。这意味着如果一个value包括了indirect value part，value1赋值给value2之后，value1和value2将引用相同的indirect value part。"

- Since an indirect underlying part may not belong to any value exclusively, it doesn't contribute to the size returned by the unsafe.Sizeof function.  [go101.org]

	>"为什么unsafe.Sizeof只返回value中的direct value part部分的内存空间大小，却不返回indirect value part部分的内存空间大小呢？以slice为例，多个slice可能引用相同的内部存储结构，同一个内部存储结构并不是排他性的属于某一个slice，因此unsafe.Sizeof不会将indirect value part计算在内。"

# Arrays, Slices, and Maps

- Each element in a container has an associated key. An element value can be accessed through its associated key. The key types of map types must be comparable types. The key types of array and slice types are all the built-in type int. The keys of the elements of an array or slice are non-negative integers which mark the positions of these elements in the array or slice. The non-negative integer keys are often called indexes.  [go101.org]

	>"容器类型中的每个元素都有一个关联的key，可以借助这个key来访问元素。key必须是可比较的类型，对于map来说，key的类型只要是可比较类型就可以，对于array、slice来说，key是非负整数，其实就是索引值index。"

- Each container value has a length, which indicates how many elements are stored in that container. The valid range of the integer keys of an array or slice value is from zero (inclusive) to the length (exclusive) of the array or slice. For each value of a map type, the key values of that map value can be an arbitrary value of the key type of the map type.  [go101.org]

	>"每种类型的container value都有一个length属性来表示容器中包括的元素的数量。"

- There are also many differences between the three kinds of container types. Most of the differences originate from the differences between the value memory layouts of the three kinds of types. From the last article, value parts, we learned that an array value is composed of only one direct part, however a slice or map value may have an underlying part, which is referenced by the direct part of the slice or map value.  [go101.org]

	>"array、slice、map虽然同属container类型，但是存在一些不同之处，例如array只包括direct value part，但是slice、map还包括了indirect value part。"

- We can access an element through its key. The time complexities of element accessments on all container values are all O(1), though, generally map element accessments are several times slower than array and slice element accessments.  [go101.org]

	>"array、slice支持随机访问，其key也就是索引index，访问指定key是O(1)的时间复杂度，对于map，因为其采用哈希桶算法，时间复杂度接近O(1)。"

- Compisite Literals Are Unaddressable But Can Be Taken Addresses  Compisite Literals are unaddressable values. We have learned that struct composite literals can be taken addresses directly before. Container composite literals have no exceptions here.    [go101.org]

	>"array、slice、map复合类型字面量是不可寻址的，但是允许对其进行取地址运算，这个跟struct字面量类似，也是一种语法糖。"

- pa := &[...]bool{false, true, true, false}  [go101.org]

  >"定义一个数组类型的时候一般是用[N]type来定义，如果这里的N不想手工指定，而是想让编译器自动进行推断的话，可以这样来声明[...]type{v1,v2,...}。"

- Nested Composite Literals Can Be Simplified  If a composite literal nested many other composite literals, then those nested composited literals can simplified to the form {...}.    [go101.org]

	>"如果一个复合类型字面量嵌套了其他的复合类型字面量，那么这些被嵌套的复合类型字面量可以被简化成{...}这种形式。"

- Compare Container Values  As which has mentioned in the article overview of Go type system, map and slice types are uncomparable types. So map and slice types can't be used as map key types.  Although a slice or map value can't be compared with another slice or map value (or itself), it can be compared to the bare untyped nil identifier to check whether or not the slice or map value is a zero value.  Most array types are comparable, except the ones whose element types are uncomparable types.  When comparing two values of the same array type, each of their elements will be compared. The two array values are equal only if all of their corresponding elements are equal.  [go101.org]

	>"container value的比较：
	>1）map、slice是不可比较类型，其内部存储的元素可以是其自身（如type T = map[interface{}]interface{}，var XX T; xx[T] = T;，这会导致无穷递归。尽管map、slice是不可比较类型但是其可以与字面量nil进行比较。
	>2）array中如果包括了不可比较类型的元素的话，那么这个array也是不可比较的；两个array钟存储的元素完全相同时，两个array才算是相同。"

- Access And Modify Container Elements  The element associated to key k stored in a container value v can be represented with the syntax form v[k].    [go101.org]

	>"访问和修改container（包括array、slice、map）中的元素都是通过如下这个统一的形式 v[k] 进行的，其中v代表一个container value，k代表key，对于array，k是非负且小于array长度的整数值；对于slice也是；对于map，k是kv键值对中的k。"

- Container Assignments  If a map is assigned to another map, then the two maps will share all (underlying) elements.  Like map assignments, if a slice is assigned to another slice, they will share all (underlying) elements.  When an array is assigned to another array, all the elements are copied from the source one to the destination one. The two arrays don't share any elements.    [go101.org]

	>"容器赋值操作，将一个map赋值给另一个map，这两个map将共享相同的内部存储，将一个slice赋值一个slice也是这样，这与map和slice的类型定义有关。将一个数组赋值给另一个数组是会拷贝数组元素到另一个数组，两个数组不共享内部存储。"

- Check Lengths And Capacities Of Container Values  Besides the length property, each container value also has a capactiy property. The capacity of an array is always equal to the length of the array. The capacity of a map is unlimited. So, in practice, only capacities of slice values are meaningful. The capacity of a slice is always equal to or larger than the length of the slice.  [go101.org]

	>"container value除了length属性以外，还有一个属性capacity，数组的capacity等于length，map的capacity是无上限的，只有slice的capacity在实际开发中才有意义，slice的capacity大于等于其length。"

- We can use the built-in len function to get the length of a container value, and use the built-in cap function to get the capacity of a container value.  [go101.org]

	>"实际测试发现，无法通过函数cap对map计算容量，编译会报错；但是可以通过函数cap对array和slice计算容量。"

- func main() { 	s0 := []int{2, 3, 5} 	s1 := append(s0, 7)      // append one element 	s2 := append(s1, 11, 13) // append two elements 	fmt.Println(s0, cap(s0)) // [2 3 5] 3 	fmt.Println(s1, cap(s1)) // [2 3 5 7] 6 	fmt.Println(s2, cap(s2)) // [2 3 5 7 11 13] 6 	s3 := append(s0)         // <=> s3 := s0 	s4 := append(s0, s0...)  // append all elements of s0 	fmt.Println(s3, cap(s3)) // [2 3 5] 3 	fmt.Println(s4, cap(s4)) // [2 3 5 2 3 5] 6 	s0[0], s1[0] = 99, 789 	fmt.Println(s2[0], s3[0], s4[0]) // 789 99 2 }  [go101.org]

	>"slice在append的时候如果空间不够了就会按照内置数组容量翻倍的规则取开辟新的slice空间，原来的slice header指向的数组如果仍然被引用的话不会被释放。结合这里的测试代码以及下面的slice空间分配示意图体会一下这里slice header中各个字段的变化。"

- So, s1 and s2 share some elements, s0 and s3 share all elements, and s4 doesn't share elements with others. The following picture depicted the memory layouts of these slices at the end of the above program.    [go101.org]

	>"结合示意图、上方的源代码来学习下对slice执行append操作时slice header中各个字段的变化情况。"

- Create Slices And Maps With The Built-in make Function  Besides using composite literals to create map and slice values, we can also use the built-in make function to create map and slice values. The built-in make function can't be used to create array values.    [go101.org]

	>"除了使用复合类型字面量来创建map、slice，也可以通过golang内置的make来创建。使用make创建时，注意可以指定容纳至少n个元素的map，如make(M, n)也可以让golang自己管理make(M)；对于slice可以指定最大capacity，如make([]int, 16)，也可以不指定，如make([]int)。"

- Allocate Containers With The Built-in new Function  From the article pointers in Go, we learned that we can also call the built-in new function to allocate a value of any type and get a pointer which references the allocated value. The allocated value is a zero value of its type. For this reason, it is a nonsense to use new function to create map and slice values.  It is not totally a nonsense to allocate a zero value of an array type with the built-in new fucntion. However, it is seldom to do this in practice    [go101.org]

	>"对于创建container value，使用复合类型字面量、make函数这两种方式更加常见，new不适合创建复合类型字面量。new(type)会分配一块type类型的内存空间，并将这段内存初始化为0值，对于符合类型来说，其底层表示归根结底是struct这样的结构体，将各个字段初始化为0值之后对我们来说没有任何意义。所以不要使用new来创建container value。"

- Derive Slices From Arrays And Slices  We can derive a new slice from an array or slice by using the subslice syntax forms. The elements of the derived slice and the base array or slice are hosted on the same underlying continuous memory segment. In other words, the derived slice and the base array or slice may share some contiguous elements.  There are two subslice syntax forms (baseContainer is an array or slice): baseContainer[low : high]       // two-index form baseContainer[low : high : max] // three-index form   [go101.org]

	>"通过一个array或slice得到其子slice，有如下两种形式可共使用。其中必须满足low &lt;= high &lt;= max &lt;= cap(baseContainer)，否则会panic。"

- Copy Slice Elements With The Built-in copy Function  We can use the built-in copy function to copy elements from one slice to another, the types of the two slices are not required to be identical, but their element types must be identical. The first argument of the copy function is the destination slice and the second one is the source slice. The two arguments can overlap some elements. The copy function returns the number of elements copied, which will be the smaller one of the lengths of the two arguments.  With the help of the subslice syntax, we can use the copy function to copy elements between two arrays or between an array and a slice.    [go101.org]

	>"通过内置的copy函数可以将一个slice钟的元素拷贝到另一个slice中去，允许dest、src slice存在内置数组的重叠部分，拷贝的元素数量是dest、src slice二者中length的最小值。"

- Container Element Iterations  In Go, keys and elements of a container value can be iterated with the following syntax:  for key, element = range aContainer { 	// use key and element ... }   [go101.org]

	>"对于container value中元素的遍历操作，可以使用这种形式，for key, element := range aContainer {...}，对于array、slice而言key就是idx，val就是element，对于map而言key就是kv键值对中的key，v就是element。迭代的时候其实可以直接把element给省略掉，编程这种形式for key := range aContainer {...}，然后可以借助key来访问对应的element。对于 for-range aContainer {...} 迭代形式，有一个非常重要的点提一下，这里的for-range迭代的实际上是变量aContainer的拷贝（拷贝aContainer的direct value part），所以对于一个数组其实就是一份完整的拷贝，对于slice或map拷贝其direct value part。for-range一个数组的时候最好传递数组的指针或者数组的subslice。"

- If the second iteration is neither ignored nor omitted, then range over a nil array pointer will panic. In the following example, each of the first two loop blocks will print five indexes, however, the last one will produce a panic.  [go101.org]

	>"遍历的aContainer如果是nil，那么for-range迭代的时候不可以获取key-element pair中的element，但是尅获取key。否则会panic。"

- The memclr Optimization  Assume t0 is a literal presentation of the zero value of type T, and a is an array which element type is T, then the standard Go compiler will translate the following one-iteration-variable for-range loop block for i := range a { 	a[i] = t0 } to an internal memclr call, generally which is faster than resetting each element one by one.  The optimization also works if the ranged container is a slice. Sadly, it doesn't work if the ranged value is an array pointer (up to Go 1.10). So if you want to reset an array, don't range its pointer. In particular, it is recommended to range a slice derived from the array  [go101.org]

	>"memclr，memory clear操作，当使用for-range迭代一个slice时，使用t0为slice中的元素赋值，编译器会将其当做一个优化标识，通过memclr来快速将slice内存清零。这只是编译器对此提供的一种优化方式，只对slice有效，并且并不是标准的gc里提供的，比如我在OS X golang1.10下测试就没有t0这个变量。"

- Calls To The Built-in len And cap Functions May Be Evaluated At Compile Time  If the argument passed to a built-in function len or cap function call is an array or an array pointer value, then the call is evaluated at compile time and the ressult of the call is a typed constant with default type as the built-in type int.    [go101.org]

	>"在某些container value上调用len或cap，如果该container value是数组类型的话，因为数组类型在定义的时候已经指定了length，而且数组的capacity==length，所以编译时就可以确定len、cap无需运行时推断。"

- Modify The Length And Capacity Properties Of A Slice Individually  As above has mentioned, generally, the length and capacity of a slice value can't be modified individually. A slice value can only be overwritten as a whole by assigning another slice value to it. However we can modify the length and capacity of a slice individually by using reflections.  Example: package main  import ( 	"fmt" 	"reflect" )  func main() { 	s := make([]int, 2, 6) 	fmt.Println(len(s), cap(s)) // 2 6 	 	reflect.ValueOf(&s).Elem().SetLen(3) 	fmt.Println(len(s), cap(s)) // 3 6 	 	reflect.ValueOf(&s).Elem().SetCap(5) 	fmt.Println(len(s), cap(s)) // 3 5 } [go101.org]

	>"可以借助reflect包手动修改slice header中的字段值，这里举了个例子来修改slice header中的length和capacity。"

- Go doesn't support more slice operations, such as slice clone, element deletion and insertion, in the built-in way. We must compose the built-in ways to achieve those operations.

	>"go没有再提供其他内置的slice操作了，如slice的clone、元素删除、元素插入，但是这些操作可以死通过简单组合现有的slice内置操作来实现。"

- Go doesn't support built-in set types. However, it is easy to use a map type to simulate a set type. In practice, we often use the map type map[K]struct{} to simulate a set type. The size of the map element type struct{} is zero, elements of values of such map types don't occupy memory space.

	>"golang并没有支持内置的set类型，但是通过使用map以及基于struct{}字面量size==0这样的事实，也可以很方便地定义出set类型，如type set map[K]struct{}。"

- Please note that, all container operations are not synchronized interally. Without making using of any data synchronization technique, it is okay for multiple goroutines to read a container concurrently, but it is not okay for multiple goroutines to maniluplate a container concurrently and at least one goroutine modifies the container. The latter case will cause data races, even make goroutines panic. We must synchronize the container operations manually.

	>"container相关的操作内部都是没有同步措施的，如果多个goroutine同时对一个container value执行read操作的话，这样是没有问题的，但是如果某个goroutine来执行写操作，其他的多个goroutine执行读操作，这种情况可能会引发data race，甚至导致goroutine panic。如果存在读写并发访问container value的情况，就需要借助sync包等对其进行同步控制。"

# Strings

- String datatype in Go
	>"string类型定义，其内部包括起始byte指针以及bytes数量len。
	>type _string struct { 	
    	elements *byte // underlying bytes 	
    	len      int   // number of bytes 
	}"

- String features in Go
	>"string类型的特点：
	>1）string可被用作常量；
	>2）go支持双引号和反引号括起来的两种形式的字符串，前者可以带转义字符，后者表示的字符串是所见即所得，不存在转义；
	>3）string的零值是空串；
	>4）可以通过+或者+=进行字符串连接；
	>5）可以通过==或者!=进行比较，也可以通过&gt;,&lt;,&gt;=或&lt;=进行大小比较；"

- More facts about string types and values in Go
	>"string的其他特性：
	>1）像java中的string一样，string一旦创建就是不可变的，包括内部的elements和len都是不可以单独修改的，只能通过赋值操作来修改；
	>2）string类型没有实现方法，但是可以通过strings这个package来对其进行操作；string中的elements是不可寻址的，也不能对内部元素element[i]进行寻址，更无法修改；aString[i:j]可以用于创建一个子字符串；
	>3）标准的gc，字符串赋值操作后，src、dest string将共享相同的内部存储。"

- Each string is actually a byte sequence wrapper. So each rune in a string will be stored as one or more bytes (up to four bytes). For example, each English code point stores as one byte in Go strings, however each Chinese code point stores as three bytes in Go strings.  [go101.org]

  >"golang里面string实际上是封装了一个byte序列，string是utf-8编码的，每个utf8码点用rune表示（int32类型），一个rune占据一个或者多个byte。例如每个英文字符占据一个byte，每个中文字符占据3个byte。"

- Here introduces two more string related conversions rules in Go: a string value can be explicitly converted to a byte slice, and vice versa. A byte slice is a slice whose underlying type is []byte (a.k.a, []uint8). a string value can be explicitly converted to a rune slice, and vice versa. A rune slice is a slice whose underlying type is []rune (a.k.a, []int32).   [go101.org]

  >"string可以转换为[]byte、[]rune，反之也可以，如果要将一个[]byte转换成[]rune，需要借助string做中转。"

- Deep copy happens when a string is converted to a byte slice, or vice vesa

  >"注意，将string转换为[]byte时，实际上是深拷贝了string的elements中的byte序列；将[]byte转换为string时，也是深拷贝了一份[]byte到string的elements。深拷贝需要开辟新的内存空间，为什么要深拷贝呢？因为slice中的元素是可变的，但是string中的字符要求是不可变的，所以为了使用过程中不互相影响，只能新开辟一块新的内存来深拷贝。"

- Please note, for conversions between strings and byte slices, illegal UTF-8 encoded bytes are allowed and will keep unchanged. the standard Go compiler makes some optimiazations for some special cases of such conversions, so that the deep copies are not made. Such optimiazations will be introduced below.   [go101.org]

  >"注意string和[]byte之间的转换，非法的utf8编码bytes是允许的，转换过程中会保持不变；标准的恶go编译器会在上述转换发生时采取某些优化措施避免发生深拷贝（只是在某些特定情境下）。"

- How to convert between byte slices and rune slices
	>"[]byte和[]rune之间的相互转换不能通过显示类型转换来完成，可以通过三种方式完成：
	>1）借助string作为转换媒介来完成；
	>2）使用unicode/utf8这个package下的工具函数DecodeRune来完成；
	>3）使用bytes包下的Runes函数将[]byte转换成[]rune。其中第一种方式使用比较简单但是不够高效，涉及到内存深拷贝，后面两种用起来啰嗦，但是比较高效。这里是一个操作示例：
	>
	```
	s := "大家好,hello world"  	
	bs := []byte(s) 	
	fmt.Println(bs)  	
	rs := []rune(s) 	
	fmt.Println(rs)  	
	// 通过unicode/utf8下工具函数转换 	
	for idx := 0; idx &lt; len(bs); { 		
	   r, w := utf8.DecodeRune(bs[idx:]) 	
	   fmt.Printf("%v ", r) 		
        idx += w 	
	} 	
	fmt.Println()  	
	// 直接使用bytes包下Runes函数完成转换 
    fmt.Println(bytes.Runes(bs))
    ```

- Compiler Optimizations For Conversions Between Strings And Byte Slices
	>go v1.10会在如下场景下string和[]byte之间转换时做优化，避免转换过程中发生深拷贝:
	>1) a conversion (from string to byte slice) which follows the range keyword in a for-range loop.
	>2) a conversion (from byte slice to string) which is used as a map key. a conversion (from byte slice to string) which is used in a comparison.
	>3) a conversion (from byte slice to string) which is used in a string concatenation, and at least one of concatenated string values is a non-blank string constant.

- The for-range loop control flow applies to strings. But please note, for-range will iterate the Unicode code points (as rune values), instead of bytes, in a string. Bad UTF-8 encoding representations in the string will be interpreted as rune value 0xFFFD.  [go101.org]

  >"for-range遍历string时，for idx, c := range aString {...}，遍历时是按照utf8码点进行遍历的，其中的idx表示的是第几个byte，遍历过程中输出的idx不是连续的，因为utf8码点占据可能多个byte，c是对应的rune码点，通过string(c)将其当做字符串输出。"

- How to iterate bytes in a string?

  >for-range遍历string时是按照rune进行遍历的，那么如何按照byte进行遍历呢？因为len(aString)返回的aString中的byte的数量，因此可以借助一般形式的for循环for i:=0; i&lt;len(aString); i++ {...}，这样来按照byte进行遍历。

- How to concatenate strings?

  >string的连接操作，除了使用+之外，也可以使用fmt.Sprintf、strings.Join、bytes.Buffer、strings.Builder等来完成。strings.Builder相比于其他三种方式效率更高，因为它尽可能避免了存储result string时内置bytes数组的拷贝。

- Syntax Sugar: use string as byte slice

  >"这里有个语法糖，正常使用方式append(hello, []byte(world)...)，但是语法糖形式更精炼append(hello, world...)。"

- More about string comparisons

  >"字符串比较是比较内置数组中的byte序列是否完全相同，但是实际比较时，会采取其他优化措施，例如：如果两个字符串长度不同，那么肯定不同，没必要逐一比较内置bytes数组中的byte；再者，如果两个字符串指向的内置数组指针elements相同，那么说明其引用的也必然是同一个字符串（字符串只有赋值操作时才可以更新elements、len字段）。"

# Functions

- function is one kind of first-level citizen types in Go  [go101.org]

  >"function在golang里面算是一级公民，可以将function用作value。自定义函数和builtin、unsafe package下的内置函数有区别，自定义函数不支持范型，但是内置函数支持。"

- The literal of a function type is composed of the func keyword and a function signature literal. A function signature is composed of two type list, one is the input parameter type list, the other is the output result type lists.  [go101.org]

  >"函数类型字面量包括了func以及函数签名（参数列表、返回值列表），函数名称并不属于签名的一部分。参数列表中参数名字以及返回值列表中返回值的名字可以是blank identifier “_”。参数列表中如果某个参数有名称，那么其他的也必须有，要么都有要么都没有（可以为blank identifier），返回值列表也是。"

- The last parameter of a function can be a variadic parameter. Each function can has most one variadic parameter. To indicate the last parameter is variadic, just prefix three dots ... to its type in its declaration. Example: func (values ...int64) (sum int64) func (seperator string, tokens ...string) string  [go101.org]

  >"每个函数的最后一个参数可以是可变参数，用...来指明，每个函数最多有一个可变参数。带有可变参数的函数称为可变函数，可变函数在调用的时候，对应可变参数位置的实参必须是一个slice...的形式，如[]int{1,2,3}..."

- function types are uncomparable types  [go101.org]

  >"函数类型是不可比较类型，但一个函数类型的value可以与nil做比较。因为函数类型不可比较，所以不能用作map的key。"

- A function prototype is composed of a function name and a function signature. Its literal is composed of the func keyword, a function name and a function signature.  [go101.org]

  >"函数原型，包括func关键字、函数名、参数列表、返回值列表。"

- Generally, the names of the functions declared in the same code package can't be duplicated. But there are two exceptions. One exception is each code package can declare several functions with the same name init. The prototypes of all the init functions must be func init(). Each of these init functions will be called once and only once when that code package is loaded at run time. The other exception is functions can be declared with names as the blank identifier _, in which cases, the declared functions can never be called.   [go101.org]
	>"通常情况下，同一个package下面不允许出现两个函数名相同的函数，但是有两个例外：
	>1）同一个package下允许出现多个init函数，且init函数必须声明为func init() {...}，参数列表、返回值列表必须为空，每个init函数在包初始化的时候都会执行且只执行一次。
	>2）允许存在多个函数名为blank identifier的函数，这样的函数永远不会被执行。"

- Most function calls are evaluated at run time. But calls to the functions of the unsafe standard package are always evaluated at compile time. Calls to some other built-in functions, such as len and cap, may be evaluated at either compile time or run time, depending on the passed arguments. The results of the function calls evaluated at compile time can be assigned to constants.  [go101.org]

  >"有些函数时在编译时就能执行完成的，不一定要到运行时。unsafe这个包下的内置函数都是在编译时就完成的，其他的内置函数如len、cap可能在编译时完成也可能在运行时完成，比如len一个数组肯定就是编译时完成，但是len一个slice就要运行时。如果一个函数调用可以在编译时就执行完成，那么该函数的返回值可用于给constants赋值。"

- Let's repeat it again, like all value assignments in Go, all function arguments are passed by copy in Go. When a value is copied, only its direct part is copied.  [go101.org]

  >"函数调用过程中，所有的参数传递都是通过值拷贝来完成的，就是说不管是基本类型还是比较复杂的容器类型、引用类型都是通过值拷贝的形式，但是只拷贝direct value part这部分。"

- We can implement a function in Go assembly. Generally, Go assembly source files are stored in *.a files. A function implemented in Go assembly is still needed to be declared in a *.go file, but the only the prototype of the function is needed to be present. The body portion of the declaration of the function must be omitted in the *.go file.  [go101.org]

  >"golang里面有些函数声明是没有函数体的。一般这种都是以汇编的形式来定义的函数体，汇编代码存储在*.a文件中，而不是*.go。"

- A value of a function type is called a function value  [go101.org]

  >"函数类型的值称为函数值，一个function value的类型就是func+参数列表+返回值列表，它是可调用的。只有自定义函数类型才可以作为函数值，内置类型函数以及init不可以作为函数值。如果一个函数值funcV是nil，go funcV会触发严重错误（无法恢复）导致进程crash，如果是在当前协程里面调用该函数值则错误可恢复。"

- function的内部表示
	>看下golang cmd/compile/internal/types/type.go中对Func类型的定义：
	>// Func contains Type fields specific to func types.
	>
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
	>通过这个Func定义来看，其可以覆盖golang里面所有的函数类型声明了，不管是普通函数，还是成员方法等等。

- 闭包是怎么实现的？
  >“前段时间组内分享闭包使用的时候，觉得这玩意虽然轻巧但是太容易出错了，究其原因是因为不了解闭包的实现原理。那么闭包是如何实现的呢，抽时间扒拉了一下golang中实现闭包的代码，看完后瞬间觉得闭包很简单。来简单总结一下。
  >闭包就是函数+环境，问题是这里的环境是如何与函数进行绑定的呢？一开始看了上面的Func类型定义之后，我以为是golang创建了一个虚拟的类型（里面各个字段值为闭包捕获的变量值）然后将该虚拟类型作为receiver-type来实现的呢，可是仔细一想这种思路站不住脚，因为闭包是golang里面的first-class citizen，闭包实现应该非常轻量才对，如果像我最初这种想法那实在是太复杂了，想想要创建多少虚拟类型及其对象吧。
  >看了下源代码，总结一下golang中的实现思路，考虑到闭包对象是否能重复使用，分为两个场景进行处理：
  >1）假如闭包定义后立即被调用，因为只会被使用一次，所以应该力图避免闭包对象的内存分配操作，那怎么优化一下呢，以下面的示例代码为例。
  >
  ```
  func(a int) {
  	println(byval)
  	byref++
  }(42)
  ```
	>上面的闭包将被转换为简单函数调用的形式：
	>
	```
	func(byval int, &amp;byref *int, a int) {
  		println(byval)
  		(*&amp;byref)++
	}(byval, &amp;byref, 42)
	```
	>注意看函数原型的变化，原来闭包里面捕获的变量都被转换成了通过函数参数来供值：
	>- 因为println操作不涉及对byval变量的修改操作，所以是按值捕获；
	>- 而byref++涉及到对捕获变量的修改，所以是按引用捕获，对于按引用捕获的变量会进行特殊处理，golang编译器会在编译时将按引用捕获的变量名byref转换成“&amp;byref”，同时将其类型转换成pointer类型，捕获变量对应的写操作也会转换为通过pointer来操作。
	>
	>2） 假如闭包定以后并不是立即调用，而是后续调用，可能调用多次，这种情况下就需要创建闭包对象，这种情况下如何实现呢？
	>- 如果变量是按值捕获，并且该变量占用存储空间小于2*sizeof(int)，那么就通过在函数体内创建局部变量的形式来shadow捕获的变量，相比于通过引用捕获，这么做的好处应该是考虑到减少引用数量、减少逃逸分析相关的计算。
	>- 如果变量是按引用捕获，或者按值捕获但是捕获的变量占用存储空间较大（拷贝到本地做局部变量代价太大），这种情况下就将捕获的变量var转换成pointer类型的“&amp;var”，并在函数prologue阶段将其初始化为捕获变量的值。
	>这部分的代码详见：cmd/compile/gc/closure.go中的方法transformclosure(...)。闭包就是函数体+环境，环境就是像这样绑定的。"

# Channels

- Modern CPUs often have multiple cores, and some CPU cores support hyper-threading. In other words, modern CPUs can process multiple instruction pipelines simultaneously. To fully use the power of modern CPUs, we need to do concurrent programming in coding our programs.  [go101.org]

  >"现代处理器一般都是多核、支持超线程的处理器，通过并发变成可以更好的发挥现代处理器的计算能力。  1）并发，指的是宏观上并行，微观上串行；2）并行，指的是多个任务在同一时刻同时运行。  并发可以是发生在同一个程序中，或者一台机器上的不同程序中，甚至不同的计算节点上。我们这里所说的golang并发编程指的是单个程序中的并发。"

- Concurrent computations may share resources, generally memory resource.

  >"并发编程涉及到资源共享，例如内存资源，存在并发读写的情景，如果不通过同步措施来控制并发就很可能出现数据竞态（data race），导致并发的任务拿到不一致的数据。goroutine是golang里面提供的多种同步措施之一。"

- One suggestion (made by Rob Pike) for concurrent programming is don't (let goroutines) communicate by sharing memory, (let them) share memory by communicating (through channels). The channel mechanism is a result of this philosophy.  [go101.org]

  >"golang里面采用了类似CSP（通信串行处理）的设计哲学，即通过通信来共享内存，而不是通过共享内存来通信。这样可以很大程度上避免出现data race。"

- Along with transferring values, the ownerships of some values may be also transferred between goroutines.

  >"channel可以理解成一个fifo的队列，有的任务往里面写数据，有的任务从里面取数据。从逻辑视角来看，当一个任务将数据写到channel时就释放了对数据的所有权ownership，接收到数据的任务就拿到了数据的所有权。这只是逻辑视角来看，golang底层实现并不想Rust语言一言保证数据写入channel、离开channel时数据所有权的变更。但是我们在编程的时候可以模拟实现这种ownership的变更，如果我们这么写了那么就可以写出无data race的代码，如果不这么写就还是无法避免data race，也就是说channel可以“帮助”我们写data race free的代码，但是也无法避免我们写出错误的代码。"

- One problem of channels is, the experience of programming with channels is so enjoyable and fun that programmers often even prefer to use channels for the scenarios which channels are not best for.  [go101.org]

  >"golang提供了channel来进行并发控制，也提供了原始的一些基于mutex等的同步控制（sync/sync.atomic package下），每一种方式都有各自的适用场景，但是基于channel实现的并发更加清晰易懂，以至于在某些channel并不是最佳选择的情境下，也有很多开发者使用了channel来实现并发控制。"

- Channel types are composite types. Like array, slice and map, each channel type has an element type. All data to be sent to the channel must be values of the element type.  [go101.org]

  >"channel是一种组合类型，和array、slice、map一样其内部记录了要存储的元素的类型，channel分为双向、单向channel，要注意他们之间的转换关系。channel对应的零值是nil，通过make创建channel。"

- All channel types are comparable types.  From the article value parts, we know that non-nil channel values are multi-part values. After one channel value is assigned to another, the two channels share the same undrelying part(s). In other words, the two channels represent the same internal channel object. The result of comparing them is true  [go101.org]

  >"chan是可比较的类型，对于chan value，其包括direct value part和indirect value part，当把一个chan value赋值给另一个chan变量时，这两个chan将共享相同的内部存储，包括data buffer、recv goroutine queue，send goroutine queue等。因为内部成员都是可比较的，所以chan类型是可比较的。"

- Close the channel by using the following function call close(ch)  	where close is a built-in function. The argument of a close function call must be a channel value, and the channel value must not be a receive-only channel.  [go101.org]

  >"close(ch)这里的ch不能是一个recv only的单向channel，比如是可以send的才行，因为close定义的时候要求参数是chan&lt;-。"

- it can be viewed as a multi-valued 	expression and result a second optional untyped boolean value, 	which indicates whether or not the first result is sent 	before the channel is closed.  [go101.org]

  >"val, sentBeforeClosed := &lt;-ch，从chan中接收的时候可以返回多个值，表示val这个值是否是在chan被关闭之前发送到chan的。如果chan被关闭后会从chan中接收会一直返回val=0，sentBeforeClosed=false，我们就知道chan被关闭了，0其实是无效的。"

- Query the value buffer capacity of the channel 	by using the following function call cap(ch)  [go101.org]

  >"查看channel中data buffer的容量，cap(ch)。"

- Query the current number of values in the value buffer 	(or the length) 	of the channel by using the following function call len(ch)  [go101.org]

  >"查询channel的data buffer中现在有多少个元素。"

- All these operations are already synchronized, so no further synchronizations are needed to perform these operations. However, like most other operations in Go, channel value assignments are not synchronized. Similarly, assigning the received value to another value is also not synchronized, though any channel receive operation is synchronized.  [go101.org]

  >"chan上的close、cap、len、发送、接收操作都是包含了同步控制的，但是将一个chan value赋值给另一个chan变量并没有同步，同样的&lt;-ch这样接收到的一个元素值，赋值给另一个变量val := &lt;-ch这种操作也是没有同步的。 编程里面应避免多个goroutine收chan上的数据更新同一个全局变量的情况，良好的编程方式是不要在chan里面塞size太大的元素，考虑是否使用指针代替。"

- A Simple Summary Of Channel Operation Rules
	>"chan可以分为如下几种类型：nil chan、non-nil但是已经closed的chan，non-nil但是还未closed-chan，对他们可进行的操作如close、send、recv，在这3种不同类型的chan上表现是不同的。 
	>1 close操作：nil chan会panic，non-nil &amp; closed chan会panic，只有non-nil &amp; non-closed chan才会正常关闭。 
	>2 send操作：nil-chan会阻塞，non-nil &amp; closed chan会panic，只有non-nil &amp; non-closed chan才能发送成功（包括了等待发送、成功发送两种情况）。 
	>3 recv操作：nil-chan会阻塞，non-nil &amp; closed chan永不阻塞，返回0值和sentbeforeclosed标记true，只有non-nil &amp; non-closed的chan才能接收数据（包括等待接收和接收成功两种情况）。"

- Sending a value to or receiving a value from a nil channel makes the current goroutine enter and stay in blocking state for ever.
	>"golang设计里面通过select-case来对chan上的读写就绪事件进行监听，但是select-case里面不能使用fallthrough，这个时候就有问题了，假如select-case里面有多个case分支，其中第一个分支是case &lt;-ch1，假如这个分支ch1被关闭了，那么这个分支将一直是ready的，其他case分支将永远无法执行到。
	>如下所示：
	>
	```
	select {
  		case &lt;-ch1:
        	dosomething()
  		case &lt;-ch2:
         	dosomething()
  		case ch3&lt;-:
         	dosomething()
	}
	```
	>如何避免这种，如何在一个ch无用后禁用对应的case分支呢？将这个分支设置为nil就是一种解决方法。"

- To better understand channel types and values and to make the some explanations easier, knowing the rough internal structures of internal channel objects is very helpful. We can think each channel maintains three queues internally.
	>"理解channel类型的内部结构之后更容易理解channel的工作原理。
	>channel内部其实包括了3个队列：
	>1 value buffer queue，这是一个环形队列，用于存储goroutine写进来的数据，该队列的size与创建channel时指定的capacity是相等的。如果环形队列满了，channel就处于full status，如果队列空了，channel就处于empty status。对于一个0-capacity的channel，常称为unbufferred channel，也是因为环形缓冲size为0无法存储数据，这种chan同时处于full和empty两种状态。
	>2 等待接收goroutine queue，这个队列的是一个容量没有上限的链表实现的，里面存储的是等待从该channel上接收数据的goroutine，接收数据后要存储到的变量的地址也和goroutine一并进行记录。
	>3 等待发送goroutine queue，这个队列也是一个容量没有上限的链表实现的，里面存储的都是等待向该channel上发送数据的goroutine，待发送数据的内存地址也和goroutine一并进行记录。"

- [Channel rule case A]: when a goroutine tries to receive a value from a not-closed non-nil channel, the goroutine first tries to acquire the lock accociated with the channel, then do the following steps until one condition is satisfied.
	>"chan操作规则1：当一个goroutine要从一个non-nil &amp; non-closed chan上接收数据时，goroutine首先会去获取chan上的锁，然后执行如下操作直到某个条件被满足：
	>1）如果chan上的value buffer不空，这也意味着chan上的recv goroutine queue也一定是空的，该接收goroutine将从value buffer中unshift出一个value。这个时候，如果send goroutine队列不空的情况下，因为刚才value buffer中空出了一个位置，有位置可写，所以这个时候会从send goroutine queue中unshift出一个发送goroutine并让其恢复执行，让其执行把数据写入chan的操作，实际上是恢复该发送该goroutine执行，并把该发送goroutine要发送的数据push到value buffer中。然后呢，该接收goroutine也拿到了数据了，就继续执行。这种情景，channel的接收操作称为non-blocking操作。
	>2）另一种情况，如果value buffer是空的，但是send goroutine queue不空，这种情况下，该chan一定是unbufferred chan，不然value buffer肯定有数据嘛，这个时候接收goroutine将从send goroutine queue中unshift出一个发送goroutine，并将该发送goroutine要发送的数据接收过来（两个goroutine一个有发送数据地址，一个有接收数据地址，拷贝过来就ok），然后这个取出的发送goroutine将恢复执行，这个接收goroutine也可以继续执行。这种情况下，chan接收操作也是non-blocking操作。
	>3）另一种情况，如果value buffer和send goroutine queue都是空的，没有数据可接收，将把该接收goroutine push到chan的recv goroutine queue，该接收goroutine将转入blocking状态，什么时候恢复期执行呢，要等到有一个goroutine尝试向chan发送数据的时候了。这种场景下，chan接收操作是blocking操作。"

- [Channel rule case B]: when a goroutine tries to send a value to a not-closed non-nil channel, the goroutine first tries to acquire the lock accociated with the channel, then do the following steps until one step condition is satisfied.
	>"当一个goroutine常识向一个non-nil &amp; non-closed chan发送数据的时候，该goroutine将先尝试获取chan上的锁，然后执行如下操作直到满足其中一种情况。
	>1）如果chan的recv goroutine queue不空，这种情况下，value buffer一定是空的。发送goroutine将从recv goroutine queue中unshift出一个recv goroutine，然后直接将自己要发送的数据拷贝到该recv goroutine的接收地址处，然后恢复该recv goroutine的运行，当前发送goroutine也继续执行。这种情况下，chan send操作是non-blocking操作。
	>2）如果chan的recv goroutine queue是空的，并且value buffer不满，这种情况下，send goroutine queue一定是空的，因为value buffer不满发送goroutine可以发送完成不可能会阻塞。该发送goroutine将要发送的数据push到value buffer中然后继续执行。这种情况下，chan send操作是non-blocking操作。
	>3）如果chan的recv goroutine queue是空的，并且value buffer是满的，发送goroutine将被push到send goroutine queue中进入阻塞状态。等到有其他goroutine尝试从chan接收数据的时候才能将其唤醒恢复执行。这种情况下，chan send操作是blocking操作。"

- [Channel rule case C]: when a goroutine tries to close a not-closed non-nil channel, both of the following two steps will be performed by the following order.
	>"当一个goroutine尝试close一个non-nil &amp; non-closed chan的时候，close操作将依次执行如下操作。
	>1）如果chan的recv goroutine queue不空，这种情况下value buffer一定是空的，因为如果value buffer如果不空，一定会继续unshift recv goroutine queue中的goroutine接收数据，直到value buffer为空（这里可以看下chan send操作，chan send写入数据之前，一定会从recv goroutine queue中unshift出一个recv goroutine）。recv goroutine queue里面所有的goroutine将一个个unshift出来并返回一个val=0值和sentBeforeClosed=false。
	>2）如果chan的send goroutine queue不空，所有的goroutine将被依次取出并生成一个panic for closing a close chan。在这close之前发送到chan的数据仍然在chan的value buffer中存着。"

- [Channel rule case D]: after a channel is closed, channel receive operations on the channel will never block. The values in the the value buffer of the channel can still be received. Once all the values in the value buffer are taken out and received, infinite zero values of the element type of the channel will received by any of following receive operations on the channel. As above has mentioned, the second return result of a channel receive operation is an untype boolean value which indicates whether or not the first result (the received value) is sent before the channel is closed.

  >"一旦chan被关闭了，chan recv操作就永远也不会阻塞，chan的value buffer中在close之前写入的数据仍然存在。一旦value buffer中close之前写入的数据都被取出之后，后续的接收操作将会返回val=0和sentBeforeClosed=true。"

- Knowing what are blocking and non-blocking channel send or receive operations is important to understand the mechanism of select control flow blocks which will be introduced in a later section.

- In the above explanations, if a goroutine is unshifted out of a queue (either the sending goroutine queue or the receiving goroutine queue) of a channel, and the goroutine was blocked for being pushed into the queue at a select control flow code block, then the goroutine will be resumed to running state at the step9 of the select control flow code block execution. It may be dequeued from the corresponding goroutine queues of several goroutines involved in the the select control flow code block.
  >golang select-case实现机制
  >
  >理解这里的goroutine的blocking、non-blocking操作对于理解针对chan的select-case操作是很有帮助的。
  >select-case中假如没有default分支的话，一定要等到某个case分支满足条件然后将对应的goroutine唤醒恢复执行才可以继续执行，否则代码就会阻塞在这里，即将当前goroutine push到各个case分支对应的ch的recv或者send goroutine queue中，对同一个chan也可能将当前goroutine同时push到recv、send goroutine queue这两个队列中。
  >不管是普通的chan send、recv操作，还是select chan send、recv操作，因为chan操作阻塞的goroutine都是依靠其他goroutine队chan的send、recv操作来唤醒的。前面我们已经讲过了goroutine被唤醒的时机，这里还要再细分一下。
  >chan的send、recv goroutine queue中存储的其实是一个结构体指针*sudog，成员gp *g指向对应的goroutine，elem unsafe.Pointer指向待读写的变量地址，c *hchan指向goroutine阻塞在哪个chan上，isSelect为true表示select chan send、recv，反之表示chan send、recv。g.selectDone表示select操作是否处理完成，即是否有某个case分支已经成立。
  >下面我们简单描述下chan上某个goroutine被唤醒时的处理逻辑，假如现在有个goroutine因为select chan 操作阻塞在了ch1、ch2上，那么会创建对应的sudog对象，并将对应的指针*sudog push到各个case分支对应的ch1、ch2上的send、recv goroutine queue中，等待其他协程执行(select) chan send、recv操作时将其唤醒：
  >1）源码文件chan.go，假如现在有另外一个goroutine对ch1进行了操作，然后对ch1的goroutine执行unshift操作取出一个阻塞的goroutine，在unshift时要执行方法 func (q *waitq) dequeue() *sudog，这个方法从ch1的等待队列中返回一个阻塞的goroutine。
  >
  ```
  func (q *waitq) dequeue() *sudog {
        for {
             sgp := q.first
             if sgp == nil {
                return nil
             }
             y := sgp.next
             if y == nil {
                 q.first = nil
                 q.last = nil
             } else {
                 y.prev = nil
                 q.first = y
                 sgp.next = nil // mark as removed (see dequeueSudog)
             }
             // if a goroutine was put on this queue because of a
             // select, there is a small window between the goroutine
             // being woken up by a different case and it grabbing the
             // channel locks. Once it has the lock
             // it removes itself from the queue, so we won't see it after that.
             // We use a flag in the G struct to tell us when someone
             // else has won the race to signal this goroutine but the goroutine
             // hasn't removed itself from the queue yet.
             if sgp.isSelect {
                if !atomic.Cas(&amp;sgp.g.selectDone, 0, 1) {
                    continue
                }
             }
             return sgp
        }
    }
  ```
  >
  >假如队首元素就是之前阻塞的goroutine，那么检测到其sgp.isSelect=true，就知道这是一个因为select chan send、recv阻塞的goroutine，然后通过CAS操作将sgp.g.selectDone设为true标识当前goroutine的select操作已经处理完成，之后就可以将该goroutine返回用于从value buffer读或者向value buffer写数据了，或者直接与唤醒它的goroutine交换数据，然后该阻塞的goroutine就可以恢复执行了。
  >这里将sgp.g.selectDone设为true，相当于传达了该sgp.g已经从刚才阻塞它的select-case块中退出了，对应的select-case块可以作废了。有必要提提一下为什么要把这里的sgp.g.selectDone设为true呢？直接将该goroutine出队不就完了吗？不行！考虑以下对chan的操作dequeue是需要先拿到chan上的lock的，但是在尝试lock chan之前有可能同时有多个case分支对应的chan准备就绪。看个示例代码：
  >
 ```
    // g1
    go func() {
      ch1 &lt;- 1 }()
    // g2
    go func() {
      ch2 &lt;- 2
    }
    select {
      case &lt;- ch1:
        doSomething()
      case &lt;- ch2:
        doSomething()
    }
  ```
  >协程g1在 chan.chansend方法中执行了一般，准备lock ch1，协程g2也执行了一半，也准备lock ch2;
  >协程g1成功lock ch1执行dequeue操作，协程g2页成功lock ch2执行dequeue操作；
  >因为同一个select-case块中只能有一个case分支允许激活，所以在协程g里面加了个成员g.selectDone来标识该协程对应的select-case是否已经成功执行结束（一个协程在某个时刻只可能有一个select-case块在处理，要么阻塞没执行完，要么立即执行完），因此dequeue时要通过CAS操作来更新g.selectDone的值，更新成功者完成出队操作激活case分支，CAS失败的则认为该select-case已经有其他分支被激活，当前case分支作废，select-case结束。
  >源文件select.go中方法 selectgo(sel *hselect) ，实现了对select-case块的处理逻辑，但是由于代码篇幅较长，这里不再复制粘贴代码，感兴趣的可以自己查看，这里只简要描述下其执行流程。
  >selectgo逻辑处理简述：
  >0）预处理部分，对各个case分支按照ch地址排序，保证后续按序加锁，避免产生死锁问题；
  >1）pass 1部分处理各个case分支的判断逻辑，依次检查各个case分支是否有立即可满足ch读写操作的。如果当前分支有则立即执行ch读写并回，select处理结束；没有则继续处理下一分支；如果所有分支均不满足继续执行以下流程。
  >2）没有一个case分支上chan操作立即可就绪，当前goroutine需要阻塞，遍历所有的case分支，分别构建goroutine对应的sudog并push到case分支对应chan的对应goroutine queue中。然后gopark挂起当前goroutine，等待某个分支上chan操作完成来唤醒当前goroutine。怎么被唤醒呢？前面提到了chan.waitq.dequeue()方法中通过CAS将sudog.g.selectDone设为1之后将该sudog返回并恢复执行，其实也就是借助这个操作来唤醒。
  >3）整个select-case块已经结束使命，之前阻塞的goroutine已被唤醒，其他case分支没什么作用了，需要废弃掉，pass 3部分会将该goroutine从之前阻塞它的select-case块中各case分支对应的chan recv、send goroutine queue中移除，通过方法chan.waitq.dequeueSudog(sgp *sudog)来从队列中移除，队列是双向链表，通过sudog.prev和sudog.next删除sudog时间复杂度为O(1)。

- Channel Element Values Are Transferred By Copy
	>"从一个goroutine向另一个goroutine借助chan传数据，涉及到数据的两次拷贝操作，value的direct part将被拷贝。
	>这里value或者chan中元素的size不能超过65536字节，这是gc的硬性规定，因为chan send、recv实际上都涉及到值的拷贝，为了性能也不应该传递size特别大的元素，如果size比较大可以考虑传递指针。"

- About Channel And Goroutine Garbage Collections
	>"什么时候才会垃圾回收器才会回收chan呢？当这个chan的send、recv goroutine queue不为空的时候，表示还有goroutine在等待该chan上的读写操作完成，说明这个chan还在被引用，这个时候垃圾回收器不会回收这里的chan。当没有goroutine还在引用这个chan的时候这个chan才会被回收。
	>goroutine的回收只有在它执行结束之后才会被回收。"

- select-case Control Flow Code Blocks features
	>"select-case的一些点：
	>- 与switch-case不同，select后面不允许有表达式；
	>- 不允许在case分支中使用fallthrough；
	>- 每个case分支都只能是chan send或者chan recv操作；
	>- 如果有多个case分支读写就绪，那么将随机选择一个case分支执行（其实是CAS操作抢锁成功的一个分支执行，可参考上面的解析加以理解）。当前协程也会从其他各个分支的recv、send goroutine queue中移除。
	>- 如果没有case分支就绪，且提供了default分支，那么僵执行default分支；如果没有default分支，将把当前goroutine push到各个分支的recv、send goroutine queue中，当前goroutine进入blocking状态；
	>- 如果是select {}将会使当前协程永久阻塞；"

- The Implementation Of The Select Mechanism
	>select-case实现机制总结，这里的总结比较精炼，我上面的分析则更加侧重关键逻辑。这里还描述了对各个case分支channel排序以及加解锁的过程，该过程保证多个协程按序加解锁，避免产生死锁问题。详细执行流程如下:
	>1 evaluate all involved channels and values to be potentially sent, from top to bottom and left to right.
	>2 randomize the case orders for polling (the default branch is treated as a special case). The corresponding channels of the orders may be duplicate. The default branch is always put at the last position.
	>3 sort all involved channels to avoid deadlock in the next step. No duplicate channels are in the first&nbsp;Nchannels of the sorted result, where&nbsp;N&nbsp;is the number of involved channels in the select block. Below,<span class="text-italic text-bold">the sorted lock order</span>&nbsp;mean for the the first&nbsp;N&nbsp;ones.
	>4 lock all involved channels by the sorted lock order in last step.
	>5 poll each cases in the select block by the randomized case orders:
	>1)if the corresponding channel operation is a send-value-to-closed-channel operation, unlock all channels and panic. Go to step 12.
	>2)if the corresponding channel operation is non-blocked, perform the channel operation and unlock all channels, then execute the corresponding&nbsp;case&nbsp;branch body. 
	>3)The channel operation may wake up another blocked goroutine. Go to step 12.
	>4)if the case is the default branch, then unlock all channels and execute the default body. Go to step 12.
	>5 (Up to here, there must be not a default branch and all case channel operations are blocked.)
	>6 push (enqueue) the current goroutine (with the case channel operation information) into the receiving or sending goroutine queue of the involved channel in each case operation. The current goroutine may be pushed into the queues of a channel multiple times, for the involved channels in multiple cases may be the same one.
	>7 block the current goroutine and unlock all channels by the sorted lock order.
	>8 …, in blocking state, waiting other channel operations to wake up the current goroutine, ...
	>9 the current goroutine is waken up by another channel operation in another goroutine. The other operation may be a channel close operation or a channel send/receive operation. If it is a channel send/receive operation, there must be a case channel receive/send operation cooperating with it. In the cooperation, the current goroutine will be dequeued from the receiving/sending goroutine queue of the channel.
	>10 lock all involved channels by the sorted lock order.
	>11 dequeue the current goroutine from the receiving goroutine queue or sending goroutine queue of the involved channel in each case operation,
	>1)if the current goroutine is waken up by a channel close operation, go to step 5.
	>2)if the current goroutine is waken up by a channel send/receive operation, the corresponding case of the cooperating receive/send operation has already been found in the dequeuing process, so just unlock all channels by the sorted lock order and execute the corresponding case body.
	>12 done

# Methods

- Go supports some object-orient programming features. Method is one of these features. A method is a special function which has a receiver parameter (see below). This article will explain method related concepts in Go.  [go101.org]
	>"golang中类似面向对象的部分特征，成员方法就是其中支持。方法是一种特殊类型的函数，相比普通函数，它多了一个接收者类型。  函数的内部表示如下，这个结构体可以覆盖golang里面所有类型的函数定义，包括普通函数、成员方法、接口方法等。  
	```
	type Func struct {    
		Receiver *Type  // function receiver，接受者类型，可以为nil或non-nil
        Results  *Type  // function results，返回值类型    
        Params   *Type  // function params，参数列表类型    
        Nname *Node     // function name，函数名    
        // Argwid is the total width of the function receiver, params, and results.    
        // It gets calculated via a temporary TFUNCARGS type.    
        // Note that TFUNC's Width is Widthptr.    
        Argwid int64    
        Outnamed bool // 是否是可导出的？ 
    }
  ```

- In Go, we can (explicitly) declare a method for type T and *T, where T must satisfiy 4 conditions
	>为类型T或者*T定义方法（接收者类型为T或者*T），必须满足如下几个条件：
	>- T必须是已经定义过的类型；
	>- T与当前方法定义必须在同一个package下面；
	>- T不能是指针；
	>- T不能是接口类型；
	>
	>1）T为什么不能是指针？
	>允许为指向类型的指针*T添加方法，但是不允许为指针类型本身添加方法。按现有golang的实现方式，为指针类型添加方法会导致方法调用时的歧义，看下面这个示例程序。
	>
	```golang
    type T int 
    func (t *T) Get() T { 
        return *t + 1 
    } 
    type P *T 
    func (p P) Get() T { 
        return *p + 2 
    } 
    func F() { 
        var v1 T 
        var v2 = &amp;v1 
        var v3 P = &amp;v1 
        fmt.Println(v1.Get(), v2.Get(), v3.Get()) 
    }
	```
	>示例程序中v3.Get()存在调用歧义，不知道该调用哪个方法了。如果要支持在指针这种receiver-type上定义方法，golang编译器势必要实现地更复杂才能支持到，指针本来就比较容易破坏可读性，还要在一种指针类型上定义方法，对使用者、编译器开发者而言可能都是件费力不讨好的事情。
	>2）T为什么不能接口类型？
	>这没有什么高深的，只是golang spec和现在的运行时实现不支持而已。golang现在的实现里，interface类型只能包括方法类型（注意是类型），但是不能方法实现，结构体才可以包括方法的实现。
	>再强调一遍，接口类型里面只包括方法的类型，而不包括方法的定义。当某个类型实现了某个接口声明的方法的时候，我们可以将这个类型值赋值给该接口值，此时接口实例里面会更新其dynamic value和dynamic type字段。
	>如果我们把某个类型T的值赋值给接口变量iface的话，可以细分为几种情景：
	>1）如果iface对应接口类型是interface{}，并且T值小于等于sizeof(uintptr)，那么dynamic value就直接是T的值的拷贝，反之就开辟内存拷贝T的值，并将新开辟内存的地址设置到dynamic value字段，dynamic type当然就指向类型T定义了。
	```
    type eface struct {
        _type *_type
        data  unsafe.Pointer
    }
  ```
	>2）如果iface对应接口类型interface{methods-list}，这个时候dynamic value还是与1）中同样的处理，但是dynamic type处理方式不同，需要对方法调用地址进行处理。这时会创建一个itable，这个itable里面保存了iface的接口类型以及接口中声明的各个方法类型对应的调用地址。然后将iface里面的tab指向该itable。
	>这样当通过接口调用方法的时候，就会通过tab查询到该方法的实际调用地址为T中方法的地址。从T值赋值给iface过程中，到通过iface多态调用T的方法，这整个逻辑处理过程中只有对接口类型中声明方法、T中定义方法的处理，如果说就算允许为接口添加方法不算语法错误，并允许算作是接口中的方法类型，那么现在的itable处理逻辑也支持不到。
	>不同的编程语言对函数调用的多态实现有不同的思路，c++是通过填充基本类型的虚函数表的方式，golang是通过类似的这样一种查询表的形式。总结一下就是并非golang无法通过扩展支持在接口上添加方法，只是这样是否真的有必要，值得商榷。
    ```
    type iface struct {
        tab  *itab
        data unsafe.Pointer
    }
    ```
	>参考“接口与itable关系”：<a target="_blank" rel="nofollow" class="link " href="https://research.swtch.com/interfaces" data-auto="true">https://research.swtch.com/interfaces</a>。"

- We can also declare methods for alias types of the T and *T types specified above. The effect is the same as declaring methods for the T and *T types themselves.  [go101.org]

  >也可以在类型T或者*T的别名上定义方法，效果跟直接在T或者*T上定义类似。

- From the above listed conditions, we will get the conclusion that we can never (explicitly) declare methods for following types.
	>- 内置基本数据类型如int、string，不能为其定义方法；
	>- 接口类型，也不能为其定义方法，原因上面也分析过了；
	>- 无名类型包括无名数组、map、slice、function、chan、struct，也不能为其定义方法，*T除外。另外，如果无名struct匿名嵌套了其他的类型并且这个被嵌套类型有方法的话，编译器是会为这个struct生成一些wrapper方法的，以保证可以通过这个无名结构体调用被嵌套类型的方法。"

- In some other programming languages, the receiver parameter names are always the implicit this, which is not a recommended identifier for receiver parameter names in Go.The receiver of type *T are called pointer receiver, non-pointer receivers are called value receivers.
	>为啥叫接收者类型呢？因为调用对象的方法就好比是给这个对象发送一个消息，然后对象对此作出处理，所以这个调用对象也被称为消息接收者，对应的类型就称为接收者类型了。
其他语言里面，这样的接收者往往是用的this，比如js、c++、java等，但是golang里面不是这样的，因为它对接收者做了细分，比如“value receiver”或者“pointer receiver”，前者不可以修改接收者的值，但是后者可以。看上去有点像c++中对方法的const修饰不允许修改对象状态，non-const方法才可以修改对象状态。


- Each Method Corresponds To An Implicit Function
	>golang编译器会为每个T或者*T上的方法定义生成一个隐式函数，如：
	```
    func (b Book) Pages() int {
        return b.pages
    }
    func (b *Book) SetPages(pages int) {
        b.pages = pages
    }
  ```
	>会被转换为：
	```
    func Book.Pages(b Book) int {
        return b.pages // the body is the same as the Pages method
    }
    func (*Book).SetPages(b *Book, pages int) {
        b.pages = pages // the body is the same as the SetPages method
    }
  ```
	>转换后，接收者被作为生成的隐式函数的第一个参数，函数体部分不变。注意，编译器生成的隐式函数与用户定义的方法是同时存在的，并不是说编译器将用户定义的方法转换为另一种形式。
	>前面提到的编译器自动为成员方法生成了对应的隐式函数，用户代码中不能定义隐式函数这种形式的方法，但是可以在代码中直接调用隐式函数，示例代码如下：
	```
    type Book struct {
        pages int
    }
    func (b Book) Pages() int {
        return b.pages
    }
    func (b *Book) SetPages(pages int) {
        b.pages = pages
    }
    func main() {
        var book Book
        // 调用编译器隐式定义的方法
        (*Book).SetPages(&amp;book, 123)
        fmt.Println(Book.Pages(book)) // 123
    }
  ```

- Implicit Methods With Pointer Receivers
	>在类型T上定义的方法，尽管receiver-type是value receiver不是pointer receiver，但是我们在调用的时候仍然可以通过T指针来调用成员方法，为什么呢？因为编译器对每个value-receiver方法会自动生成一个与之对应的pointer-receiver方法，同时也会为这个方法生成对应的隐式函数。
    ```
    type T struct {}
    func (t T) doSomething() {
    }
    func main() {
      t := &amp;T{}
      t.doSomething()
    }
    ```
	>这种调用方式仍然是ok的，因为编译器隐式地创建了一个成员方法：
    ```
    func (t *T) doSomething() {
      T.doSomething(*t)
    }
    ```
	>这个成员方法相当于调用了原来value-receiver方法对应的隐式函数，所以是ok的。
另外，假如用户在*T上定义了一个成员方法，能不能通过T的值来调用该方法呢？可以！实现原理是否一样呢？不一样！
	>看下面的示例代码：
    ```
    type T struct {}
    func (t *T) doSomething{
    }
    func main() {
      t := T{}
      t.doSomething()
    }
    ```
	>这种形式其实是一种语法糖，编译器会将其转换成(&amp;t).doSomething()调用value-receiver的方法。但是有一点要注意的是，这种语法糖形式的调用，必须保证t是可寻址的（注意golang里面返回值是不可寻址的）。"

- Syntax sugar for pointer receiver method func(b *Book) SetPages(val int), book := Book{}; (&book).SetPages(123) can be simplified to book.SetPages(123).
    >对于pointer-receiver方法，如果是通过value来调用该方法的话，只要value是可寻址的，那么编译器会将先取value得地址，再调用对应的pointer-receiver方法，只是一个语法糖转换而已（需要注意的是golang里面的函数返回值是不可寻址的）。
    
- Receiver Arguments Are Passed By Copy
    >"方法调用时传递的receiver-type value也是通过值传递的形式拷贝过来的，如果对这里的value进行了修改，那么将不会影响到外部原始value的direct part的值。"

- Should A Method Be Declared With Pointer Receiver Or Value Receiver
    >一个方法到底应该选择pointer receiver还是value receiver呢？
    >根据前面的内容，某些情况下必须将receiver type定义生成pointer receiver，比如希望对对象本身作出修改，并且更新receiver的direct value part。实际上如果我们将所有的方法都定义到pointer-receiver上是没有任何逻辑问题的，但是确实需要考虑一下选择value-receiver或者pointer-receiver那种性能更好。
    >- 太多的指针拷贝，会加重垃圾收集器的负担；
    >- 如果receiver-type的size比较大，那么receiver拷贝将是一个不能忽视的问题，特别是当传递的对象是一个interface value的话将涉及到两次拷贝，一次是接口值的拷贝，一次是接口动态值的拷贝。而pointer value都是size较小的。实际上标准go编译器和运行时，除了array和struct类型都是比较小的类型。struct字段比较少的话也是size比较小的。
    >- 同一个receiver type类型上同时混杂着value-receiver和pointer-receiver，方法被并发调用的话更容易引入data race。
    >- sync包下的value不应该不拷贝，所以如果receiver-type是struct类型，而这个类型里面嵌套了sync包下的类型的话，将引发一些问题。
    >如果很难以决定到底该采取哪一种receiver-type，那就使用pointer-receiver吧。"

# Interfaces

- Interface types are one special kind of types in Go. Interface kind plays several important roles in Go. Firstly, interface types make Go support value boxing. Consequently, through value boxing, reflection and polymorphism get supported.  [go101.org]
    >"interface类型是一种特殊的类型，它实现了value boxing操作，通过value boxing，也可以支持reflection和polymorphism。"

-  What Are Interface Types?  [go101.org]
    >"每一个interface类型都定义了一个method prototype的结合，这个集合可以为空。结合中方法名不能是"_"。interface中只能定义方法原形，而不是在interface上添加方法定义，这个在前面学习method的时候已经分析了其中的原因，这里不再赘述。"

- The Method Set Of A Type  [go101.org]
    >"每一种类型都有一个与之关联的method set：
    >- 对于interface类型，它的method set也就是interface声明的method prototype的集合；
    >- 对于non-interface类型，它的method set包括显示定义在该类型上的方法的原型构成的集合，还包括编译器为value receiver隐式添加的pointer receiver方法，还包括二者对应的隐式函数，如果该类型涉及到类型嵌套，还回包括编译器为其生成的隐式wrapper方法。
如果有两个无名接口类型，并且它们的method set都是空的，那么这两个接口类型是完全相同的。"

-  What Are Implementations?  [go101.org]
    >"- 如果类型T的method set是接口I的method set的超集，那么就说类型T实现了接口I；
    >- 如果两个接口类型I1、I2都是空接口类型，那么I1、I2是互相实现了对方的；
    >- 一个接口类型I也总是实现了自身的；
    >- 任何类型都实现了一个空接口类型；
    >golang里面类型T与接口I的实现关系是隐式实现的，没有像Java中那样的关键字“implements”来显示表名实现关系。这种隐式实现有一种好处，就是能够允许某些包中的类型实现用户自定义的接口。比如std库中的database/sql package下的类型DB、Tx都实现了如下用户自定义的接口：
    ```
    type DatabaseStorer interface {
    	Exec(query string, args ...interface{}) (Result, error)
    	Prepare(query string) (*Stmt, error)
    	Query(query string, args ...interface{}) (*Rows, error)
    }
    ```
    
-  Value Boxing  [go101.org]
    >"如果类型T实现了接口I，那么就可以将T的值赋值给I的值，赋值过程中涉及到设置接口值的dynamic value和dynamic type：
    >1）dynamic value
    >- 如果T本身不是接口类型，那么将拷贝T的值，如果sizeof(T)&lt;=sizeof(uintptr)将直接把T的值设置到接口值的value unsafe.Pointer字段；反之新开辟一块足够大的内存将T的值拷贝过去，然后将新开辟内存的地址设置到value unsafe.Pointer。这里拷贝T的时间复杂度为O(n)，n为sizeof(T)。
    >- 如果T本身是一个接口类型，那么将拷贝T中的dynamic value到接口值中的dynamic value，时间复杂度为O(1)。
    >2) dynamic type
    >除了拷贝dynamic value还需要构建T的动态类型信更新到接口值的dynamic type字段，这个动态类型信息包含两部分内容：
    >- 一部分是包含一个指向itable的指针，方便通过接口值查询动态类型实现的接口方法的调用地址，借此实现polymorphism（多态）；
    >- 另一部分是包含动态类型的字段列表信息、方法信息，借此实现reflection（反射）；"
    
- Polymorphism  [go101.org]
    >"多态是golang interface的重要功能之一，如果类型T实现了接口I，并将T类型值tval付给I类型值ival，那么通过ival.dosomething()执行的将是类型T中定义的方法dosomething()。如果分别有类型T1、T2实现了接口I，那么为ival赋值对应的T1、T2的值，并执行ival.dosomething()将分别调用T1、T2对dosomething()的实现，从而实现多态的效果。"

- The dynamic type information stored in an interface value can be used to inspect and manipulate the values referenced by the dynamic value which is boxed in the interface value. This is called reflection in programming.  Currently (v1.10), Go doesn't support generic for custom functions and types. Reflection partially remedies the inconveniences caused by lacking of generic.  [go101.org]
    >"golang中用户自定义类型和函数无法使用泛型支持，但是可以通过反射来近似实现泛型支持。"

- Type Assertion  There are four kinds of interface value involved value conversion cases in Go
    >"有四种可能的操作： 
    >- 转换非接口值为接口值，非接口类型必须实现接口； 
    >- 转换接口值到另一个接口值，源接口值类型必须实现目的接口值的类型； 
    >- 转换接口值到非接口值，非接口值类型可能实现或没实现该接口类型； 
    >- 转换接口值到另一个接口值，源接口值类型可能实现或没实现目的接口值类型； 
    >前两种转换前面已经讲过了，是编译时就能完成的，后面两种是运行时来检查的，是通过type assertion来完成。"

- The form of a type assertion expression is i.(T)
    >"类型断言的形式是i.(T)，i称为被短断言的值asserted value，T称为被断言的类型asserted type。 
    >- T可能是一个非接口类型（必须实现了接口i）； 
    >- T可能是任意一个接口。  
    >断言会返回成功或者失败，成功时也会返回T的值：
    >- 如果T是一个非接口类型，那么i.(T)是希望获取i中的动态值，只有当i中的动态类型与T完全匹配的时候才会断言成功； 
    >- 如果T是一个及诶口类型，那么i.(T)是希望将i中的dynamic value先unboxed然后再转换为接口T类型的值，意味着i中boxed value对应的dynamic type必须实现了接口T才会断言成功。"

- If a type assersion fails, the first return result must be a zero value of the asserted type, and the second return result (assume it is present) is an untyped boolean value false.
    >"类型断言i.(T)既可以用作单值表达式，也可以用作多值表达式。 - 用作多值表达式的时候，第一个参数表示转换后的值，第二个参数表示是否断言成功； - 用作单值表达式的时候，返回值表示转换后的值，如果断言失败，会直接panic。"

- Type Switch Control Flow Block  [go101.org]
    >"type switch control flow block，可以看做是增强版的类型断言，其基本形式如下：  
    >
    ```
    // type-switch
    switch aSimpleStatement; v := x.(type) { 
        	case TypeA: 	
                           ... 
        case TypeB, TypeC: 
                           ...
        	case nil: 	
                           ... 
        	default: 	
                           ... 
    }
    ```
    >type-switch块中也不能使用fallthrought，如果值为nil对应的类型也为nil。default分支可以出现在任意顺序，可以包括0个或者多个分支，多个类型可以出现在同一个case分支。"

- Interface Type Embedding  [go101.org]
    >"接口类型嵌套，一个接口中可以嵌套其他的有名接口，效果就是相当于在接口中定义了被嵌套的接口中定义的方法。  示例如下： 
    >
    ```
    type Ia interface { 	
        fa() 
    }  
    		type Ib interface { 	
        fb() 
    }   
    		interface { 	
        	Ia 	
        Ib 
    }  
    ```
    >下面这个接口嵌套了Ia、Ib： 
    >
    ```
    interface { 	
        Ia 	
        Ib 
    } 
    ``` 
    与直接在接口中定义这两个方法没什么差别： 
    >
    ```
    type Ic interface { 	
        fa() 	
        fb() 
    }
    ```  
    >如果两个I接口中定义了相同的方法原型，是不允许相互嵌套的，例如，接着上面的例子，按下面这样嵌套就是非法的，因为Ia、Ic以及Ib、Ic中定义了相同的方法原型： 
    >
    ```
    interface { 	
        Ia 	
        Ic 
    }  
    interface { 	
        Ib 	
        Ic 
    }
    ```

- Interface Values Involved Comparisons  [go101.org]
    >"接口值相关的比较，涉及到两种情况： 
    >- 比较一个非接口值和一个接口值； 
    >- 比较两个接口值；  
    >
    >比较非接口值和接口值时，会先检查非接口值是否实现了该接口，没有的话二者不相等，如果实现了则将非接口值转换为接口值，然后继续比较两个接口值是否相等，也就是说最终还是转换成两个接口值来进行最终比较。  
    >
    >比较两个接口值过程： 
    >- 如果两个接口值都是nil，那么二者相等； 
    >- 如果一个接口值为nil，另一个不为nil，则二者不相等； 
    >- 如果两个接口值都不为nil，则需要比较二者的dynamic type和dynamic vlaue。如果二者的dynamic type不相同则二者肯定不相等；若dynamic type相同但是不可比较则二者也不相等；如果dynamic type相同且可比较，那么继续比较dynamic value是否相同，若相同则二者相等，反之则不相等。  
    >
    >总之，就是比较dynamic type和dynamic value。"

- The Internal Structure Of Interface Values  [go101.org]
    >"interface的内部结构表示，对空接口类型和非空接口类型采用两个不同的结构体来表示，区别就是空接口类型不需要查询接口方法实现地址，非空接口类型需要查询接口方法实现地址。
    >
    ```
    // 空接口类型
    type eface struct {
        _type *_type  // 指向类型
        data  unsafe.Pointer
    }
    // 非空接口类型
    type iface struct {
        tab  *itab   // 指向查询表，查询接口实现方法
        data unsafe.Pointer
    }
    ```
    >这个是go1.10中的表示，这样看比较抽象，按下面这两个结构体来理解会更简单明了。
    >
    ```
    // 空接口类型
    type _interface struct {
    	dynamicType  *_type         // the dynamic type
    	dynamicValue unsafe.Pointer // the dynamic value
    }
    // 非空接口类型
    type _interface struct {
    	dynamicTypeInfo *struct {
    		dynamicType *_type       // the dynamic type
    		methods     []*_function // implemented methods
    	}
    	dynamicValue unsafe.Pointer // the dynamic value
    }
    ```
    >写了个程序验证一下small size的val赋值给空接口的情况，发现即便是很小的val，也是被拷贝了一份的，然后将新拷贝到的目的地址设置为动态值字段的值。
    >
    ```
    type Ia interface{}
    type Ib interface{}
    func main() {
    	// 验证下small size，空接口类型赋值
    	var a uint64 = 0x1
    	fmt.Printf("%p\n", &amp;a)
    	var ia Ia
    	var ib Ib
    	ia = a
    	ib = a
    	type interfaceHeader struct {
    		dtype uintptr
    		dvalue unsafe.Pointer
    	}
    	ptr_ia := (*interfaceHeader)(unsafe.Pointer(&amp;ia))
    	fmt.Printf("%#v\n", ptr_ia)
    	fmt.Printf("%v\n", *(*uint64)(unsafe.Pointer(ptr_ia.dvalue)))
    	ptr_ib := (*interfaceHeader)(unsafe.Pointer(&amp;ib))
    	fmt.Printf("%#v\n", ptr_ib)
    	fmt.Printf("%v\n", *(*uint64)(unsafe.Pointer(ptr_ib.dvalue)))
    }
    ```
    >实际运行结果如下所示：
    >
    ```
    0xc042008160
    &amp;main.interfaceHeader{dtype:0x4b6bc0, dvalue:(unsafe.Pointer)(0xc042008168)}
    1
    &amp;main.interfaceHeader{dtype:0x4b6bc0, dvalue:(unsafe.Pointer)(0xc042008190)}
    1
    ```
    >变量a的地址与两个接口值的动态值不一样，说明还是拷贝了一份数据，并不是像之前说的对于smallsize的值直接设置到动态值字段中。"

- Values Of []T Can't Be Directly Converted To []I Even If Type T Implements Interface Type I.
    >"即使类型T实现了接口I，[]T也不能直接转换为[]I，可以在一个for循环里面逐个完成T到I元素的转换然后设置到slice里面。"

- Each Method Specified In An Interface Type Corresponds To An Implicit FunctionFor each method with name m in the method set defined by an interface type I, compilers will implicitly declare a function named I.m, which has one more input parameter, of type I, than method m. The extra parameter is the first input parameter of function I.m. A call to the function I.m(i, ...) is equivalent to the method call i.m(...).
    >"跟类型T上定义方法时编译器会生成隐式方法类似，接口方法，编译器也会为其对应的隐式方法。"

# Type Embedding

# Type-Unsafe Pointers

- Unsafe Pointers Related Conversion Rules  [go101.org]
    >"unsafe指针相关的转换规则：

- safe pointer可以与unsafe pointer通过显示类型转换来相互转换；

- uintptr值可以与unsafe pointer通过显示类型转换来相互转换。
    >如果uintptr和safe pointer之间要相互转换，需要借助unsafe pointer作为转换的桥梁，即先将uintptr转换成unsafe pointer，再将unsafe pointer转换为safe pointer。将safe pointer转换成uintptr也是类似的操作。"

- Unsafe Pointers Are Pointers And Uintptr Values Are Intergers  [go101.org]
    >"unsafe指针是指针类型，uintptr是整数类型。  uintptr虽然很可能是通过一个unsafe pointer来赋值的，但是因为它只是整数，不引用任何变量。uintptr可以参与算术运算。"

- Unused Values May Be Collected At Any Time    [go101.org]
    >"如果golang运行时发现unused values，那么可能会在随后的任何时间点回收其占用的内存。"

- Use The runtime.KeepAlive Function To Mark A Value As Still In Using (Reachable) Currently    [go101.org]
    >"对于某些unused value，golang运行时可能会在之后的任何时间点回收器占用的空间。但是通过runtime.KeepAlive方法可以告知golang运行时这个变量还在使用中，这样就可以阻止变量内存空间被回收。
    >
    ```
    func main() {
    	var vx, vy, vz int
    	x = &amp;vx
    	y = unsafe.Pointer(&amp;vy)
    	z = uintptr(unsafe.Pointer(&amp;vz))
    	// do other things ...
    	// vz is still reachable at least up to here.
    	// So it will not be garbage collected now.
    	runtime.KeepAlive(&amp;vz)
    }
    ```
    >本来执行完 z = uintptr(unsafe.Pointer(&amp;vz))之后，vz就编程unused value了，为了将其标识为used，调用runtime.KeepAlive(&amp;vz)来将&amp;vz这个指针值指向的value标记位used。"

- *unsafe.Pointer Is A General Safe Pointer Type  [go101.org]
    >"注意safe.Pointer是一个不安全指针，而*safe.Pointer是一个通用的安全指针。他们两者之间可以通过unsafe.Pointer进行转换。
    >
    ```
    func main() {
    	x := 123 // of type int
    	p := unsafe.Pointer(&amp;x)
    	pp := &amp;p // of type *unsafe.Pointer
    	p = unsafe.Pointer(pp)
    	pp = (*unsafe.Pointer)(p)
    }
    ```

- How To Use Unsafe Pointers Correctly  [go101.org]
    >"如何正确使用unsafe指针？golang官方总结了6种常见的unsafe指针的使用方式，下面一一介绍：
    >1 转换*T1为unsafe pointer，再将unsafe pointer转换为*T2
    >2 转换unsafe pointer为uintptr，然后使用uintptr值，一般是用来打印某个地址值
    >3 转换unsafe pointer为uintptr，对uintptr做些运算后再转换为unsafe pointer
    >4 调用s'y'scall.Syscall时将unsafe pointer转换为uintptr作为参数传递给syscall.Syscall方法。注意这里的指针类型向uintptr的转换必须在函数调用的同一条语句完成，编译器应该是据此获知是哪几个变量要用到，然后编译器自己执行runtime.KeepLive方法将这些uintptr参数对应的unsafe pointer指向的变量标记为used value。
    >5 uintptr是reflect.value.Pointer或者reflect.value.UnsafeAddr的返回值类型，使用时要再将uintptr转换为unsafe pointer。而且要求在同一个函数调用中完成类型转换，因为如果不这样，编译器就不会keeplive变量，也没有指针引用原来的变量，会被销毁，uintptr作为指针值就无效了。所以一般用到它的地方，就是类型转换和函数地调用紧密结合
    >6 将reflect.SliceHeader.Data和reflect.StringHeader.Data与unsafe.Pointer之间进行相互转换。"

# Type Compositions

# Reflections in Go


- Overview Of Go Reflection  [go101.org]
    >"go 1不支持用户自定义函数上的范型，go reflection为go提供了很多动态能力，这一定程度上弥补了范型缺失的尴尬，但是从cpu占用方面考虑还是没有真正的范型高效。go标准库里fmt、encoding等package都大量使用了反射。  通过reflect.Type和reflect.Value我们可以更深入地看下go value的内部表示。go reflection设计的终极目标之一是，go里面任何非反射方式的操作都可以通过反射来完成，但是现在的实现还不能100%支持，不过大多数非反射操作是可以借助反射方式来完成的，比如创建变量、执行chan-select-case等等。  借助反射可以实现某些非反射操作实现不了的操作，下面会介绍下现在的反射支持不到的操作以及可以支持到的操作。"

- The reflect.Type Type And Values  [go101.org]
    >"reflect.TypeOf(val)，只要val不是接口值类型，该方法就可以返回一个reflect.Type值，该值代表了该val的类型信息。其实该方法入参是interface{}，意味着可以接受任何方法，但是这里除去接口值类型，该方法先将val转换为接口值，然后再提取动态类型信息存储到reflect.Type接口值的动态类型部分。  reflect.Type是个接口类型，通过它的方法集可以查看val的类型信息。"

- The reflect.Value Type And Values  [go101.org]
    >"reflect.ValueOf(val)，该方法通过val返回一个reflect.Value值，其中记录了val的动态类型信息，以及值。通过它提供的方法不仅可以查看类型信息，也可以查看值。  reflect.ValueOf(val)与reflect.TypeOf(val)的区别是，前者返回的是一个Value（包含了类型和值），后者返回的是一个纯粹的类型Type（只包含类型）。"


