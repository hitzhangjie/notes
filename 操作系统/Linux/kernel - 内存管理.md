# 1 内存管理

在编写程序时常常涉及到动态内存分配相关的内容，这个时候我们会通过c malloc/free来动态申请、释放内存。**然而对于内存分配、释放而言，却不仅仅只有动态内存分配、释放的时候才会触发，函数栈帧的创建和销毁、页面的换入和换出、mmap、unmap等也会涉及到内存的分配、释放动作**。这些内存分配动作，底层都依赖操作系统来为进程分配页帧使用或者回收页帧。

大家常见的c malloc/free，除了操作系统内存管理，它还牵扯到**内存分配器（Memory Allocator）**的问题，为了避免频繁进入系统内核，内存分配器通常会申请一块内存自己管理应用程序内存分配，c free之后的内存也并不会立即归还给操作系统，而是留给后续c malloc使用，只有当heapsize超过了指定的阈值之后才会将空闲内存归还给操作系统。

要理清C在Linux下的内存分配细节，就至少需要从两个方面入手：

- 操作系统如何管理内存？
- C库中内存分配器如何管理内存?

# 2 Linux内存管理

参考《Linux内核架构》补充Linux内存管理相关的细节。

# 3 libc内存分配器

参考下面几个视频以及更多libc内容完善内存分配器相关细节：

- [Memory Allocation, Video 1: Introduction](https://youtu.be/RSuZhdwvNmA?list=PL0oekSefhQVJdk0hSRu6sZ2teWM740NtL)
- [Memory Allocation, Video 2: Examples](https://youtu.be/PY1PgGktEOw?list=PL0oekSefhQVJdk0hSRu6sZ2teWM740NtL)
- [Memory Allocation, Video 3: Implementation](https://youtu.be/74s0m4YoHgM?list=PL0oekSefhQVJdk0hSRu6sZ2teWM740NtL)
- [Memory Allocation, Video 4: Explicit free list](https://youtu.be/rhLk2lf6QXA?list=PL0oekSefhQVJdk0hSRu6sZ2teWM740NtL)

上面讲述的是内存分配器的通用实现方法，具体libc中是如何实现的，需要结合相应的源码来进一步确定。

libc中内存是怎么进行申请的？

- 当申请内存尺寸>=512字节时，使用“best-fit”分配器；
- 当申请内存尺寸<=64字节时，使用“caching”分配器；
- 当申请内存尺寸介于64和512之间时，使用“大、小内存申请”的组合来达到更好的效率；
- 当申请内存尺寸>=128KB时，依赖于系统的内存映射mmap机制，如果系统支持的话。

