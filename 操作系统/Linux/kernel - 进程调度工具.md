下面是整理的与进程调度相关的一些工具，包括控制进程调度的工具，和监控进程调度的工具，以及背后的相关知识点。



1. taskset：设置进程的CPU粘性

    ```bash
    NAME
           taskset - retrieve or set a process's CPU affinity
    
    SYNOPSIS
           taskset [options] mask command [arg]...
           taskset [options] -p [mask] pid
    ```

    taskset的使用方式有两种：

    - 对于还没有启动的进程，设置其进程粘性，如`taskset [options] mask command [args]...`
    - 对于已经启动的进程，通过其pid来设置进程粘性，如`taskset [options] -p [mask] pid`

    这里的参数mask表示的是CPU掩码，如`0x00000001`表示`CPU CORE #0`。

2. top：查看系统中进程调度情况

    ```bash
    NAME
           top - display Linux processes
    
    SYNOPSIS
           top -hv|-bcHiOSs -d secs -n max -u|U user -p pid -o fld -w [cols]
    
           The traditional switches '-' and whitespace are optional.
    ```

    top的使用方式，简单的大家可能都知道，如`top` 或者 `top -p <pid>` 或者 `top -H -p pid` 等等，top还有些不为人知的高级用法，这里结合上述taskset设置CPU粘性来介绍下top的用法。

    

3. 其他