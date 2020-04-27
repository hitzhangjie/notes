1. depends on your workload, but sometimes it's beneficial to start a go process per CPU, set gomaxprocs to 1 and pin the process to the CPU with taskset. Here is an excerpt on that topic from the awesome fasthttp library.
- use reuseport listener
- run a separate server instance per CPU core with GOMAXPROCS = 1
- pin each server instance to a seprate CPU core using taskset
- ensure the interrupts of multiqueue network card are evenly districuted btw CPU cores. see [this article](fixme which articles) for details.
- use go 1.6 as it provides some considerable performance improvements

source: https://github.com/valyala/fasthttp#performance-optimization-tips-for-multi-core-systems

2. improved value inspection
when debugging optimized binaries produced by go 1.10, variable values were usally completely unavailable. In contrast, go 1.11, variables can usually be examined even in optimized binaries, unless they've been optimized away completely. In go 1.11, the compiler begin emitting DWARF location lists so debuggers can track variables as they move in and out of registers and reconstruct complex objects that are split across different registers and stack slots.

...

see go release notes about debugger optimization.

go build -gcflags="-a=-N -l"，新版本都要这么用了，加这些选项禁止内联、大多数优化

3. go module: both go.mod and go.sum should be checked into version control.

4. 如果函数调用过程中发生了copy栈的动作，因为只是拷贝还不行，因为可能新栈中的指针变量值还是落在旧栈空间的，如果检测到由这样的指针值的话，为这些指针值加上一个偏移量，使其指向新栈中的正确位置

5. go里面一些引用类型的定义，map、channel、function的direct part都是指针，所以这几类引用变量的赋值是没有任何问题的，理解其构成的时候理解direct part、indirect part（指针指向的结构体）就行了
```
type _map *hashtableImpl
type _channel *channelImpl
type _function *functionImpl

type _slice struct {
    elements unsafe.Pointer
    len int
    cap int
}
```

6. 编译项目时，如果go.mod中指定了某个package的版本，则拉取对应版本；
   如果没有，则拉取latest版本，latest的定义是：
   - latest tagged stable版本，
   - 没有的话，则拉latest tagged prerelease版本，
   - 没哟的话，则拉latest untagged版本，
   同时也会将其加入到go.mod中


7. go数组长度可以自动推算的，使用这种语法 b := [...]string{"hello", "world"}，这里的...编译器会自动推断长度为2。

8. `x.t, y.t = y, x`，假定存在这样的环形依赖，go的垃圾回收是解决不了的，x, y都不会被回收掉，可以在这条语句之前加 runtime.SetFinalizer(&x, finalizer)来测试

9. CAP原理，P分区耐受性，由于客观网络的不稳定，P是一定存在的，实际上谈CAP的时候，指的是在C（数据一致性）和A（可用性）之间二选一的问题。

10. //go:directive，这样的一些指定是给go工具等去解析的，往往会执行一些特殊的操作，比如pkg开发工具//go:generate用来生成代码之类的

go:nointerface
go:noescape
go:nosplit
go:noinline
go:systemstack
go:nowritebarrier
go:nowritebarrierrec
go:yeswritebarrierrec
go:cgo_unsafe_args
go:uintptrescapes

11. go版本号：vA.B.C，A主版本-不兼容性修改，B副版本-新特性，C修订版本-bug修复等修订类的工作

12. go.mod里面只会记录直接依赖的部分，但是有时候也会出现一些//indrect的标记，这个表示当前项目的构建确实依赖这个package，但是不是直接依赖

13. 可以同时import同一个package的不同版本，如：
```
import (
        "rsc.io/quote"
        quotev3 "rsc.io/quote/v3" //  ==> /v3表示使用版本v3
)
```

14. s := "hello中国", len(s)返回的是底层byte slice的长度，`for idx:=0; i<len(s); i++ {println(s[i])}`这种是遍历的byte，而不是rune，这么`for _, c := range s {println(c)}`这种遍历得到的是rune

15. go编译器当前生成的是DWARF v4调试信息，不过看上去后面应该会改成DWARF v5的。









