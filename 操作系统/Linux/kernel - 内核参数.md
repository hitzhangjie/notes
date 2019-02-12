# 1 tcpip内核参数

所有的TCP/IP调优参数都位于/proc/sys/net/目录，下面是最重要、常用的tcp/ip调优参数：

| 内核参数                              | 参数用途                                                     |
| ------------------------------------- | ------------------------------------------------------------ |
| /proc/sys/net/core/rmem_max           | 最大的TCP数据接收缓冲                                        |
| /proc/sys/net/core/wmem_max           | 最大的TCP数据发送缓冲                                        |
| /proc/sys/net/ipv4/tcp_timestamps     | 时间戳(请参考RFC 1323)在TCP包头增加12个字节                  |
| /proc/sys/net/ipv4/tcp_sack           | 选择应答                                                     |
| /proc/sys/net/ipv4/tcp_window_scaling | 支持更大的tcp滑动窗口，<br/>如果tcp窗口最大超过64KB，必须设置该参数值为1 |
| rmem_default                          | 默认的接收窗口大小                                           |
| rmem_max                              | 接收窗口的最大大小                                           |
| wmem_default                          | 默认的发送窗口大小                                           |
| wmem_max                              | 发送窗口的最大大小                                           |

# 2 System内核参数

| 内核参数                                          | 参数用途                                                     | defv         |
| ------------------------------------------------- | ------------------------------------------------------------ | ------------ |
| /proc/sys/fs/super-max                            | 该文件指定超级块处理程序的最大数目。<br>mount的任何文件系统需要使用超级块，<br>所以如果挂装了大量文件系统，则可能会用尽超级块处理程序。 | 256          |
| /proc/sys/fs/super-nr                             | 该文件显示当前已分配超级块的数目。<br>该文件是只读的，仅用于显示信息。 |              |
| /proc/sys/kernel <br>/proc/sys/kernel/acct        | 该文件有三个可配置值，根据包含日志的文件系统上可用空间的数量（以百分比表示），这些值控制何时开始进行进程记帐： <br>- 如果可用空间低于这个百分比值，停止进程记帐；<br>- 如果可用空间高于这个百分比值，开始进程记帐；<br>- 检查上面两个值的频率（以秒为单位）；<br>通过空格分隔开的一串数字来设置该选项的值。 | 2 4 30       |
| /proc/sys/kernel/ctrl-alt-del                     | 控制系统在接收到 ctrl+alt+delete 按键组合时如何反应。<br>值为0，表示捕获ctrl+alt+delete，平滑关闭系统，类似shutdown命令；<br>值为1，表示不捕获ctrl+alt+delete，非平滑关闭，类似于关电源。 | 0            |
| /proc/sys/kernel/domainname                       | 配置网络域名。<br>它没有缺省值，也许已经设置了域名，也许没有设置。 |              |
| /proc/sys/kernel/hostname                         | 配置网络主机名。<br>它没有缺省值，也许已经设置了主机名，也许没有设置。 |              |
| /proc/ss/kernel/msgmax                            | 该文件指定了从一个进程发送到另一个进程的消息的最大长度。<br>进程间的消息传递是在内核的内存中进行，不会交换到磁盘上，所以如果增加该值，则将增加操作系统所使用的内存数量。 | 8192         |
| /proc/sys/kernel/msgmnb                           | 该文件指定在一个消息队列中最大的字节数。                     | 16384        |
| /proc/sys/kernel/msgmni                           | 该文件指定消息队列标识的最大数目。                           | 16           |
| /proc/sys/kernel/panic                            | 该文件表示如果发生“内核严重错误（kernel panic）”，则内核在重新引导之前等待的时间（以秒为单位）。<br>0表示，在发生内核严重错误时将禁止重新引导。 | 0            |
| /proc/sys/kernel/printk                           | 根据日志记录消息的重要性，定义将其发送到何处。<br>关于不同日志级别的更多信息，请阅读 syslog(2) 联机帮助页。<br>该文件有四个数字值，该文件的四个值为： <br>控制台日志级别：优先级高于该值的消息将被打印至控制台；
缺省消息日志级别：将用该优先级来打印没有优先级的消息；
最低控制台日志级别：控制台日志级别可被设置的最小值（最高优先级）； 
缺省控制台日志级别：控制台日志级别的缺省值； | 6 4 1 7      |
| /proc/sys/kernel/shmall                           | 任何给定时刻系统上可以使用的共享内存的总量（以字节为单位）。 | 2097152      |
| /proc/sys/kernel/shmax                            | 内核所允许的最大共享内存段的大小（以字节为单位）。           | 33554432     |
| /proc/sys/kernel/shmmni                           | 整个系统共享内存段的最大数目。                               | 4096         |
| /proc/sys/kernel/sysrq                            | 值为非零，则激活 System Request Key。                        | 0            |
| /proc/sys/kernel/threads-max                      | 内核所能使用的线程的最大数目。                               | 2048         |
| /proc/sys/net<br>/proc/sys/net/core/message_burst | 写新的警告消息所需的时间（以 1/10 秒为单位）；<br>在这个时间内所接收到的其它警告消息会被丢弃。<br>这用于防止某些企图用消息“淹没”您系统的人发起的拒绝服务（Denial of Service）攻击。 | 50 (5s)      |
| /proc/sys/net/core/message_cost                   | 与每个警告消息相关的成本值。<br>该值越大，越有可能忽略警告消息。 | 5            |
| /proc/sys/net/core/netdev_max_backlog             | 在接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目。 | 300          |
| /proc/sys/net/core/optmem_max                     | 每个套接字所允许的最大缓冲区的大小。                         |              |
| /proc/sys/net/core/rmem_default                   | 接收套接字缓冲区大小的缺省值（以字节为单位）。               |              |
| /proc/sys/net/core/rmem_max                       | 接收套接字缓冲区大小的最大值（以字节为单位）。               |              |
| /proc/sys/net/core/wmem_default                   | 发送套接字缓冲区大小的缺省值（以字节为单位）。               |              |
| /proc/sys/net/core/wmem_max                       | 发送套接字缓冲区大小的最大值（以字节为单位）。               |              |
| /proc/sys/net/ipv4<br>/proc/sys/net/ipv6          | 所有 IPv4/v6 的参数都被记录在内核源代码文档中。<br>请参阅文件 /usr/src/linux/Documentation/networking/ip-sysctl.txt。 |              |
| /proc/sys/vm<br>/proc/sys/vm/buffermem            | 缓冲区内存占整个系统内存的数量（以百分比表示）。<br>它有三个值，通过空格相隔的一串数字来设置：<br>- 用于缓冲区的内存的最低百分比；
- 如果系统内存所剩不多，且系统内存正在不断减少，系统将试图维护缓冲区内存的数量；
- 用于缓冲区的内存的最高百分比； | 2 10 60      |
| /proc/sys/vm/freepages                            | 系统如何应对各种级别的可用内存。<br>它有三个值，通过空格相隔的一串数字来设置：<br>- 如果系统中可用页面的数目大于最低限制，则允许内核分配一些内存；<br>- 如果系统中可用页面的数目小于这一限制，则内核将以较积极的方式启动交换，以释放内存，从而维持系统性能。 <br>- 内核将试图保持这个数量的系统内存可用，低于这个值将启动内核交换。 | 512 768 1024 |
| /proc/sys/vm/kswapd                               | 控制内核如何进行内存交换。<br>它有三个值，通过空格相隔的一串数字来设置：<br>- 内核试图一次释放的最大页面数目。如果想增加内存交换过程中的带宽，则需要增加该值。 <br>- 内核在每次交换中试图释放页面的最少次数。 
- 内核在一次交换中所写页面的数目。这对系统性能影响最大。这个值越大，交换的数据越多，花在磁盘寻道上的时间越少。然而，这个值太大会因“淹没”请求队列而反过来影响系统性能。 | 512 32 8     |
| /proc/sys/vm/pagecache                            | 该文件与 /proc/sys/vm/buffermem 的工作内容一样，但它是针对文件的内存映射和一般高速缓存。 |              |

