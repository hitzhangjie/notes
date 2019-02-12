# Go反射、Java范型、C++模板对比

Go语言并不支持范型编程（某些内置函数是支持范型的，但是用户自定义函数不支持范型），但是可以借助reflect来一定程度上弥补这部分能力的缺失，因为要靠运行时计算所以有运行时开销，性能比不上真正的范型实现。

Java支持真正的“范型”，泛型编程的好处是，编译时对类型安全性进行检查，并且模板参数可以是任意类型不用做类型转换，既安全又方便。由于是在编译时进行类型检查，并且Java编译器会对类、方法、变量级别的模板参数进行类型擦除（Type Erasure，简单理解就是将模板参数替换成Object类型或者第一个Bound的类型），无运行时开销，比Go借助反射模拟范型性能好，也不用像C++一样拷贝代码引起编译速度下降或者代码尺寸膨胀。点击查看：[Java-Type-Erasure](https://www.baeldung.com/java-type-erasure)。

C++通过“模板”来支持“范型”编程，之所以加引号，是因为C++不是真正的支持范型编程，模板特例化时编译器其实是生成了一个新类的代码。C++模板是通过Macro来进行处理的，相当于复制、粘贴了类模板的代码，并替换了模板参数类型。简言之，就是一个高级的Macro处理系统。但是因为拷贝了代码，代码膨胀导致了编译速度下降、文件尺寸增加。

网上有很多相关的讨论，这里举个示例简单总结一下。

## C++ 类模板

```c++
#include <iostream>
using namespace std;

template <typename T>
class Calc{
    T t1;
    T t2;
public:
    T Add(T t1, T t2) {
        return t1 + t2;
    }
};

int main() {
    Calc<int> calc_int;
    auto sum_int = calc_int.Add(1, 2);
    cout << "1 + 2 = " << sum_int << endl;
    
    Calc<float> calc_flt;
    auto sum_flt = calc_flt.Add(1.1, 2.2);
    cout << "1.1 + 2.2 = " << sum_flt << endl;
    
    return 0;
}
```

这里其实是创建了两个不同的类，`objdump -dS`可以很清晰地看到至少创建了两个不同的方法`Add(T, T)`，可能会有人认为这是`函数重载中的name mangling`，其实不是，确实是生成了两个不同的类型，这个可以通过DWARF相关信息看出来，首先`g++ -s main.cpp`得到汇编后文件main.s，然后查看该文件内容并搜索Calc，下面两个分别表示`Calc<float>模板实例`以及`Calc<int>模板实例`，二者确实属于两个不同的类型，一个是用Ltypes95来标识，一个是用Ltypes47来标识。

![image-20181122133519746](assets/template-dwarf.png)

## Java范型

Java中范型的实现依赖于Java中的类继承机制、类型擦除、类型转换来实现，最终只会有一个类的示例。

编译时，编译器会对模板参数T进行类型擦除，这里有两种处理的情形：

- 模板参数T，没有绑定一个类型（如`T extends Comparable`），那么类型擦除后，模板参数T会用Object进行替代，同时生成对应的类型转换的代码；
- 模板参数T，有限制类型（如T extends Comparable限定了模板实参必须实现Comparable接口），那么类型擦除后，模板参数T就用这第一个bound的类型Comparable代替，同时生成对应的类型转换代码。

需要注意的是，编译时类型擦除虽然会对源码做一定的调整，某些信息看似丢失了，比如`List<String> lst`被擦除后变为了`List<Object> lst`，在运行时我们依然可以通过反射机制来获取lst的元素类型为String，则是为什么呢？这是因为类型擦除并不是删除所有类型信息，模板实参的信息会以某种形式保存下来，以便反射时使用。

```Java
// 类型擦除前代码
List<String> lst = new ArrayList();
lst.Add("hello");
lst.Add("world");
Iterator it = lst.iterator();
for ; it.hasNext(); {
    String el = it.Next();
}

// 类型擦除后代码
List lst = new ArrayList();			// 模板实参String，擦除为Object
lst.Add("hello");					// hello为String，IS-A Object关系成立
lst.Add("world");                   // ...
Iterator it = lst.iterator();       
for ; it.hasNext(); {
    String el = (String) it.Next(); // 编译器自动插入类型转换的代码
}
```

由此可见，Java的范型实现，既不会像C++那样多创建类导致代码体积膨胀，也不会带来运行时开销，也没有破坏反射依赖的信息。

# 异常处理： Go panic & recover vs C++、Java try-catch

错误处理是必须要面对的一个问题，错误又包括编译时、运行时错误，编译时错误可以在编译器处理阶段发现，运行时错误就要依赖语言提供的错误处理机制来捕获，像C++、Java都提供了try-catch的能力，Go里面没有try-catch，但是提供了panic & recover的机制来模拟异常处理。

那么这几种方式的差别是什么呢？

- 控制流执行方式不同
`try { codeblock } catch (ex e1){ handle e1 } catch (ex e2){handle e2}`，只有当codeblock抛出异常且被catch时对应的错误处理代码才会执行，但是panic、recover不同，`defer func() { e := recover ...}()`注册的函数在函数退出阶段一定会执行；

- 异常的传播方式不同
`try-catch`错误处理代码是在catch之后的block进行，如果没有被catch到则会继续向上层抛出异常等上层捕获处理……如果最终没有被catch并处理，则进程挂掉。panic的抛出有别于异常向上抛出的过程，某个goroutine中产生的panic只可以在当前goroutine结束前recover，如果当前goroutine没有recover处理该panic，则进程立即挂掉。

- 异常的处理方式不同
`try-catch`捕获了异常、处理之后依然继续走后续流程，就好像什么都没有发生过一样，但是panic会立即unwind the calling stack并层层返回并直到被recover捕获后，上层调用函数才可以重新恢复向下执行。

这里的分点描述可能有点牵强，主要是表达这个意思。

# 资源释放：Go defer vs C++ smart pointers、Java try-catch-finally 































