---
layout: post
title: Unix环境高级编程
description: ""
date: 2014-06-11 08:00:00 +0800
categories: ["过去的学习笔记"]
tags: ["unix","linux","programming","c"]
toc: true
reward: true
---

迁移自 hitzhangjie/Study 项目下的内容，本文主要总结的是Unix环境高级编程里的一些知识要点。

```
# Advanced Programming in Unix Environment

############################################################################
Mon Jun  9 09:22:41 CST 2014
############################################################################

M1 Unix基础知识

1. man man
1)user commands
2)system calls
3)c library functions
4)devices and special files
5)file formats and conventions
6)games
7)miscellanea
8)system admistration tools and daemons

2. c return values
1)return 0, 正常结束
2)return 1-255，表示错误代码

3. 工作目录
char *getcwd(char *buf, size_t size);
int chdir(char *path);

4. libc与glibc的关系
libc是泛指c库，glibc是gnu组织对libc的一种实现，是unix、linux的根基，微软也有自
己对libc的实现，叫msvcrt。

5. read system call
return 0, 表示到达了文件的结尾。

6. Ctrl+D，默认的文件结束字符
ctrl+c，中断键
ctrl+\，退出键

7. fork，执行一次，返回两次，对父进程返回子进程的进程id，对子进程返回0

8. 出错处理和出错恢复
errno
当unix函数出错时，常常返回一个负值，同时将整形变量errno设置为含有附加信息的一
个值，例如open调用失败返回-1，对应的有大约15中不同的errno值。
errno.h中定义了errno以及可以赋予它的各种常量，这些常量都以字母E开头。
举个例子：
E2BIG：参数列表太长
EAGAIN：资源临时不可获取
EACCESS：权限不够，访问被拒绝
EBADF：无效文件描述符
EBUSY：设备忙或资源忙
ECANCELED：操作被取消
ECHILD：没有子进程
EEXIST：文件已经存在
EFAULT：无效地址
EFBIG：文件尺寸过大
EINTR：中断函数调用
EIO：IO错误
...

char *strerror(int errno);
void perror(char *msg);

对于资源相关的非致命性错误，一般恢复动作是延迟一些时间，然后再试

9. 支持线程的环境中，需要使用局部errno，避免线程间的相互干扰

10. 为什么要将用户名、组名映射为id呢？
1）如果使用全场ascii登录名和组名，则需要更多的磁盘空间进行存储；
2）在查验权限期间，比较字符串较之比较整形更消耗时间

11. 度量一个进程的执行时间：
时钟时间、用户cpu时间、系统cpu时间，time命令

12. 系统调用和库函数
1)从实现者的角度来看，两者的实现有着重大的不同，通常库函数是在系统调用之上建立起
来的；
2)从用户的角度来看，两者并没有明显的区别；
通常，我们可以替换库函数，但是不能或者很难替换系统调用；

############################################################################

M2 Unix标准化

1. 
1)ISO C, (ANSI在ISO中代表美国的利益），按照改标准定义的头文件，将iso c库分成24
个区
2)IEEE POSIX，添加来pthreads（POSIX线程）、更多的实时接口、事件跟踪方面的扩展
3)Single Unix Specification(SUS)，是POSIX的超集，在POSIX基础上，定义来一些附加
的接口，相应的系统接口全集被称为X/Open系统接口(X/Open System Interface, XSI)

ISO->POSIX->XSI

只有遵循XSI的实现，才能称为是Unix系统

2. 限制
Unix定义了很多幻数和常量，不同的实现定义的值可能不一样，为了增加可移植性，需要
解决这些问题，为此提供了如下三种限制：
1)编译时限制（头文件）
编译时需要确定的幻数和常量的值，可以在头文件中定义；
2)不与文件或目录相关联的运行时限制，可以通过sysconf函数获取；
3)与文件或目录相关链的运行时限制，可以通过pathconf或者fpathconf函数获取；

1）iso c定义的限制都是编译时限制，例如头文件limits.h中定义的常量；
2）posix和xsi定义的限制既有编译时限制，也有运行时限制；

############################################################################

M3 文件I/O

1. 不带缓冲的IO，指的是每个read、write操作都对应内核中的一次系统调用

2.将标准输入、输出、错误输出分别用文件描述符1、2、3来引用，是shell的惯例，与内
核没有关系。
一个进程可以打开的文件描述符的范围是0～OPEN_MAX。

3. lseek，返回文件当前的偏移量，可以是负值，所以再测试lseek是否失败的时候，不
能判断是否小于0，而应判断是否等于-1；lseek定位时指定的偏移量可以大于文件长度，
这时会在文件中产生空洞;
产生的空洞读为\0，可以在程序中进行处理，将\0去掉，即将空洞从文件中删除。

4. IO效率，建议缓冲区长度采用4096字节，此时消耗的系统cpu时间最小，用户cpu时间
、时钟时间也比较小4.

5. 内核用于所有IO的数据结构
1)进程表项中存储着打开的文件描述符列表，每个文件描述符表项包含文件描述符以及指
向文件表项的指针；
2)文件表，在文件表中，内核为所有打开的文件增加一个表项。其实进程每调用一次open
，就会在文件表中增加一个文件表项；dup、dup2只是复制文件描述符，内核不会创建新
的文件表项；
每个文件表项，包含文件状态标志、当前文件的偏移量以及指向v节点表项的v节点指针
3)v节点表，每个打开的文件，内核都在v节点表中创建一个v节点表项，v节点表项包含了
i节点信息（索引节点信息）以及当前文件长度；
每个打开的磁盘上的文件，只对应一个v节点表项

6. 因为对文件的io操作，通常是采用的建议性锁机制，多个进程读写同一个文件时，可
能在读写时产生冲突， pread、pwrite可以将定位和读写封装为一个原子性操作，可以解
决这个问题；当然如果对文件操作施加强制性锁，不用pread、pwrite也是可以的

7. sync，fsync，fdatasync
平时我们说的不带缓冲的io，指的是每次read、write都是一个系统调用，然后进入内核
进行操作。这里需要注意的是，并不是说内核在处理io相关的操作的时候，就没有缓冲。
为了减少磁盘读写次数，内核总是使用了缓冲机制的，只不过用户通过不带缓冲的io进行
访问时，会进入内核进行操作而已。
例如通过write写一个文件，写入的数据内核不会立即将其更新到磁盘上，而是将其放入
一个缓冲区中，等待缓冲区满时，在将其排入输出队列更新到磁盘上，这样做的优点是减
少了写磁盘的次数，提高了效率；这样做的缺点是，延长了磁盘文件的更新时间，如果发
生某种意外，可能会造成更新数据的丢失；

为了使得内核缓冲区中的数据与磁盘上的数据保持一致，提供了三个函数
sync,fsync,fdatasync，对于普通用户来讲，fsync应该是用的比较多的吧。

8. fcntl函数，可以更改已打开文件的性质。

9. 打开文件描述符/dev/fd/N等效于复制文件描述符N

ps: In linux, everything is a file.
- for ordinary files, use buffered i/o function to accelerate access.
- for device files, use unbuffered i/o function to avoid device waiting.

############################################################################

M4 文件和目录

1. stat结构体中的st_mode成员，对其进行测试，判断文件类型，判断的时候使用如下宏：
S_ISREG(st_mode)：普通文件
S_ISDIR(st_mode)：目录文件
S_ISCHR(st_mode)：字符设备文件
S_ISBLK(st_mode)：块设备文件
S_ISFIFO(st_mode)：fifo，用于进程间通信，有时也称其为有名管道（mkfifo创建有名
					管道，pipe创建无名管道）
S_ISLNK(st_mode)：符号链接文件（非符号链接文件的硬链接数至少为1）
S_ISSOCK(st_mode)：socket文件，用于网络间的进程间通信

2. shell命令过长，通过符号“\”来段行

3. stat,fstat,lstat
stat函数不会观察到符号链接，观察符号链接，应该使用lstat函数

4. 与一个进程相关联的ID有6个或者更多
1)实际用户ID/实际组ID：（标识进程实际上是谁创建的）
2)有效用户ID/有效组ID/附加组ID：（用于进程的文件访问权限检查）
3)保存的设置用户ID/保存的设置组ID：（exec从有效用户ID复制得到的）

使用宏S_ISUID和S_ISGID对st_mode进行测试，判断有没有对设置用户ID位/设置组ID位进
行设置, 例如S_ISUID & st.st_mode。

```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	printf("euid is: %d\n", (int)geteuid());
	printf("uid is: %d\n", (int)getuid());

	return 0;
}
```

测试uid，euid

kn创建sid程序，以kn执行：euid:500,uid:500
加sudo执行：euid:0,uid:0
sudo chown root:root sid
kn执行sid：euid:0,uid:0
sudo chmod u+s sid
kn执行sid：euid:0,uid:500



最后一次kn执行sid，shell执行过程：
shell接收到./sid命令；
shell fork创建子shell进程；
子shell进程检测sid的文件访问权限，通过测试宏S_ISUID，发现文件sid设置了设置用户
ID位，该文件的属主为root，exec函数将设置进程的有效用户ID为0，并复制有效用户ID
到保存的设置用户ID，然后执行sid程序，这样sid执行时输出的有效用户ID为0，实际用
户 ID为500。

保存的设置用户ID用于在exec执行结束之后恢复原来的有效用户ID。

对，就这么理解！！！！
passwd的权限就是rwsr-xr-x，也是通过设置用户ID来让普通用户完成对/etc/passwd和
/etc/shadow访问的

getuid,geteuid只能获取当前实际用户ID和有效用户ID，不能获取保存的设置用户ID。

其实这些ID里面最重要的就是：实际用户id（getuid）和有效用户id（geteuid）。当程
序文件本身通过chmod被设置了设置用户ID位的时候，在通过shell执行的时候， shell
fork后通过exec执行该程序，exec不会创建新的进程，只是将程序的代码、栈、堆等替换
当前进程的内容，在执行前，也将当前进程的有效用户ID设置为程序文件属主的ID ，并
将旧的有效用户ID复制到保存的设置用户ID。

5. umask
创建文件模式屏蔽子
mode & ~mask，为创建文件的实际模式

6. 文件系统
1)一个磁盘可以划分为多个分区
2)每个分区可以单独设置文件文件系统类型
3)文件系统一般包括：自举块、超级块、很多柱面组（柱面组0，柱面组1, ...，柱面组n）
4)每一个柱面组包括：超级块副本、配置信息、i节点图、块位图、很多i节点、很多数据块
5)i节点和数据块是非常重要的，数据块根据存储内容的不同，可以细分为数据块和目录
块，其中数据块中存放的是文件的内容，目录块中存放的是目录下面文件的名字以及该文
件对应的i节点编号；
目录块中，每个文件占有一个目录项，通过目录项中的i节点编号，就可以访问对应的i节
点，从i节点中就可以读取文件系统中指向存放文件内容的数据块的指针的值，通过这些
指向数据块的指针的值，就可以访问文件系统上的数据块，读取文件的内容。

1)当创建一个硬链接文件时，只是在所处的目录下面创建一个目录项，目录项中存储的只是
硬链接文件的名称以及i节点编号。由于每个文件系统对文件系统内的i节点单独进行编号
，所以硬链接不能够跨越文件系统创建。
2)i节点中都存储着文件的硬链接计数信息，当硬链接计数减为0时，文件才可以被删除，这
就是为什么删除文件的函数是unlink而不是delete的原因。
3)当在同一个文件系统下面进行mv操作时，文件对应的数据块并没有做任何改变，文件对应
的i节点也没有任何改变，系统所做的工作，只是在目标目录所对应的目录块下面创建一
个新的目录项，将目录项中的i节点编号设置为源文件所对应的i节点的编号。

7. 符号链接、硬链接都可能造成循环，例如在一个目录a下面创建一个指向a的链接b，当
我们递归便利目录a的时候，就永远无法结束，因为会发生这样的过程a->b->a，造成循环
，递归永远结束。
1)假如b是一个符号链接，这中循环容易消除，因为unlink不跟随符号链接，所以很容易把b给删除；
2)假如b是一个硬链接，那么就不容易删除，因为b指向一个目录，由于硬链接的实现方面
的原因，b的链接计数>1，无法删除，无法消除循环，所以不允许创建指向目录的硬链接
，即便是root用户也不行。

8. symlin函数创建符号链接，由于open函数跟随符号链接，所以想要打开符号链接本身
的话，就不能使用open函数，可以使用readlink函数来实现。

9. 文件的时间
stat结构体中：
1)st_atime：文件数据的最后访问时间（访问数据块）
2)st_mtime：文件数据的最后修改时间（修改数据块）
3)st_ctime：i节点状态的最后更改时间（修改i节点）

utime函数可以对1）2）进行修改，不能修改3）的内容，3）的值由内核负责更新。

10. mkdir, rmdir

11. read dir
DIR *opendir(const char *pathname);
struct dirent *readdir(DIR *dp);

struct dirent {
	ino_t d_ino;	// i-node number
	char d_name[NAME_MAX+1];	// null-terminated string, dir entry name
};

11. 主设备号标识设备驱动程序；次设备号标识特定的子设备。 stat结构体中的st_dev
和st_rdev两个值表示设备号相关的信息，通过宏 major(st.st_dev)、minor(st.st_dev)
来获取设备的主次设备号； st_rdev只有字符特殊设备或者块特殊设备才有，也是通过
major和minor宏来获取其主次设备号。

##############################################################################
M5 标准IO

1. 请勿将标准IO流的概念与System V的STREAMS IO系统相混淆。

2. 标准IO流可以处理单字节、多字节字符集，但是要设置正确的“流的定向”，因为流的
定向决定了所读、写的字符是单字节的还是多字节的。

如果打开文件、创建流后，没有设置流定向：
调用了多字节的函数，则流被定向成多字节的；
调用来单子节的函数，则流被定向成单字节的；

获取、设置流定向：
fwide函数
清除流的定向：
freopen

3. STDIN_FILENO\STDOUT_FILENO\STDERR_FILENO，这是文件的描述符(int)；
stdin\stdout\stderr是文件指针(FILE *);

4. 标准IO流提供的缓冲方式：全缓冲、行缓冲、不带缓冲，很多系统默认采用下列类型
的缓冲：
1)标准出错是不带缓冲的，这样就可以使得错误信息尽快输出
2)如果涉及终端设备的其他流，则是行缓冲的；其他的，为全缓冲的

setbuf，setvbuf：
通过上述两个函数可以指定标准IO缓冲的类型。

5. 格式化输入的时候，scanf("%*d",&num);希望读一个int数赋值给num，这个时候*号会
匹配int数前面的字符，但是不会将其存入num变量中。

############################################################################

M6 系统数据文件和信息

1)口令文件/etc/passwd
2)影子文件/etc/shadow，其中用户的登录密码是单向加密的，不能够从/etc/shadow中猜
解出用户的密码;
3)组文件
4)附加组ID
5)登录账户记录，utmp文件记录当前登录进系统的用户；wtmp文件跟踪各个登录和注销事
件。
6)系统标识

##########################################################################

M7 进程环境

1)c程序启动、退出示意图，P180
内核执行c程序前，首先执行一个特殊的启动例程，，该启动例程可以获取环境表等信息
，然后启动例程调用exec，执行c程序，这是内核执行c程序的唯一方法。c程序执行过程
中，c程序终止的方法有这么几种：
正常终止的情况：
a.从main返回（执行结束），返回到启动例程后，启动例程立即调用exit方
法，例如exit(main); 
b.从main中调用其他exit、_exit、_Exit退出（调用return等效于调用exit）
c.从main中调用其他函数，其他函数中调用exit、_exit、_Exit退出
d.c程序最后一个线程从其启动例程返回
e.c程序最后一个线程调用pthread_exit
异常终止的情况：
a.调用abort
b.接收到一个信号并终止
c.最后一个线程对取消请求作出响应（pthread_cancel)

调用exit会先调用atexit注册的函数（执行退出处理程序的顺序与注册的顺序相反，因为
这些函数指针是存放在栈中的），然后关闭所有打开的流，然后进入内核；
调用_exit或_Exit直接进入内核；

2)echo $?打印上一条命令的返回状态

3)jmp_buf类型、setjmp、longjmp实现非局部goto，goto只能够实现函数内跳转，而非局
部goto可以在函数之间进行跳转，跳转时越过的函数栈帧将直接被丢弃。

关于跳转之后的变量的值是否回滚，针对总结如下：
a.全局变量、静态变量在longjmp的时候值保持不变，即不会回滚；不受编译优化的影响；
b.自动变量、寄存器变量、易失(volatile)变量，如果未进行编译器的优化，则其值不回
滚，如果进行全部优化，则回滚；

############################################################################

M8 进程控制

1)PID为0的进程通常是调度进程swapper，是内核的一部分，并不执行任何磁盘上的程序
，因此也被称为系统进程；PID为1的进程是init，它不是内核进程，是一个普通的用户进
程，只不过以root权限运行；PID为2的是页守护进程(pagedaemon)。

2)fork执行一次，返回两次，子进程复制父进程的数据空间、堆、栈的副本，父子进程共
享程序正文段；
在子进程中创建父进程的副本的时候，遵循写时复制。

文件共享，父进程打开的文件描述符也被复制到子进程中，例如无名管道pipe的创建就是
利用了这个道理。

fork失败的原因：
a.系统中已经有了太多的进程；
b.该实际用户ID的进程总数超过了系统限制；

3)wait/waitpid
a.如果子进程已经终止，但是父进程还没有终止，并且父进程没有对子进程调用wait或者
waitpid，那么子进程就会变成僵死进程，通过ps aux命令可以查看到其状态为
Z+<defunct>;
b.如果子进程的父进程已经终止，那么子进程将由init进程领养，init进程对每个终止的
子进程调用waitpid，因此可以保证不会使领养进程变成僵死进程；
c.书上说的通过两次fork避免产生僵死进程（P183）有点牵强，不过也是利用来init进程
领养这个原理而已。

4)竞争条件的解决
a.通过信号实现进程间通信
b.通过各种其他进程间通信机制

5)exec函数的执行会用新程序的正文段、堆、栈替换当前进程中的对应部分，但是并没有
创建新的进程，因此进程的ID不会发生改变
6个exec函数的转换关系P191

6)更改用户ID和组ID

时刻铭记，有效用户ID、有效组ID、附加ID，用于文件访问权限检查！！！

有两种方式达到这个目的：a.通过chmod u+s,chmod g+s设置程序文件本身的设置用户ID
位、设置组ID位；b.在程序代码中通过setuid、setgid函数设置设置用户ID位、设置组ID
位；

注意两种方式的要点：
a.
exec函数不能修改实际用户ID，可能修改有效用户ID，每次都会修改保存的设置用户ID；
exec函数根据程序文件本身有没有通过chmod添加设置用户ID位、设置组ID位，决定是
否将程序文件的属主ID设置为调用进程的有效用户ID。如果程序文件被设置了设置用户ID
位，exec将程序文件的属主ID设置为进程的有效用户ID，然后将该有效用户ID复制到保存
的设置用户ID，然后执行该程序；如果程序文件本身没有设置设置用户ID 位，那么有效
用户ID位就是实际用户ID位，那么exec 函数只是将有效用户ID复制到保存的设置用户ID
； 

保存的设置用户ID用于exec返回前，恢复进程的有效用户ID；
b.setuid类似于在程序的运行过程中调用chmod一样，修改进程的有效用户ID；
如果进程具有root权限，调用setuid(uid)时会将实际用户id、有效用户id、保存的设置
用户id全部设置为uid；但是这样调用setuid之后，root权限一旦丢失，无法再通过
setuid(0)将权限恢复成root权限，可以用seteuid代替setuid。
如果进程没有root权限，是普通用户权限，仅当setuid(uid)中的uid等于实际用户id时或
者等于保存的设置用户id时，才能够将有效用户id设置成uid，但是实际用户id和保存的
设置用户id不变。

详情请参见P239

7. 
getuid(): return the real user id of calling process
geteuid(): return the effective user id of calling process
这两个函数的功能容易区分，一个是返回实际用户id，一个是返回有效用户id；

setuid(uid): set the effective user id of calling process
seteuid(uid): set the effective user id of calling process
这两个函数的功能不容易区分，都是设置有效用户id，区别何在呢?
1)如果非root权限运行的进程调用这两个函数，那么没有什么区别，当uid等于实际用户
id或者保存的设置用户id时才可以修改有效用户id为uid，但是实际用户id和保存的设置
用户id不会改变
2)如果是以root权限运行的进程调用这两个函数，就有区别了。如果进程调用
setuid(uid)放弃了root权限，当希望再次恢复root权限运行时，setuid(0)不会调用成功
，无法恢复root权限；但是如果是通过调用seteuid(uid)放弃root权限，以后希望恢复
root权限运行时，就可以通过seteuid(0)来恢复root权限；

可以参看例子P194 man的工作原理，也顺便了解保存的设置用户ID用来恢复有效用户ID的
原理。所有的东西都是围绕有效用户ID转的。

8. 进程会计

############################################################################

M9 进程关系

1)进程组
进程组，是一个或者多个进程的集合。通常，进程组中的进程与同一作业相关联。
进程组存在组长进程，组长进程的进程id与进程组的id相同，组长进程可以创建一个进程
组;
setpgid(pid_t pid, pid_t pgid)既可以改变进程的进程组id，也可以创建一个新的进程
组，另外setsid函数也可以创建一个新的进程组；

2)会话
会话，是一个或者多个进程组的集合。
通常管道线可以用来将前后的几个进程编入一个进程组中，例如proc1 | proc2 &将创建
一个包含进程proc1和proc2的进程组，并且是后台进程组；
进程组中的非组长进程可以通过调用pid_t setsid(void)创建一个新的会话；创建新的会
话之后，调用进程成为会话首进程，并且成为新进程组的组长；调用进程将失去对控制终
端的控制，但是会话首进程仍然可以通过open调用打开控制终端，只有会话非首进程才可
以彻底失去对控制终端的控制。
鉴于此，可以通过创建会话非首进程，用它来作为daemon进程。

会话，通常包含前台进程组和后台进程组，终端产生的终端、退出信号将传递给前台进程
组中的所有进程，调制解调器的挂断信号，则会发送给会话的控制进程，就是会话的首进
程。

3)作业控制
一个作业，只是几个进程的集合，通常是用管道线连接起来的几个进程，也就是说，一个
作业基本上是对应着一个进程组。

作业既可以在前台运行，也可以在后台运行。在后台作业时，shell赋予它一个作业标识。

4)shell执行程序的方式
ps | cat1 | cat2
请参见P227，注意管道线连接的多个进程中的最后一个进程才是子shell要通过exec执行
的程序。
大体上执行流程如下：
shell执行fork，创建子进程，我们称为子shell；
子shell中创建两个管道，第一个是pipe_ps_cat1，第二个是pipe_cat1_cat2；
子shellfork两次，分别称为子子shell1，子子shell2；
子子shell1中将标准输出重定向至pipe_ps_cat1的写端，子子shell2将标准输入重定向至管道的读段；
子子shell2将标准输出重定向至管道pipe_cat1_cat2的写端；
子shell将标准输入重定向至管道pipe_cat1_cat2的读段，并调用exec执行ps；

############################################################################

M10 信号
1)信号是软件中断，信号提供了一种处理异步事件的方法
2)头文件signal.h中定义了信号，信号是正整数
3)不存在编号为0的信号，kill函数对信号编号0有特殊的应用
4)信号是随机出现的，程序必须告诉内核，在信号到达时，执行下列3种操作中的一种：
忽略、采用默认动作、用户自定义的信号捕捉函数
5)signal函数
学习signal函数的时候，学习sigaction函数，这样对信号的理解和学习更好。

在最早的signal实现中，程序接收到信号之后，准备调用信号处理函数之前，就把对信号
的处理方式恢复为 SIG_DFL，并且在调用信号处理函数的过程中并不屏蔽这个信号。但是
如果想继续以当前处理方式对信号进行处理时，不得不在进入信号处理函数时，立即调用
signal函数重新对信号注册当前信号函数，但是由于没有屏蔽该信号，加入在成功调用
signal之前信号到达了，那么就会执行了默认的处理动作，例如SIGINT的默认动作是退出
，之前的信号处理函数还没有执行，程序就已经退出了。
综合这两点，1)执行信号处理程序时，信号没有被屏蔽2)signal将信号处理方式重置为默
认，就使得这个信号处理不可靠。

6)解决不可靠信号的方法就是，通过signaction函数，由于可以通过信号屏蔽字屏蔽信号
，并且不会自动将对信号的处理方式重置为默认，因此可以实现可靠的信号处理。

现在的signal函数，一般都是在sigaction函数的基础上实现的，因此可以保证对信号的
可靠处理。对于简单的信号处理，signal完全已经够用了，如果需要更复杂的信号处理，
那就还是要通过sigaction来实现。

几种常用快捷键对应生成的信号：
- ctrl+z : put foreground process into background and keep it running
- ctrl+c : terminate foreground process
- ctrl+\ : terminate foreground process and core dumped,but i didn't find the core file.

>ps: 这里列下常见的几个信号操作函数吧：
>```bash
>	#include <signal.h>
>​	int kill(pid_t pid,int signo);	// kill process marked by pid (send signal to target process)
>​	int raise(int signo);			// kill current process (send signal to calling process)
>​	pid_t getpid();					// get current process id
>
>	#include <unistd.h>
>	void abort(void);				// terminate current process
>	
>	pause();
>	sleep();
>```

############################################################################
/* vim: set ft=text: */
```
