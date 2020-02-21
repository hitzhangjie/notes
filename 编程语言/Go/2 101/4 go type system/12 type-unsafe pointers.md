# Type-Unsafe Pointers

- Unsafe Pointers Related Conversion Rules  [go101.org]

  > "unsafe指针相关的转换规则：

- safe pointer可以与unsafe pointer通过显示类型转换来相互转换；

- uintptr值可以与unsafe pointer通过显示类型转换来相互转换。

  > 如果uintptr和safe pointer之间要相互转换，需要借助unsafe pointer作为转换的桥梁，即先将uintptr转换成unsafe pointer，再将unsafe pointer转换为safe pointer。将safe pointer转换成uintptr也是类似的操作。"

- Unsafe Pointers Are Pointers And Uintptr Values Are Intergers  [go101.org]

  > "unsafe指针是指针类型，uintptr是整数类型。  uintptr虽然很可能是通过一个unsafe pointer来赋值的，但是因为它只是整数，不引用任何变量。uintptr可以参与算术运算。"

- Unused Values May Be Collected At Any Time    [go101.org]

  > "如果golang运行时发现unused values，那么可能会在随后的任何时间点回收其占用的内存。"

- Use The runtime.KeepAlive Function To Mark A Value As Still In Using (Reachable) Currently    [go101.org]

  > "对于某些unused value，golang运行时可能会在之后的任何时间点回收器占用的空间。但是通过runtime.KeepAlive方法可以告知golang运行时这个变量还在使用中，这样就可以阻止变量内存空间被回收。

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

  > 本来执行完 z = uintptr(unsafe.Pointer(&amp;vz))之后，vz就编程unused value了，为了将其标识为used，调用runtime.KeepAlive(&amp;vz)来将&amp;vz这个指针值指向的value标记位used。"

- *unsafe.Pointer Is A General Safe Pointer Type  [go101.org]

  > "注意safe.Pointer是一个不安全指针，而*safe.Pointer是一个通用的安全指针。他们两者之间可以通过unsafe.Pointer进行转换。

  ```
  func main() {
  	x := 123 // of type int
  	p := unsafe.Pointer(&x)
  	pp := &p // of type *unsafe.Pointer
  	p = unsafe.Pointer(pp)
  	pp = (*unsafe.Pointer)(p)
  }
  ```

- How To Use Unsafe Pointers Correctly  [go101.org]

  > "如何正确使用unsafe指针？golang官方总结了6种常见的unsafe指针的使用方式，下面一一介绍：
  > 1 转换*T1为unsafe pointer，再将unsafe pointer转换为*T2
  > 2 转换unsafe pointer为uintptr，然后使用uintptr值，一般是用来打印某个地址值
  > 3 转换unsafe pointer为uintptr，对uintptr做些运算后再转换为unsafe pointer
  > 4 调用s'y'scall.Syscall时将unsafe pointer转换为uintptr作为参数传递给syscall.Syscall方法。注意这里的指针类型向uintptr的转换必须在函数调用的同一条语句完成，编译器应该是据此获知是哪几个变量要用到，然后编译器自己执行runtime.KeepLive方法将这些uintptr参数对应的unsafe pointer指向的变量标记为used value。
  > 5 uintptr是reflect.value.Pointer或者reflect.value.UnsafeAddr的返回值类型，使用时要再将uintptr转换为unsafe pointer。而且要求在同一个函数调用中完成类型转换，因为如果不这样，编译器就不会keeplive变量，也没有指针引用原来的变量，会被销毁，uintptr作为指针值就无效了。所以一般用到它的地方，就是类型转换和函数地调用紧密结合
  > 6 将reflect.SliceHeader.Data和reflect.StringHeader.Data与unsafe.Pointer之间进行相互转换。"