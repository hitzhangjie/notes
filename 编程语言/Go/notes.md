# Go反射、Java范型、C++模板对比

Go语言并不支持范型编程（某些内置函数是支持范型的，但是用户自定义函数不支持范型），但是可以借助reflect来一定程度上弥补这部分能力的缺失，因为要靠运行时计算所以有运行时开销，性能比不上真正的范型实现。

Java支持真正的“范型”，泛型编程的好处是，编译时对类型安全性进行检查，并且模板参数可以是任意类型不用做类型转换，既安全又方便。由于时编译时进行类型检查，并且Java编译器会对类、方法、变量级别的模板参数进行类型擦除（Type Erasure，简单理解就是将模板参数替换成Object类型或者第一个Bound的类型），无运行时开销，比Go借助反射模拟范型性能好，也不用像C++一样拷贝代码引起编译速度下降或者代码尺寸膨胀。点击查看：[Java-Type-Erasure](https://www.baeldung.com/java-type-erasure)

C++通过“模板”来支持“范型”编程，之所以加引号，是因为C++不是真正的支持范型编程，模板特例化时编译器其实是生成了一个新类的代码。C++模板是通过Macro来进行处理的，相当于复制、粘贴了类模板的代码，并替换了模板参数类型。简言之，就是一个高级的Macro处理系统。但是因为拷贝了代码，代码膨胀导致了编译速度下降、文件尺寸增加。

网上有很多类似的讨论，这里就不再一一列举了。

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































