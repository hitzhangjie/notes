# GoNeat服务支持daemon方式启动



## **问题描述**：请描述您发现的框架中不完善的点？

当前框架在线上运行是借助nohup来屏蔽SIGHUP，但是框架里面又重新修改了SIGHUP的处理方式，存在的问题：

- 如果框架收到SIGHUP，则会执行退出流程；
- 如果终端异常关闭并且发出了SIGHUP信号，服务将退出；

最终的问题是，goneat服务启动后并不是一个daemon进程在运行，其并没有完全脱离控制终端，终端掉线、断开仍然可能会收到SIGHUP而退出，
这个与开发人员的预期不符，容易给开发人员困惑。需要做些优化。



## **优化方法（可选）**：如您有建议的优化方法，请在此描述

1、进程支持普通进程、daemon进程方式运行；
2、进程保留SIGHUP信号默认处理方式（退出），如果希望屏蔽SIGHUP，借助nohup这种比较通用的方式；
3、进程daemon方式运行，脱离了控制终端，终端异常断开不会在向其发送SIGHUP，进程可以正常运行。
要不要屏蔽SIGHUP，这里可以与linux平台下的daemon(3)对齐，符合大家使用习惯



可借助外部工具daemonize或操作系统工具systemd、upstart、launchd来实现服务daemon启动，不建议自己实现：

- 系统调用fork会复制进程地址空间，但是并不会继承所有的线程，只有调用fork()的线程能够得到继承，child process里面只有调用fork()的那个线程的副本，其他线程不存在。
- go程序天然是多线程程序，不能确定编程人员在何处启动goroutine（引入新线程）.

- github上有个实现：<https://github.com/sevlyar/go-daemon>，可了解下，但不建议goneat框架层实现或者集成。



## demo：fork出的子进程不能完全继承所有线程

fork不能复制进程中的其他线程，下面是测试demo：

该程序将创建两个线程，然后两个线程跑起来之后就sleep 1min，主线程开始fork：

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>

void* tfunc1(void *args) {
    printf("tfunc1, get pid:%u, tid:%u\n", getpid(), pthread_self());
    sleep(60);
}

void* tfunc2(void *args) {
    printf("tfunc2, get pid:%u, tid:%u\n", getpid(), pthread_self());
    sleep(60);
}

int main(int argc, char *argv[])
{
    int ret;
    pthread_t t1, t2;

    ret = pthread_create(&t1, NULL, tfunc1, NULL);
    ret = pthread_create(&t2, NULL, tfunc2, NULL);

    pid_t pid = fork();
    if (pid != 0) { // parent process
        printf("create process, pid:%u\n", pid);
    } else { // child process
        sleep(30); // hold to check how many threads has been copied from parent process
    }

    sleep(10);

    return 0;
}
```

运行结果：

```bash
[root@VM_1_34_centos ~]# ./main
tfunc2, get pid:2672, tid:397674240
tfunc1, get pid:2672, tid:406066944
create process, pid:2675
```

在1min内立即运行top命令查看新进程中包括的轻量级进程数量，结果只有一个线程，说明父进程中除调用fork()的主线程被复制了之外，进程中其他线程没有被复制：
```bash
top -H -p 2675

Threads:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.1 us,  0.1 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem : 16171652 total,  3413496 free,   450324 used, 12307832 buff/cache
KiB Swap:        0 total,        0 free,        0 used. 15009260 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
 2675 root      20   0   25968    140      0 S  0.0  0.0   0:00.00 main
```

谁调用fork这个函数，新创建的进程里面就包括哪个线程的副本，也不是说fork会复制主线程。