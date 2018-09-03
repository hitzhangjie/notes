# Value Parts

- Each values of the these kinds of types is often composed of one direct part and one or several underlying indirect parts, and the underlying value part is referenced by the direct value part. The following picture dipicts a mult-part value.    [go101.org]

  > "golang里面的数据类型可以分为两类，一类是只包括direct value part的数据类型，这部分对应于c风格中的一些数据类型如book、数值、数组、unsafe.Pointer等，另一类是包括direct value part和indirect value part这两部分的数据类型，其中indirect value part由direct value part引用，包括slice、map、chan、func、interface、string等。"

- We have learned Go pointers in the last article. The pointer types in that article are type-safe pointer types. In fact, Go also supports type-unsafe pointer types. The unsafe.Pointer type provided in the unsafe standard package is like void* in C language. Types whose underlying types are unsafe.Pointer are called unsafe pointer types in Go 101.  [go101.org]

  > golang支持两种类型的指针，一种是安全的，一种是不安全的。前一种就是说go对指针增加了各种安全限制的指针，后一种就是说的unsafe.Pointer指针。

- Internal Definitions Of Map, Channel And Function Types  The internal definitions of map, channel and function types are similar: // map types type _map *hashtableImpl // currently, for the standard Go compiler,                          // Go maps are hashtables actually.  // channel types type _channel *channelImpl  // function types type _function *functionImpl So, internally, types of the three families are just pointer types. The zero values of these types are all represented by the predeclared nil identifier. For any non-nil value of these types, its direct part (a pointer) references its indirect underlying implementation part.  In fact, the indirect underlying part of a value of the three kinds of types may also reference deeper indirect underlying parts.    [go101.org]

  > map、chan、func属于引用类型，其类型定义本质上是有名指针类型。slice也属于引用类型，但是一个slice是通过slice header来唯一确定的，为什么slice不定义成一个有名指针类型呢？这是因为slice要实现底层内存空间的共享，为了实现多个slice对底层内存空间的共享就只能分别通过各自的slice header来引用该底层内存空间，只是各个slice header的不同cap、len限定了访问内置数组的不同range。

- Internal Definition Of Slice Types  The internal definition of slice types is like: // slice types type _slice struct { 	elements unsafe.Pointer // underlying elements 	len      int            // number of elements 	cap      int            // capacity }   [go101.org]

  > "slice的内部定义，slice内部的elements是其存储数据的内置数组，len、cap限定了当前range可以访问的内置数组的range。通过一个slice可以衍生出其他的slice，其实就是对应的slice header里面cap、len设置了不同的值。"

- Internal Definition Of String Types  Below is the internal definition for string types: // string types type _string struct { 	elements *byte // underlying bytes 	len      int   // number of bytes }   [go101.org]

  > "string类型的定义，其实也是一个指针wrapper类型的struct。"

- Internal Definition Of Interface Types  Below is the internal definition for general interface types: // general interface types type _interface struct { 	dynamicType  *_type         // the dynamic type 	dynamicValue unsafe.Pointer // the dynamic value } Internally, interface types are also pointer wrapper struct types. The internal definition of an interface type has two pointer fields. The zero values of interface types are also represented by the predeclared nil identifier. Each non-nil interface value has two indirect underlying parts which store the dynamic type and dynamic value of that interface value. The two indirect parts are referenced by the dynamicType and dynamicValue fields of that interface value.  In fact, for the standard Go compiler, the above definition is only used for blank interface types. Blank interface types are the interface types which don't specify any methods. We can learn more about interfaces in the article interfaces in Go later. For non-blank interface types, a definition like the following one is used. // general interface types type _interface struct { 	dynamicTypeInfo *struct { 		dynamicType *_type       // the dynamic type 		methods     []*_function // implemented methods 	} 	dynamicValue unsafe.Pointer // the dynamic value } The methods field of the dynamicTypeInfo field of an interface value stores the implemented methods of the dynamic type of the interface value for the (interface) type of the interface value.    [go101.org]

  > "interface也是引用类型，本质上它也是指针wrapper的struct，对于一个空的interface定义而言，通过type _interface struct {*_type, unsafe.Pointer}这样的结构体来对其进行描述就足够了，只需要在两个字段中记录引用的动态类型指针、动态类型值就足够了。对于定义了方法的interface来说，除了上述内容，还需要定义这个动态类型中对接口方法的实现的func的指针。因此有接口方法的interface，需要下面这个结构体来定义。"

- Now we have learned that the internal definitions of the types in the second category are either pointer types or struct types. Certainly, Go compilers will never view the types in the second category as pointer types or struct types in user programs. These definitions are just used internally by Go runtimes.  [go101.org]

  > "前面描述了golang里面第二类数据类型的定义方式，要么是指针，要么是指针wrapper struct。当然了，golang的编译器并不会将用户程序中的第二类数据类型看做是指针类型或者struct类型，这些定义只是在golang运行时内部使用时使用。"

- In Go, each value assignment (including parameter passing, etc) is a shallow value copy if the involved destination and source values have the same type (if their types are different, we can think that the source value will be implicitly converted to the destination type before doing that assignment). In other words, only the direct part of the soruce value is copied to the destination value in an value assignment. If the source value has underlying value part(s), then the direct parts of the destination and source values will reference the same underlying value part(s), in other words, the destination and source values will share the same underlying value part(s).    [go101.org]

  > "golang里面的赋值操作，都是对数据类型对应值中的direct value part进行shadow copy，值中包括indirect value part的部分并不会进行拷贝。这意味着如果一个value包括了indirect value part，value1赋值给value2之后，value1和value2将引用相同的indirect value part。"

- Since an indirect underlying part may not belong to any value exclusively, it doesn't contribute to the size returned by the unsafe.Sizeof function.  [go101.org]

  > "为什么unsafe.Sizeof只返回value中的direct value part部分的内存空间大小，却不返回indirect value part部分的内存空间大小呢？以slice为例，多个slice可能引用相同的内部存储结构，同一个内部存储结构并不是排他性的属于某一个slice，因此unsafe.Sizeof不会将indirect value part计算在内。"