# 3 临时修改配置

/proc是虚拟文件系统，它是操作系统对上层暴露的与内核通信的一个接口，该目录下的所有内容都是临时性的，重新启动系统后任何修改都会丢失。因此如果是想临时性的调整内核参数，可以直接通过命令`echo`来修改/proc下的对应项目内容。

为了避免系统重启后参数修改失效，也可以借助/etc/rc.local在系统重启后自动设置内核参数。系统启动到指定运行级之后会执行/etc/rc.local中的命令，把下面代码增加到/etc/rc.local。

下面是常见内核参数调优示例。

```bash
#filename: /etc/rc.local

echo 256960 > /proc/sys/net/core/rmem_default 
echo 256960 > /proc/sys/net/core/rmem_max 
echo 256960 > /proc/sys/net/core/wmem_default 
echo 256960 > /proc/sys/net/core/wmem_max 
echo 0 > /proc/sys/net/ipv4/tcp_timestamps 
echo 1 > /proc/sys/net/ipv4/tcp_sack 
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling 
TCP/IP参数都是自解释的, TCP窗口大小设置为256960, 禁止TCP的时间戳(取消在每个数据包的头中增加12字节), 支持更大的TCP窗口和TCP有选择的应答。 
上面数值的设定是根据互连网连接和最大带宽/延迟率来决定. 
注: 上面实例中的数值可以实际应用, 但它只包含了一部分参数. 
另外一个方法: 使用 /etc/sysctl.conf 在系统启动时将参数配置成您所设置的值: 
net.core.rmem_default = 256960 
net.core.rmem_max = 256960 
net.core.wmem_default = 256960 
net.core.wmem_max = 256960 
net.ipv4.tcp_timestamps = 0 
net.ipv4.tcp_sack =1 
net.ipv4.tcp_window_scaling = 1 
```

