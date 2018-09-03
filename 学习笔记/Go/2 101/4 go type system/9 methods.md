# Methods

- Go supports some object-orient programming features. Method is one of these features. A method is a special function which has a receiver parameter (see below). This article will explain method related concepts in Go.  [go101.org]

  > "golang中类似面向对象的部分特征，成员方法就是其中支持。方法是一种特殊类型的函数，相比普通函数，它多了一个接收者类型。  函数的内部表示如下，这个结构体可以覆盖golang里面所有类型的函数定义，包括普通函数、成员方法、接口方法等。  

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

  > 为类型T或者*T定义方法（接收者类型为T或者*T），必须满足如下几个条件：
  >
  > - T必须是已经定义过的类型；
  > - T与当前方法定义必须在同一个package下面；
  > - T不能是指针；
  > - T不能是接口类型；
  >
  > 1）T为什么不能是指针？
  > 允许为指向类型的指针*T添加方法，但是不允许为指针类型本身添加方法。按现有golang的实现方式，为指针类型添加方法会导致方法调用时的歧义，看下面这个示例程序。

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

  > 示例程序中v3.Get()存在调用歧义，不知道该调用哪个方法了。如果要支持在指针这种receiver-type上定义方法，golang编译器势必要实现地更复杂才能支持到，指针本来就比较容易破坏可读性，还要在一种指针类型上定义方法，对使用者、编译器开发者而言可能都是件费力不讨好的事情。
  > 2）T为什么不能接口类型？
  > 这没有什么高深的，只是golang spec和现在的运行时实现不支持而已。golang现在的实现里，interface类型只能包括方法类型（注意是类型），但是不能方法实现，结构体才可以包括方法的实现。
  > 再强调一遍，接口类型里面只包括方法的类型，而不包括方法的定义。当某个类型实现了某个接口声明的方法的时候，我们可以将这个类型值赋值给该接口值，此时接口实例里面会更新其dynamic value和dynamic type字段。
  > 如果我们把某个类型T的值赋值给接口变量iface的话，可以细分为几种情景：
  > 1）如果iface对应接口类型是interface{}，并且T值小于等于sizeof(uintptr)，那么dynamic value就直接是T的值的拷贝，反之就开辟内存拷贝T的值，并将新开辟内存的地址设置到dynamic value字段，dynamic type当然就指向类型T定义了。

  ```
    type eface struct {
        _type *_type
        data  unsafe.Pointer
    }
  ```

  > 2）如果iface对应接口类型interface{methods-list}，这个时候dynamic value还是与1）中同样的处理，但是dynamic type处理方式不同，需要对方法调用地址进行处理。这时会创建一个itable，这个itable里面保存了iface的接口类型以及接口中声明的各个方法类型对应的调用地址。然后将iface里面的tab指向该itable。
  > 这样当通过接口调用方法的时候，就会通过tab查询到该方法的实际调用地址为T中方法的地址。从T值赋值给iface过程中，到通过iface多态调用T的方法，这整个逻辑处理过程中只有对接口类型中声明方法、T中定义方法的处理，如果说就算允许为接口添加方法不算语法错误，并允许算作是接口中的方法类型，那么现在的itable处理逻辑也支持不到。
  > 不同的编程语言对函数调用的多态实现有不同的思路，c++是通过填充基本类型的虚函数表的方式，golang是通过类似的这样一种查询表的形式。总结一下就是并非golang无法通过扩展支持在接口上添加方法，只是这样是否真的有必要，值得商榷。
  >
  > ```
  >  type iface struct {
  >      tab  *itab
  >      data unsafe.Pointer
  >  }
  > ```
  >
  > 参考“接口与itable关系”：<a target="_blank" rel="nofollow" class="link " href="https://research.swtch.com/interfaces" data-auto="true">https://research.swtch.com/interfaces</a>。"

- We can also declare methods for alias types of the T and *T types specified above. The effect is the same as declaring methods for the T and *T types themselves.  [go101.org]

  > 也可以在类型T或者*T的别名上定义方法，效果跟直接在T或者*T上定义类似。

- From the above listed conditions, we will get the conclusion that we can never (explicitly) declare methods for following types.

  > - 内置基本数据类型如int、string，不能为其定义方法；
  > - 接口类型，也不能为其定义方法，原因上面也分析过了；
  > - 无名类型包括无名数组、map、slice、function、chan、struct，也不能为其定义方法，*T除外。另外，如果无名struct匿名嵌套了其他的类型并且这个被嵌套类型有方法的话，编译器是会为这个struct生成一些wrapper方法的，以保证可以通过这个无名结构体调用被嵌套类型的方法。"

