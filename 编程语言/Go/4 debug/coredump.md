
go程序crash的时候，没有生成coredump文件？可能设置了`ulimit -c unlimited`，也指定了`kernel.core_pattern`确定core目录没有错误，但是还是没有生成core文件。

如何解决：启动的时候要加个环境变量，core掉的时候会生成core文件：`GOTRACEBACK=crash ./any_go_program`
可以自己`kill -6 $pid`自测一下。

为什么呢？
看来还不完全是操作系统控制的，应该是进程监听操作系统发过来的信号，自己决定如何生成core文件。
可能是这样的，不同语言实现不同，可自己决定写什么信息到core文件，方便语言对应的调试器解析。
