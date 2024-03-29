libmill, 是Martin Sustrik发起的一个面向unix平台下c语言开发的协程库，实现了一种类似goroutine风格的协程，也支持channel，“通过通信共享数据，而非通过共享数据来完成通信”。

觉得挺有意思的，就抽周末时间看了下。大神的代码干净利索，也看到了不少令自己眼前一亮的tricks，举几个例子吧。

**1 通用链表及迭代器实现**

**offsetof**可以计算结构体中的成员的offset，如果我们知道一个struct的类型、其成员名、成员地址，我们就可以计算出struct的地址：
```c
#define mill_cont(ptr, type, member) \
        (ptr ? ((type*) (((char*) ptr) - offsetof(type, member))) : NULL)
```

基于此可以进一步实现一个通用链表，怎么搞呢？

```c
struct list_item {
    struct list_item * next;
};

struct my_struct {
    void * data; 
    struct list_item * iter;
};
```

我们通过list_item来构建链表，并在自定义my_struct中增加一个list_item成员，将其用作迭代器。当我们希望构建一个my_struct类型的链表时实际上构建的是list_item的列表，当我们遍历my_struct类型的链表时遍历的也是list_item构成的链表。加入现在遍历到了链表中的某个list_item item，就可以结合前面提到的mill_cont(&item, struct list_item, iter)来获得包括成员的结构体地址，进而就可以访问结构体中的data了。

其实这里Martin Sustrik的实现方式与Linux下的通用链表相关的宏实现类似，只是使用起来感觉更加自然一些，也更容易被接受。

**2 栈指针调整（分配协程栈）**

栈的分配有两个时机，一个是编译时，一个是运行时。对于编译时可以确定占用空间大小的就在编译时生成对应的汇编指令来分配，如：```sub 0x16, %rsp```；对于运行时才可以确定占用空间大小的就要在运行时分配，如：```int n = srand()%16; int buf[n];```，这个如何分配呢？Linux下有个库函数alloca可以在当前栈帧上继续分配空间，但是呢？它不会检查是否出现越界的行为，注意了，因为内存分配后，栈顶会发生变化，寄存器%rsp会受到影响，也是基于这个side effect，就可以实现让指定的函数go(func)将新分配的内存空间当做自己的栈帧继续运行。这样每个协程都有自己的栈空间，再存储一下协程上下文就可以很方便地实现协程切换。

```c
#define mill_go_(fn) \
    do {\
        void *mill_sp;\
        mill_ctx ctx = mill_getctx_();\
        if(!mill_setjmp_(ctx)) {\
            mill_sp = mill_prologue_(MILL_HERE_);\
            int mill_anchor[mill_unoptimisable1_];\
            mill_unoptimisable2_ = &mill_anchor;\
            char mill_filler[(char*)&mill_anchor - (char*)(mill_sp)];\
            mill_unoptimisable2_ = &mill_filler;\
            fn;\
            mill_epilogue_();\
        }\
    } while(0)
```

**3 其他惊喜**

惊喜的点不在多，一两三个也是令人开心的 ...

理解了这个goroutine风格协程库的实现，但是也更多地看到了好的设计思想，看大神的代码就是有种“听君一席话，胜读十年书”的感觉。

感慨：路漫漫其修远兮，吾将上下而求索！



