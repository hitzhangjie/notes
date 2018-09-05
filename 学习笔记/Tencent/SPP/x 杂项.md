spp ctrl
===

CServerBase应该是spp框架中最最基础的服务器类，其他的spp proxy、spp worker、spp ctrl都是基于CServerBase构建起来的。

如果不安装cscope的话，vim会直接跳转过去；如果希望提供一个候选然后选择跳转的话，安装cscope就可以了！

spp服务器类型，unknown、proxy、work、ctrl。

malloc是在堆内存中申请内存，alloca是在调用者的栈内存中申请内存，当栈帧被销毁时，alloca申请的内存也就自动被销毁了。

flock用于对打开的文件申请一个建议锁，其实就是文件锁了！这里的锁是建议性锁，需要读写这个文件的程序共同遵守访问约定；强制性锁需要文件系统的支持！

RLIMIT_NOFILE，允许进程打开的最大文件描述符编号+1！意味着进程只可以使用 [0,RLIMIT_NOFILE) 这个范围内的文件描述符。

struct rlimit中的rlim_t rlim_cur指定了软限制，rlim_max指定了硬限制！软限制的话可以设置其值为[0,rlim_max]。

daemon(nochdir, noclose)可以将当前进程直接转为daemon进程运行！其工作原理跟我们自己两次创建daemon放弃控制中断的方式应该是类似的吧！
- nochdir, 如果为0则切换进程工作目录到根目录，否则不变；
- noclose，如果为0将进程的输入、输出、错误重定向到/dev/null，否则不变；


int fileno(FILE *stream)用于获取文件的文件描述符。
int flock(int fd, int operation)可以用于对某一个文件的fd进行添加建议锁（共享锁、排他性锁），也可以删除锁。
close_on_exec: 执行execve族函数时关闭标记了这个位的文件描述符！

spp proxy
===



