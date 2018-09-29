
go程序crash的时候，没有生成coredump文件？可能设置了`ulimit -c unlimited`，也指定了`kernel.core_pattern`确定core目录没有错误，但是还是没有生成core文件。

启动的时候要加个环境变量，core掉的时候会生成core文件：`GOTRACEBACK=crash ./any_go_program`
可以自己`kill -6 $pid`自测一下。

这个选项可能`GOTRACEBACK != crash`的时候可能屏蔽了SIGSEGV等等其他可能触发操作系统生成core文件的信号。
