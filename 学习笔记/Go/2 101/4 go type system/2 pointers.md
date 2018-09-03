# Pointers

- A memory address means an offset (number of bytes) from the start point of the whole memory managed by a system (generally, operation system).  Generally, a memory address is stored as an unsigned native (interger) word. The size of a native word is 4 (bytes) on 32-bit architectures and 8 (bytes) on 64-bit architectures. So the theoretical maximum memory space size is 232 bytes, a.k.a. 4GB (1GB == 230 bytes), on 32-bit architectures, and is 234GB (16 exibytes) on 64-bit architectures.  [go101.org]

  > "内存地址指的一个相对于系统管理内存起始地址的偏移量，对于一个处理器，其可寻址的内存地址空间是固定的，内存地址位宽必须要与处理器设计对齐，保证可以寻址与处理器一致的可寻址内存地址空间。"

- The address of a value means the start address of the memory segment occupied by the direct part of the value.  [go101.org]

  > "对于一个值value的地址，往往指的是这个value的direct part的起始地址。"

- A pointer is a special value, which can storage a memory address. In fact, we often call a memory address as a pointer, and vice versa.  Generally, the stored memory address in a pointer is the address of another value. Unlike C language, for safety reason, there are some restrictions made for Go pointers. Please read the following sections for details.  [go101.org]

  > "指针是存储内存地址的特殊类型，c、c++里面对指针不加限制，golang希望保证指针操作的安全性，对指针加了一些限制，比如不允许对指针进行计算，但是为了保证一定的灵活性，unsafe.Pointer提供了类似void *一样的指针计算能力。"

- We can declare named pointer types, but generally this is not recommended. Unnamed pointer types have better readabilities than named ones.  [go101.org]

  > "对于指针类型，更加推荐使用无名指针类型，因为这样代码可读性更强。"

- There are two ways to get a non-nil pointer value. The built-in new function can be used to allocate memory for a value of any type. new(T) will allocate memory for a T value and return the address of the T value. The allocated value is a zero value of type T. The returned address is viewed as a pointer value of type *T. We can also take the addresses of some values in Go. Values can be taken addresses are called addressable values. For an addressable value t of type T, we can use the expression &t to take the address of t, where & is the operator to take value addresses. The type of &t is viewed as *T.   All variables are addressable and all constants are unaddressable.  [go101.org]

  > "golang里面如何获得一个value的指针呢？有两种方式，一种是通过new(T)来获得类型T的指针，一种是通过对可寻址的value进行取地址运算&amp;value。与c、c++关键字new不同，golang里的new并不限定分配的内存空间是一定在heap里面，也可能在栈上。另外，变量一定是可寻址的，常量一定是不可寻址的。"

- Given a pointer value p of type Tp, how to get the value at the address stored in the pointer? Just use the expression *p, where * is called dereference operator. *p is call the dereference of poiner p. Pointer dereference is the inverse process of address taking. The result of *p is a value of the base type of Tp.  [go101.org]

  > "如何解除指针的引用，指针解引用相对于取地址运算来说是个相反的过程，跟c、c++类似，对于指针p，可以通过*p解引用。"

- Unlike C language, Go is a language supporting garbage collection, so return the address of a local variable is absolutely safe in Go.  [go101.org]

  > "golang编译器会根据对变量的逃逸分析决定是把变量分配在stack上海市heap上，在c、c++里面返回函数局部变量的指针是有问题的，解引用时变量已经被销毁。但是在golang里面，返回局部变量的指针是完全没问题的，因为逃逸的局部变量是被分配在heap上的。"

- Restrictions On Pointers In Go  For safety reasons, Go makes some restrictions to guarantee pointers in Go are always legal and safe. By applying these restrictions, Go keeps the benefits of pointers, and avoids the dangerousness of pointers at the same time.  [go101.org]

  > "golang希望保留指针的优势，去掉指针危险的一面，因此对指针加了一些限制：1）不允许对指针进行算术运算 2）某类型的指针值不允许转换成任意其他指针类型 3）某类型的指针值不允许与其他任意指针类型做比较 4）某类型的指针值不允许为其他任意指针类型赋值。尽管golang加了如下限制，但是unsafe package也提供了unsafe.Pointer可以允许你像c、c++中一样灵活地使用指针，从而绕过golang这里的限制。"