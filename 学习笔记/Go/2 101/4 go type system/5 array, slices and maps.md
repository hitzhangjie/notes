# Arrays, Slices and Maps

- Each element in a container has an associated key. An element value can be accessed through its associated key. The key types of map types must be comparable types. The key types of array and slice types are all the built-in type int. The keys of the elements of an array or slice are non-negative integers which mark the positions of these elements in the array or slice. The non-negative integer keys are often called indexes.  [go101.org]

  > "容器类型中的每个元素都有一个关联的key，可以借助这个key来访问元素。key必须是可比较的类型，对于map来说，key的类型只要是可比较类型就可以，对于array、slice来说，key是非负整数，其实就是索引值index。"

- Each container value has a length, which indicates how many elements are stored in that container. The valid range of the integer keys of an array or slice value is from zero (inclusive) to the length (exclusive) of the array or slice. For each value of a map type, the key values of that map value can be an arbitrary value of the key type of the map type.  [go101.org]

  > "每种类型的container value都有一个length属性来表示容器中包括的元素的数量。"

- There are also many differences between the three kinds of container types. Most of the differences originate from the differences between the value memory layouts of the three kinds of types. From the last article, value parts, we learned that an array value is composed of only one direct part, however a slice or map value may have an underlying part, which is referenced by the direct part of the slice or map value.  [go101.org]

  > "array、slice、map虽然同属container类型，但是存在一些不同之处，例如array只包括direct value part，但是slice、map还包括了indirect value part。"

- We can access an element through its key. The time complexities of element accessments on all container values are all O(1), though, generally map element accessments are several times slower than array and slice element accessments.  [go101.org]

  > "array、slice支持随机访问，其key也就是索引index，访问指定key是O(1)的时间复杂度，对于map，因为其采用哈希桶算法，时间复杂度接近O(1)。"

- Compisite Literals Are Unaddressable But Can Be Taken Addresses  Compisite Literals are unaddressable values. We have learned that struct composite literals can be taken addresses directly before. Container composite literals have no exceptions here.    [go101.org]

  > "array、slice、map复合类型字面量是不可寻址的，但是允许对其进行取地址运算，这个跟struct字面量类似，也是一种语法糖。"

- pa := &[...]bool{false, true, true, false}  [go101.org]

  > "定义一个数组类型的时候一般是用[N]type来定义，如果这里的N不想手工指定，而是想让编译器自动进行推断的话，可以这样来声明[...]type{v1,v2,...}。"

- Nested Composite Literals Can Be Simplified  If a composite literal nested many other composite literals, then those nested composited literals can simplified to the form {...}.    [go101.org]

  > "如果一个复合类型字面量嵌套了其他的复合类型字面量，那么这些被嵌套的复合类型字面量可以被简化成{...}这种形式。"

- Compare Container Values  As which has mentioned in the article overview of Go type system, map and slice types are uncomparable types. So map and slice types can't be used as map key types.  Although a slice or map value can't be compared with another slice or map value (or itself), it can be compared to the bare untyped nil identifier to check whether or not the slice or map value is a zero value.  Most array types are comparable, except the ones whose element types are uncomparable types.  When comparing two values of the same array type, each of their elements will be compared. The two array values are equal only if all of their corresponding elements are equal.  [go101.org]

  > "container value的比较：
  > 1）map、slice是不可比较类型，其内部存储的元素可以是其自身（如type T = map[interface{}]interface{}，var XX T; xx[T] = T;，这会导致无穷递归。尽管map、slice是不可比较类型但是其可以与字面量nil进行比较。
  > 2）array中如果包括了不可比较类型的元素的话，那么这个array也是不可比较的；两个array钟存储的元素完全相同时，两个array才算是相同。"

- Access And Modify Container Elements  The element associated to key k stored in a container value v can be represented with the syntax form v[k].    [go101.org]

  > "访问和修改container（包括array、slice、map）中的元素都是通过如下这个统一的形式 v[k] 进行的，其中v代表一个container value，k代表key，对于array，k是非负且小于array长度的整数值；对于slice也是；对于map，k是kv键值对中的k。"

- Container Assignments  If a map is assigned to another map, then the two maps will share all (underlying) elements.  Like map assignments, if a slice is assigned to another slice, they will share all (underlying) elements.  When an array is assigned to another array, all the elements are copied from the source one to the destination one. The two arrays don't share any elements.    [go101.org]

  > "容器赋值操作，将一个map赋值给另一个map，这两个map将共享相同的内部存储，将一个slice赋值一个slice也是这样，这与map和slice的类型定义有关。将一个数组赋值给另一个数组是会拷贝数组元素到另一个数组，两个数组不共享内部存储。"

