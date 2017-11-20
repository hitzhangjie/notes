# GNU M4

GNU M4是一个经典的Unix宏处理器实现，与[SVR4](https://kb.iu.edu/d/agjs)兼容但同时又增加了一些扩展（比如可以处理超过9个宏参数）。GNU M4也内置了文件包含、运行shell命令、算术运算等功能。

GNU M4拷贝输入的宏并处理后进一步展开成编译器可处理的宏，宏是M4内置的也可以是用户自定义的，支持任意参数。除了做**宏展开**（macro expansion）之外，还可以执行**文件包含、运行shell命令、算术运算、处理文本、递归……**等操作。M4可以用作一个编译器前端也可以单独作为一个宏处理器。

M4少为人知，用的人可能也不会直接编写M4脚本，大多数人是因为使用了[Autoconf](https://en.wikipedia.org/wiki/Autoconf)而Autoconf又依赖M4所以才安装了M4。但是M4确实是非常强大的，甚至让一些程序员欲罢不能。

关于M4的更多介绍，请看M4手册：[M4 Mannual](https://www.gnu.org/savannah-checkouts/gnu/m4/manual/m4-1.4.18/html_node/index.html)

这里有一篇笔记介绍了M4的工作原理、使用：[Notes on the M4 Macro Language](http://mbreen.com/m4.html)



