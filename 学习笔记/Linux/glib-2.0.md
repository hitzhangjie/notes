开发过程中，难免要用到各种或简单或复杂的数据结构，比如链表（单链表、双链表）、队列（普通队列、双端队列）、栈、哈希表、树（红黑树、AVL树，M树）、动态数组、记录等等，不可能每次开发的时候都自己写一遍，也不太可能拼凑一些网络上收集的、自己编写的代码来用于生产环境，还是需要使用一些经过充分验证的、健壮稳定的工具库来辅助开发过程。

有些编程语言内置了对这些常用数据结构的支持，甚至包括了某些算法支持，C++中的STL、Java中的java.util包都是面向这一难题的。但是c太精炼，标准库里面没有对此予以支持。尽管如此还是有众多的面向c的工具库，比如gnulib、glib。

我们这里只介绍glib，glib从96年开始就已经诞生了，前后20多年时间表明其经得起实践的检验。另外在学习了**《Manage C data using the GLib Collections》**之后，发现glib封装的api表意清楚、使用简单，如果是一个比较熟练的C程序开发人员的话，应该很容易就能上手。

点击阅读教程：[Manage C data using the GLib Collections](https://www.ibm.com/developerworks/linux/tutorials/l-glib/)

- 单链表 GSList
- 双链表 GList
- 哈希表 GHashTable
- 动态数组 GArray
- AVL树 GTree
- 队列 GQueue
- 记录 Relation
- 其他

