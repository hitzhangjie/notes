# Interfaces

- Interface types are one special kind of types in Go. Interface kind plays several important roles in Go. Firstly, interface types make Go support value boxing. Consequently, through value boxing, reflection and polymorphism get supported.  [go101.org]

  > "interface类型是一种特殊的类型，它实现了value boxing操作，通过value boxing，也可以支持reflection和polymorphism。"

- What Are Interface Types?  [go101.org]

  > "每一个interface类型都定义了一个method prototype的结合，这个集合可以为空。结合中方法名不能是"_"。interface中只能定义方法原形，而不是在interface上添加方法定义，这个在前面学习method的时候已经分析了其中的原因，这里不再赘述。"

- The Method Set Of A Type  [go101.org]

  > "每一种类型都有一个与之关联的method set：
  >
  > - 对于interface类型，它的method set也就是interface声明的method prototype的集合；
  > - 对于non-interface类型，它的method set包括显示定义在该类型上的方法的原型构成的集合，还包括编译器为value receiver隐式添加的pointer receiver方法，还包括二者对应的隐式函数，如果该类型涉及到类型嵌套，还回包括编译器为其生成的隐式wrapper方法。
  >   如果有两个无名接口类型，并且它们的method set都是空的，那么这两个接口类型是完全相同的。"

- What Are Implementations?  [go101.org]

  > "- 如果类型T的method set是接口I的method set的超集，那么就说类型T实现了接口I；
  >
  > - 如果两个接口类型I1、I2都是空接口类型，那么I1、I2是互相实现了对方的；
  > - 一个接口类型I也总是实现了自身的；
  > - 任何类型都实现了一个空接口类型；
  >   golang里面类型T与接口I的实现关系是隐式实现的，没有像Java中那样的关键字“implements”来显示表名实现关系。这种隐式实现有一种好处，就是能够允许某些包中的类型实现用户自定义的接口。比如std库中的database/sql package下的类型DB、Tx都实现了如下用户自定义的接口：

  ```
  type DatabaseStorer interface {
  	Exec(query string, args ...interface{}) (Result, error)
  	Prepare(query string) (*Stmt, error)
  	Query(query string, args ...interface{}) (*Rows, error)
  }
  ```

- Value Boxing  [go101.org]

  > "如果类型T实现了接口I，那么就可以将T的值赋值给I的值，赋值过程中涉及到设置接口值的dynamic value和dynamic type：
  > 1）dynamic value
  >
  > - 如果T本身不是接口类型，那么将拷贝T的值，如果sizeof(T)&lt;=sizeof(uintptr)将直接把T的值设置到接口值的value unsafe.Pointer字段；反之新开辟一块足够大的内存将T的值拷贝过去，然后将新开辟内存的地址设置到value unsafe.Pointer。这里拷贝T的时间复杂度为O(n)，n为sizeof(T)。
  > - 如果T本身是一个接口类型，那么将拷贝T中的dynamic value到接口值中的dynamic value，时间复杂度为O(1)。
  >   2) dynamic type
  >   除了拷贝dynamic value还需要构建T的动态类型信更新到接口值的dynamic type字段，这个动态类型信息包含两部分内容：
  > - 一部分是包含一个指向itable的指针，方便通过接口值查询动态类型实现的接口方法的调用地址，借此实现polymorphism（多态）；
  > - 另一部分是包含动态类型的字段列表信息、方法信息，借此实现reflection（反射）；"

- Polymorphism  [go101.org]

  > "多态是golang interface的重要功能之一，如果类型T实现了接口I，并将T类型值tval付给I类型值ival，那么通过ival.dosomething()执行的将是类型T中定义的方法dosomething()。如果分别有类型T1、T2实现了接口I，那么为ival赋值对应的T1、T2的值，并执行ival.dosomething()将分别调用T1、T2对dosomething()的实现，从而实现多态的效果。"

- The dynamic type information stored in an interface value can be used to inspect and manipulate the values referenced by the dynamic value which is boxed in the interface value. This is called reflection in programming.  Currently (v1.10), Go doesn't support generic for custom functions and types. Reflection partially remedies the inconveniences caused by lacking of generic.  [go101.org]

  > "golang中用户自定义类型和函数无法使用泛型支持，但是可以通过反射来近似实现泛型支持。"

- Type Assertion  There are four kinds of interface value involved value conversion cases in Go

  > "有四种可能的操作： 
  >
  > - 转换非接口值为接口值，非接口类型必须实现接口； 
  > - 转换接口值到另一个接口值，源接口值类型必须实现目的接口值的类型； 
  > - 转换接口值到非接口值，非接口值类型可能实现或没实现该接口类型； 
  > - 转换接口值到另一个接口值，源接口值类型可能实现或没实现目的接口值类型； 
  >   前两种转换前面已经讲过了，是编译时就能完成的，后面两种是运行时来检查的，是通过type assertion来完成。"