# 4 永久修改配置

如果是想永久的修改内核参数，需要修改**/etc/sysctl.conf**，然后重启系统，或者不重启系统直接通过sysctl命令重新加载配置。当然了，sysctl命令也可以临时性调整内核参数，类似于echo重定向那样临时性修改下参数。

# 5 sysctl使用工具

在 sysctl(8) 的联机帮助页中，对这个程序进行了完整的文档说明，sysctl 的配置文件是 /etc/sysctl.conf，可以编辑该文件，然后sysctl来重新加载该配置。

sysctl 将 /proc/sys 下的文件视为可以更改的单个变量。所以，以 /proc/sys 下的文件 /proc/sys/fs/file-max 为例，它表示系统中所允许的文件句柄的最大数目，这个文件被表示成 fs.file-max。 这个示例揭示了 sysctl表示法中的一些区别：

- 由于 sysctl 只能更改 /proc/sys 目录下的变量，并且人们始终认为变量是在这个目录下，因此省略了变量名的那一部分（/proc/sys）；
- 另一个要说明的更改是，将目录分隔符（正斜杠 /）换成了英文中的句号（点 .）； 

将 /proc/sys 中的文件转换成 sysctl 中的变量有两个简单的规则： 

- 去掉前面部分 /proc/sys；
- 将文件名中的正斜杠变为点；

这两条规则使您能将 /proc/sys 中的任一文件名转换成 sysctl 中的任一变量名。一般文件到变量的转换为： 

```bash
/proc/sys/dir/file --> dir.file 
dir1.dir2.file --> /proc/sys/dir1/dir2/file 
```
下面介绍下常用的sysctl操作方式：

- 可以使用命令 `sysctl -a` 查看所有可以更改的变量和其当前设置；
- 用 sysctl 临时性更改变量，类似于echo重定向方式，`sysctl -w kernel.hostname="kn"`；
- 用sysctl 永久性更改变量，先下/etc/sysctl.conf中添加配置行，kernel.hostname=“kn"，然后`sysctl -p /etc/sysctl.conf`重新加载配置文件;