- In some other programming languages, the receiver parameter names are always the implicit this, which is not a recommended identifier for receiver parameter names in Go.The receiver of type *T are called pointer receiver, non-pointer receivers are called value receivers.

  > 为啥叫接收者类型呢？因为调用对象的方法就好比是给这个对象发送一个消息，然后对象对此作出处理，所以这个调用对象也被称为消息接收者，对应的类型就称为接收者类型了。
  > 其他语言里面，这样的接收者往往是用的this，比如js、c++、java等，但是golang里面不是这样的，因为它对接收者做了细分，比如“value receiver”或者“pointer receiver”，前者不可以修改接收者的值，但是后者可以。看上去有点像c++中对方法的const修饰不允许修改对象状态，non-const方法才可以修改对象状态。

- Each Method Corresponds To An Implicit Function

  > golang编译器会为每个T或者*T上的方法定义生成一个隐式函数，如：

  ```
    func (b Book) Pages() int {
        return b.pages
    }
    func (b *Book) SetPages(pages int) {
        b.pages = pages
    }
  ```

  > 会被转换为：

  ```
    func Book.Pages(b Book) int {
        return b.pages // the body is the same as the Pages method
    }
    func (*Book).SetPages(b *Book, pages int) {
        b.pages = pages // the body is the same as the SetPages method
    }
  ```

  > 转换后，接收者被作为生成的隐式函数的第一个参数，函数体部分不变。注意，编译器生成的隐式函数与用户定义的方法是同时存在的，并不是说编译器将用户定义的方法转换为另一种形式。
  > 前面提到的编译器自动为成员方法生成了对应的隐式函数，用户代码中不能定义隐式函数这种形式的方法，但是可以在代码中直接调用隐式函数，示例代码如下：

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

  > 在类型T上定义的方法，尽管receiver-type是value receiver不是pointer receiver，但是我们在调用的时候仍然可以通过T指针来调用成员方法，为什么呢？因为编译器对每个value-receiver方法会自动生成一个与之对应的pointer-receiver方法，同时也会为这个方法生成对应的隐式函数。
  >
  > ```
  >  type T struct {}
  >  func (t T) doSomething() {
  >  }
  >  func main() {
  >    t := &amp;T{}
  >    t.doSomething()
  >  }
  > ```
  >
  > 这种调用方式仍然是ok的，因为编译器隐式地创建了一个成员方法：
  >
  > ```
  >  func (t *T) doSomething() {
  >    T.doSomething(*t)
  >  }
  > ```
  >
  > 这个成员方法相当于调用了原来value-receiver方法对应的隐式函数，所以是ok的。
  > 另外，假如用户在*T上定义了一个成员方法，能不能通过T的值来调用该方法呢？可以！实现原理是否一样呢？不一样！
  > 看下面的示例代码：
  >
  > ```
  >  type T struct {}
  >  func (t *T) doSomething{
  >  }
  >  func main() {
  >    t := T{}
  >    t.doSomething()
  >  }
  > ```
  >
  > 这种形式其实是一种语法糖，编译器会将其转换成(&amp;t).doSomething()调用value-receiver的方法。但是有一点要注意的是，这种语法糖形式的调用，必须保证t是可寻址的（注意golang里面返回值是不可寻址的）。"

- Syntax sugar for pointer receiver method func(b *Book) SetPages(val int), book := Book{}; (&book).SetPages(123) can be simplified to book.SetPages(123).

  > 对于pointer-receiver方法，如果是通过value来调用该方法的话，只要value是可寻址的，那么编译器会将先取value得地址，再调用对应的pointer-receiver方法，只是一个语法糖转换而已（需要注意的是golang里面的函数返回值是不可寻址的）。

- Receiver Arguments Are Passed By Copy

  > "方法调用时传递的receiver-type value也是通过值传递的形式拷贝过来的，如果对这里的value进行了修改，那么将不会影响到外部原始value的direct part的值。"

- Should A Method Be Declared With Pointer Receiver Or Value Receiver

  > 一个方法到底应该选择pointer receiver还是value receiver呢？
  > 根据前面的内容，某些情况下必须将receiver type定义生成pointer receiver，比如希望对对象本身作出修改，并且更新receiver的direct value part。实际上如果我们将所有的方法都定义到pointer-receiver上是没有任何逻辑问题的，但是确实需要考虑一下选择value-receiver或者pointer-receiver那种性能更好。
  >
  > - 太多的指针拷贝，会加重垃圾收集器的负担；
  > - 如果receiver-type的size比较大，那么receiver拷贝将是一个不能忽视的问题，特别是当传递的对象是一个interface value的话将涉及到两次拷贝，一次是接口值的拷贝，一次是接口动态值的拷贝。而pointer value都是size较小的。实际上标准go编译器和运行时，除了array和struct类型都是比较小的类型。struct字段比较少的话也是size比较小的。
  > - 同一个receiver type类型上同时混杂着value-receiver和pointer-receiver，方法被并发调用的话更容易引入data race。
  > - sync包下的value不应该不拷贝，所以如果receiver-type是struct类型，而这个类型里面嵌套了sync包下的类型的话，将引发一些问题。
  >   如果很难以决定到底该采取哪一种receiver-type，那就使用pointer-receiver吧。"