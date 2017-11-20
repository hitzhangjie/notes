**1 查看一个包的头文件、库文件搜索路径**

```bash
pkg-config --cflags --libs glib-2.0
```
pkg-config读取/usr/lib64/pkg-config/glib-2.0.pc，并返回该配置文件中指定的头文件、库文件搜索路径。

**2 collection library for c programming**

在开发过程中经常要用到一些常见的数据结构，比如单链表、双链表、集合、哈希表、多阶哈希、avl树、红黑树、队列、栈等等，c++中提供了stl简化了开发工作，java中也有提供java.util包。但是c标准库里面并没有提供类似的工具，但是linux平台经过多年发展也确实积累了很多的可用的库，比如**gnulib**、**glib**等。

这里抽时间学习了一下glib-2.0工具包，其中基本包括了开发中所要用到的常见数据结构。

