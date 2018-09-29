
在工作、学习过程中学习到了一些定位、分析bug的技巧，在这里几种进行一下总结，有些技能真的是不常用就忘了，回家呆了两个月，回到公司后发现很多之前积累起来的知识被“遗忘”了，其实还是没有完全掌握，只能算是“初识”该技能，好几性不如烂笔头，还是要多做总结、多回顾，有问题的时候即便记不起来了也可以快速查询。

# 1 coredump
Linux下进程收到下面这5个常见信号时，会终止进程生成core文件。
- SIGQUIT，quit from keyboard；
- SIGILL，illegal instruction；
- SIGABRT，abort signal from abort(3)；
- SIGFPE，floating point exception；
- SIGSEGV，invalid memory reference；

## 1.1 core文件大小
core文件大小是有限制的，默认都是0，意味着不会生成core文件，可以通过 ```ulimit -c``` 进行查看，也可以通过 ```ulimit -c $size``` 进行修改，但是命令只对当前shell有效，重启一个shell或者重启机器都会恢复为系统默认设置。如果想永久保留此设置可以在 ```/etc/profile``` 或者 ```/etc/bashrc``` 中进行配置。

## 1.2 core文件命名
core文件命名模式是可以指定的，在 ```/etc/sysctl.conf``` 中添加如下配置即可在程序coredump时在当前程序目录生成core文件，```kernel.core_pattern=core-%e(%s).%p.%t```。对这里的配置选项进行简单说明：

- %e，executable filename (withouth path prefix)；
- %s，number of signal causing dump；
- %p，PID of dumped process;
- %t，time of dump，unix timestamp；

其他配置选项可以通过man core进行查询。

core文件名后面的时间戳不好辨认，可以通过命令将其转成可读的、易理解的字符串，```date -d @time```。

## 1.3 分析core文件
假如当前可执行文件名是prog，生成的core文件是core-prog(11).12345.1490000000，那么执行命令 `gdb prog core-prog(11).12345.1490000000`，通过该命令来定位到该进程12345收到信号11 coredump时的内存状态，通过对其调用栈进行分析可以找到进程coredump的原因，这里的kernel.core_pattern中的信号选项%s其实也是很重要的，通过进程收到的信号大体可以猜到接收该信号的原因，便于辅助定位问题，例如信号11表示SIGSEGV，其往往是因为内存访问非法所致，这个时候就可以重点分析内存是否存在越界等。

另外为了方便分析coredump，这里的prog可执行程序在构建时最好加入调试符号，编译程序时为gcc指定选项**gcc -g**。一般gdb prog $core-file分析时最后会打印出程序发生coredump时的堆栈信息便于分析。

# 1.4 as with go

go程序crash的时候，没有生成coredump文件？可能设置了`ulimit -c unlimited`，也指定了`kernel.core_pattern`确定core目录没有错误，但是还是没有生成core文件。

启动的时候要加个环境变量，core掉的时候会生成core文件：`GOTRACEBACK=crash ./any_go_program`
可以自己`kill -6 $pid`自测一下。

这个选项可能`GOTRACEBACK != crash`的时候可能屏蔽了SIGSEGV等等其他可能触发操作系统生成core文件的信号。
