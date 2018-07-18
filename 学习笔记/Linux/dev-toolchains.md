# 1 开发基础

## 1.0 构建工具

### 1.0.1 GNU M4

GNU M4是一个经典的Unix宏处理器实现，与[SVR4](https://kb.iu.edu/d/agjs)兼容但同时又增加了一些扩展（比如可以处理超过9个宏参数）。GNU M4也内置了文件包含、运行shell命令、算术运算等功能。

GNU M4拷贝输入的宏并处理后进一步展开成编译器可处理的宏，宏是M4内置的也可以是用户自定义的，支持任意参数。除了做**宏展开**（macro expansion）之外，还可以执行**文件包含、运行shell命令、算术运算、处理文本、递归……**等操作。M4可以用作一个编译器前端也可以单独作为一个宏处理器。

M4少为人知，用的人可能也不会直接编写M4脚本，大多数人是因为使用了[Autoconf](https://en.wikipedia.org/wiki/Autoconf)而Autoconf又依赖M4所以才安装了M4。但是M4确实是非常强大的，甚至让一些程序员欲罢不能。

关于M4的更多介绍，请看M4手册：[M4 Mannual](https://www.gnu.org/savannah-checkouts/gnu/m4/manual/m4-1.4.18/html_node/index.html)

这里有一篇笔记介绍了M4的工作原理、使用：[Notes on the M4 Macro Language](http://mbreen.com/m4.html)


## 1.1 常用的软件开发包

在列举常用的软件开发包之前，需先描述下如何高效地设置软件包头文件、库文件的搜索路径。

### 1.1.1 如何配置头文件、库文件搜索路径

使用第三方软件包开发时常需要设置头文件、库文件的搜索路径，如何确定软件包对应的文件路径呢？pkg-config可以简化这一设置工作，如获取glib-2.0的头文件、库文件搜索路径执行如下命令即可：```pkg-config --cflags --libs glib-2.0```。

pkg-config是如何得知软件包的头文件、库文件搜索路径的呢？每个软件包在安装的时候就已经包含了这一信息，这些信息保存在 **/usr/lib64/pkg-config/${pkg}.pc** 描述文件中，pkg-config只是读取该文件中的描述项而已。

以glib-2.0这一面向linux c程序开发的集合框架开发包为例：

```
pkg-config --cflags --libs glib-.20

-I/usr/local/Cellar/glib/2.54.2/include/glib-2.0 
-I/usr/local/Cellar/glib/2.54.2/lib/glib-2.0/include 
-I/usr/local/opt/gettext/include 
-I/usr/local/Cellar/pcre/8.41/include 
-L/usr/local/Cellar/glib/2.54.2/lib 
-L/usr/local/opt/gettext/lib 
-lglib-2.0 
-lintl 
-Wl,-framework 
-Wl,CoreFoundation
```

其中不仅包括了glib-2.0自身的头文件、库文件搜索路径，还包括了某些依赖的头文件、库文件搜索路径，可见pkg-config确实能简化头文件、库文件搜索路径的设置工作，开发人员应该充分利用起此工具。

### 1.1.2 适用于linux c程序开发的开发包

#### 1.1.2.1 集合框架类

在开发过程中经常要用到一些常见的数据结构，比如单链表、双链表、集合、哈希表、多阶哈希、avl树、红黑树、队列、栈等等，C++中提供了STL（标准模板库）简化了开发工作，Java中提供了对应的集合框架JUC包。但是C标准库里面并没有类似工具……Linux平台经过多年发展积累了一些面向C语言的集合框架，比如**gnulib**、**glib**等。

我们这里只介绍glib，glib从96年开始就已经诞生了，前后20多年时间表明其经得起实践的检验。glib封装的api表意清楚、使用简单，如果是一个比较熟练的C程序开发人员的话，应该很容易就能上手。

这里抽时间学习了一下glib-2.0工具包，其提供了如下常用的数据结构：

- 单链表 GSList
- 双链表 GList
- 哈希表 GHashTable
- 动态数组 GArray
- AVL树 GTree
- 队列 GQueue
- 记录 Relation
- 其他

有关glib-2.0的教程可以参考：[Manage C data using the GLib collections](https://www.ibm.com/developerworks/linux/tutorials/l-glib/)


