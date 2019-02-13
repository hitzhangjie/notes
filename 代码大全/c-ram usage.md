```c
#include <sys/resource.h>

int getrusage(int who, struct rusage *usage);
```

**1 获取当前进程的物理内存使用量**

当前进程的物理内存使用量，包括了该进程内所有线程的内存用量。

```c
#include <sys/resource.h>

long get_process_rss()
{
    struct rusage ru;
    getrusage(RUSAGE_SELF, &ru);
    return ru.ru_maxrss;
}
```

**2 获取当前线程的物理内存使用量**

```c
#include <sys/resource.h>

long get_thread_rss()
{
    struct rusage ru;
    getrusage(RUSAGE_THREAD, &ru);
    return ru.ru_maxrss;
}
```

**3 获取等待被回收的子进程内存使用量**

获取当前进程的等待被回收的子进程的物理内存使用量，等待被回收的子进程指的是已经终止并且等待被当前进程（父进程）回收的子进程，也可能包括了等待被回收的子孙进程（但是没有子孙进程的后代）。

```c
#include <sys/resource.h>

long get_subprocess_rss()
{
    struct rusage ru;
    getrusage(RUSAGE_CHILDREN, &ru);
    return ru.ru_maxrss;
}
```