- The form of a type assertion expression is i.(T)

  > "类型断言的形式是i.(T)，i称为被短断言的值asserted value，T称为被断言的类型asserted type。 
  >
  > - T可能是一个非接口类型（必须实现了接口i）； 
  > - T可能是任意一个接口。  
  >   断言会返回成功或者失败，成功时也会返回T的值：
  > - 如果T是一个非接口类型，那么i.(T)是希望获取i中的动态值，只有当i中的动态类型与T完全匹配的时候才会断言成功； 
  > - 如果T是一个及诶口类型，那么i.(T)是希望将i中的dynamic value先unboxed然后再转换为接口T类型的值，意味着i中boxed value对应的dynamic type必须实现了接口T才会断言成功。"

- If a type assersion fails, the first return result must be a zero value of the asserted type, and the second return result (assume it is present) is an untyped boolean value false.

  > "类型断言i.(T)既可以用作单值表达式，也可以用作多值表达式。 - 用作多值表达式的时候，第一个参数表示转换后的值，第二个参数表示是否断言成功； - 用作单值表达式的时候，返回值表示转换后的值，如果断言失败，会直接panic。"

- Type Switch Control Flow Block  [go101.org]

  > "type switch control flow block，可以看做是增强版的类型断言，其基本形式如下：  

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

  > type-switch块中也不能使用fallthrought，如果值为nil对应的类型也为nil。default分支可以出现在任意顺序，可以包括0个或者多个分支，多个类型可以出现在同一个case分支。"

- Interface Type Embedding  [go101.org]

  > "接口类型嵌套，一个接口中可以嵌套其他的有名接口，效果就是相当于在接口中定义了被嵌套的接口中定义的方法。  示例如下： 

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

  > 下面这个接口嵌套了Ia、Ib： 

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

  > 如果两个I接口中定义了相同的方法原型，是不允许相互嵌套的，例如，接着上面的例子，按下面这样嵌套就是非法的，因为Ia、Ic以及Ib、Ic中定义了相同的方法原型： 

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

  > "接口值相关的比较，涉及到两种情况： 
  >
  > - 比较一个非接口值和一个接口值； 
  > - 比较两个接口值；  
  >
  > 比较非接口值和接口值时，会先检查非接口值是否实现了该接口，没有的话二者不相等，如果实现了则将非接口值转换为接口值，然后继续比较两个接口值是否相等，也就是说最终还是转换成两个接口值来进行最终比较。  
  >
  > 比较两个接口值过程： 
  >
  > - 如果两个接口值都是nil，那么二者相等； 
  > - 如果一个接口值为nil，另一个不为nil，则二者不相等； 
  > - 如果两个接口值都不为nil，则需要比较二者的dynamic type和dynamic vlaue。如果二者的dynamic type不相同则二者肯定不相等；若dynamic type相同但是不可比较则二者也不相等；如果dynamic type相同且可比较，那么继续比较dynamic value是否相同，若相同则二者相等，反之则不相等。  
  >
  > 总之，就是比较dynamic type和dynamic value。"

- The Internal Structure Of Interface Values  [go101.org]

  > "interface的内部结构表示，对空接口类型和非空接口类型采用两个不同的结构体来表示，区别就是空接口类型不需要查询接口方法实现地址，非空接口类型需要查询接口方法实现地址。

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

  > 这个是go1.10中的表示，这样看比较抽象，按下面这两个结构体来理解会更简单明了。

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

  > 写了个程序验证一下small size的val赋值给空接口的情况，发现即便是很小的val，也是被拷贝了一份的，然后将新拷贝到的目的地址设置为动态值字段的值。

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

  > 实际运行结果如下所示：

  ```
  0xc042008160
  &amp;main.interfaceHeader{dtype:0x4b6bc0, dvalue:(unsafe.Pointer)(0xc042008168)}
  1
  &amp;main.interfaceHeader{dtype:0x4b6bc0, dvalue:(unsafe.Pointer)(0xc042008190)}
  1
  ```

  > 变量a的地址与两个接口值的动态值不一样，说明还是拷贝了一份数据，并不是像之前说的对于smallsize的值直接设置到动态值字段中。"

- Values Of []T Can't Be Directly Converted To []I Even If Type T Implements Interface Type I.

  > "即使类型T实现了接口I，[]T也不能直接转换为[]I，可以在一个for循环里面逐个完成T到I元素的转换然后设置到slice里面。"

- Each Method Specified In An Interface Type Corresponds To An Implicit FunctionFor each method with name m in the method set defined by an interface type I, compilers will implicitly declare a function named I.m, which has one more input parameter, of type I, than method m. The extra parameter is the first input parameter of function I.m. A call to the function I.m(i, ...) is equivalent to the method call i.m(...).

  > "跟类型T上定义方法时编译器会生成隐式方法类似，接口方法，编译器也会为其对应的隐式方法。"