- Check Lengths And Capacities Of Container Values  Besides the length property, each container value also has a capactiy property. The capacity of an array is always equal to the length of the array. The capacity of a map is unlimited. So, in practice, only capacities of slice values are meaningful. The capacity of a slice is always equal to or larger than the length of the slice.  [go101.org]

  > "container value除了length属性以外，还有一个属性capacity，数组的capacity等于length，map的capacity是无上限的，只有slice的capacity在实际开发中才有意义，slice的capacity大于等于其length。"

- We can use the built-in len function to get the length of a container value, and use the built-in cap function to get the capacity of a container value.  [go101.org]

  > "实际测试发现，无法通过函数cap对map计算容量，编译会报错；但是可以通过函数cap对array和slice计算容量。"

- func main() { 	s0 := []int{2, 3, 5} 	s1 := append(s0, 7)      // append one element 	s2 := append(s1, 11, 13) // append two elements 	fmt.Println(s0, cap(s0)) // [2 3 5] 3 	fmt.Println(s1, cap(s1)) // [2 3 5 7] 6 	fmt.Println(s2, cap(s2)) // [2 3 5 7 11 13] 6 	s3 := append(s0)         // <=> s3 := s0 	s4 := append(s0, s0...)  // append all elements of s0 	fmt.Println(s3, cap(s3)) // [2 3 5] 3 	fmt.Println(s4, cap(s4)) // [2 3 5 2 3 5] 6 	s0[0], s1[0] = 99, 789 	fmt.Println(s2[0], s3[0], s4[0]) // 789 99 2 }  [go101.org]

  > "slice在append的时候如果空间不够了就会按照内置数组容量翻倍的规则取开辟新的slice空间，原来的slice header指向的数组如果仍然被引用的话不会被释放。结合这里的测试代码以及下面的slice空间分配示意图体会一下这里slice header中各个字段的变化。"

- So, s1 and s2 share some elements, s0 and s3 share all elements, and s4 doesn't share elements with others. The following picture depicted the memory layouts of these slices at the end of the above program.    [go101.org]

  > "结合示意图、上方的源代码来学习下对slice执行append操作时slice header中各个字段的变化情况。"

- Create Slices And Maps With The Built-in make Function  Besides using composite literals to create map and slice values, we can also use the built-in make function to create map and slice values. The built-in make function can't be used to create array values.    [go101.org]

  > "除了使用复合类型字面量来创建map、slice，也可以通过golang内置的make来创建。使用make创建时，注意可以指定容纳至少n个元素的map，如make(M, n)也可以让golang自己管理make(M)；对于slice可以指定最大capacity，如make([]int, 16)，也可以不指定，如make([]int)。"

- Allocate Containers With The Built-in new Function  From the article pointers in Go, we learned that we can also call the built-in new function to allocate a value of any type and get a pointer which references the allocated value. The allocated value is a zero value of its type. For this reason, it is a nonsense to use new function to create map and slice values.  It is not totally a nonsense to allocate a zero value of an array type with the built-in new fucntion. However, it is seldom to do this in practice    [go101.org]

  > "对于创建container value，使用复合类型字面量、make函数这两种方式更加常见，new不适合创建复合类型字面量。new(type)会分配一块type类型的内存空间，并将这段内存初始化为0值，对于符合类型来说，其底层表示归根结底是struct这样的结构体，将各个字段初始化为0值之后对我们来说没有任何意义。所以不要使用new来创建container value。"

- Derive Slices From Arrays And Slices  We can derive a new slice from an array or slice by using the subslice syntax forms. The elements of the derived slice and the base array or slice are hosted on the same underlying continuous memory segment. In other words, the derived slice and the base array or slice may share some contiguous elements.  There are two subslice syntax forms (baseContainer is an array or slice): baseContainer[low : high]       // two-index form baseContainer[low : high : max] // three-index form   [go101.org]

  > "通过一个array或slice得到其子slice，有如下两种形式可共使用。其中必须满足low &lt;= high &lt;= max &lt;= cap(baseContainer)，否则会panic。"

- Copy Slice Elements With The Built-in copy Function  We can use the built-in copy function to copy elements from one slice to another, the types of the two slices are not required to be identical, but their element types must be identical. The first argument of the copy function is the destination slice and the second one is the source slice. The two arguments can overlap some elements. The copy function returns the number of elements copied, which will be the smaller one of the lengths of the two arguments.  With the help of the subslice syntax, we can use the copy function to copy elements between two arrays or between an array and a slice.    [go101.org]

  > "通过内置的copy函数可以将一个slice钟的元素拷贝到另一个slice中去，允许dest、src slice存在内置数组的重叠部分，拷贝的元素数量是dest、src slice二者中length的最小值。"

- Container Element Iterations  In Go, keys and elements of a container value can be iterated with the following syntax:  for key, element = range aContainer { 	// use key and element ... }   [go101.org]

  > "对于container value中元素的遍历操作，可以使用这种形式，for key, element := range aContainer {...}，对于array、slice而言key就是idx，val就是element，对于map而言key就是kv键值对中的key，v就是element。迭代的时候其实可以直接把element给省略掉，编程这种形式for key := range aContainer {...}，然后可以借助key来访问对应的element。对于 for-range aContainer {...} 迭代形式，有一个非常重要的点提一下，这里的for-range迭代的实际上是变量aContainer的拷贝（拷贝aContainer的direct value part），所以对于一个数组其实就是一份完整的拷贝，对于slice或map拷贝其direct value part。for-range一个数组的时候最好传递数组的指针或者数组的subslice。"

- If the second iteration is neither ignored nor omitted, then range over a nil array pointer will panic. In the following example, each of the first two loop blocks will print five indexes, however, the last one will produce a panic.  [go101.org]

  > "遍历的aContainer如果是nil，那么for-range迭代的时候不可以获取key-element pair中的element，但是尅获取key。否则会panic。"

- The memclr Optimization  Assume t0 is a literal presentation of the zero value of type T, and a is an array which element type is T, then the standard Go compiler will translate the following one-iteration-variable for-range loop block for i := range a { 	a[i] = t0 } to an internal memclr call, generally which is faster than resetting each element one by one.  The optimization also works if the ranged container is a slice. Sadly, it doesn't work if the ranged value is an array pointer (up to Go 1.10). So if you want to reset an array, don't range its pointer. In particular, it is recommended to range a slice derived from the array  [go101.org]

  > "memclr，memory clear操作，当使用for-range迭代一个slice时，使用t0为slice中的元素赋值，编译器会将其当做一个优化标识，通过memclr来快速将slice内存清零。这只是编译器对此提供的一种优化方式，只对slice有效，并且并不是标准的gc里提供的，比如我在OS X golang1.10下测试就没有t0这个变量。"

- Calls To The Built-in len And cap Functions May Be Evaluated At Compile Time  If the argument passed to a built-in function len or cap function call is an array or an array pointer value, then the call is evaluated at compile time and the ressult of the call is a typed constant with default type as the built-in type int.    [go101.org]

  > "在某些container value上调用len或cap，如果该container value是数组类型的话，因为数组类型在定义的时候已经指定了length，而且数组的capacity==length，所以编译时就可以确定len、cap无需运行时推断。"

- Modify The Length And Capacity Properties Of A Slice Individually  As above has mentioned, generally, the length and capacity of a slice value can't be modified individually. A slice value can only be overwritten as a whole by assigning another slice value to it. However we can modify the length and capacity of a slice individually by using reflections.  Example: package main  import ( 	"fmt" 	"reflect" )  func main() { 	s := make([]int, 2, 6) 	fmt.Println(len(s), cap(s)) // 2 6 	 	reflect.ValueOf(&s).Elem().SetLen(3) 	fmt.Println(len(s), cap(s)) // 3 6 	 	reflect.ValueOf(&s).Elem().SetCap(5) 	fmt.Println(len(s), cap(s)) // 3 5 } [go101.org]

  > "可以借助reflect包手动修改slice header中的字段值，这里举了个例子来修改slice header中的length和capacity。"

- Go doesn't support more slice operations, such as slice clone, element deletion and insertion, in the built-in way. We must compose the built-in ways to achieve those operations.

  > "go没有再提供其他内置的slice操作了，如slice的clone、元素删除、元素插入，但是这些操作可以死通过简单组合现有的slice内置操作来实现。"

- Go doesn't support built-in set types. However, it is easy to use a map type to simulate a set type. In practice, we often use the map type map[K]struct{} to simulate a set type. The size of the map element type struct{} is zero, elements of values of such map types don't occupy memory space.

  > "golang并没有支持内置的set类型，但是通过使用map以及基于struct{}字面量size==0这样的事实，也可以很方便地定义出set类型，如type set map[K]struct{}。"

- Please note that, all container operations are not synchronized interally. Without making using of any data synchronization technique, it is okay for multiple goroutines to read a container concurrently, but it is not okay for multiple goroutines to maniluplate a container concurrently and at least one goroutine modifies the container. The latter case will cause data races, even make goroutines panic. We must synchronize the container operations manually.

  > "container相关的操作内部都是没有同步措施的，如果多个goroutine同时对一个container value执行read操作的话，这样是没有问题的，但是如果某个goroutine来执行写操作，其他的多个goroutine执行读操作，这种情况可能会引发data race，甚至导致goroutine panic。如果存在读写并发访问container value的情况，就需要借助sync包等对其进行同步控制。"