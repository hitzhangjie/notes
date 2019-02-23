go语言提供了c、go互相调用的能力。

比较常见的是在go中借助c头文件、共享库来调用c代码，通过cgo指令可以指定linkers要连接的共享库的搜索路径。下面是一个示例。

file: add.h

```c
#ifndef _ADD_H_
#define _ADD_H_

int add(int, int);

#endif
```

file: add.c

```c
int add(int n, int m)
{
    return n + m;
}
```

首先将add.c编译成共享库：

```bash
gcc -c -fpic add.c
gcc -shared -o libadd.so add.o
```

file: main.go

```go
import "fmt"

/*
# cgo CFLAGS: -I${SRCDIR}
# cgo LDFLAGS: -L${SRCDIR} -ladd
#include "add.h"
*/
import "C"

func main() {
    fmt.Printf("1 + 2 = %v\n", C.add(1, 2))
}
```

`import "C"`必须紧跟在cgo相关的指令、说明后面，它们以注释的形式包括起来，cgo编译器会处理这里的信息。如cgo指令 `-I${SRCDIR}`会指导从哪里寻找add.h，`cgo -L${SRCDIR}`会指导从哪里寻找libadd.so。

```bash
go build main.go -o main
./main
```

go程序编译的时候没有问题，但是**运行的时候却提示“找不到共享库文件”**，这个是什么原因呢？cgo指令中-I、-L不是已经说明了吗？是的，但是上述说明只是指导cgo编译器在编译阶段如何搜索共享库，对程序加载运行阶段并没有任何帮助。如果想让程序在运行阶段正常搜索到共享库，有两个办法：

- 一种是通过修改LD_LIBRARY_PATH，使其包含共享库位置，如`LD_LIBRARY_PATH=. ./main`；
- 一种是通过修改cgo指令，强制包含当前库路径到程序加载时库搜索路径里面，如`# cgo LDFLAGS: -L${SRCDIR} -Wl,rpath=${SRCDIR} -ladd`，编译后直接运行`./main`即可。

在工作过程中有个同学问起这个问题，于是我就琢磨了下这其中的问题，不只是go程序存在类似的问题，其他c、c++程序也是这样的，本质上这是个**linkers and loaders**相关的问题。

参考文献：

1 http://gridengine.eu/index.php/other-stories/232-avoiding-the-ldlibrarypath-with-shared-libs-in-go-cgo-applications-2015-12-21