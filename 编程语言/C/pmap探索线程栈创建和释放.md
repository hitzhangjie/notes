通过pmap测试了一下，发现每次创建一个线程，pmap的输出都会多出一块区域，但是看上去这块区域的地址是在进程的堆和栈之间，这块区域的名字叫anon，搜索了一下anon区域表示的是mmap映射的区域。

当某个线程销毁的时候呢，pmap输出就会减少几个anon区域。那么基本可以断定了线程所使用的内存空间（线程栈）是通过mmap映射到进程的虚拟地址空间中的。而anon区域的大小基本上都是8M，我们也知道，linux下面支持的进程栈或线程栈的最大大小就是8M。而malloc(n)申请内存的时候，小于128k的都是从堆里面分配，大于的都是通过mmap来分配。

这样的话，就搞明白了。

下面线程2回收线程3的时候，其实只是执行了munmap操作，将线程3的栈空间从进程地址空间中移除。

本来我还以为是所有线程栈在当前进程主线程栈sp的基础上减去一个值来当做栈空间呢？但是后面想到如果线程3回收了线程2这个处在线程3栈下方的线程怎么办？sp要怎么操作？线程3的栈空间是否要移动，线程是否要停顿？页表是否要重新映射？

想到这，就有了上面的探索和思考，现在搞明白了。

```c
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

pthread_t tids[3];

void pmap() {
    char cmd[1024];
    memset(cmd, 0, 1024);
    sprintf(cmd, "/usr/bin/pmap %d", getpid());
    system(cmd);
}

void *work(void *param) {
    int i = 0;
    while(i++<10)
        ;
}

void *work2(void *param) {
    sleep(10);
    pthread_join(tids[2], NULL);
    pmap();
}

void *work3(void *param) {
    sleep(5);
}

int main(int argc, char *argv[])
{
    pmap();

    pthread_create(&tids[0], NULL, work, NULL);
    sleep(1);
    pmap();
    
    pthread_create(&tids[1], NULL, work2, NULL);
    sleep(1);
    pmap();
    
    pthread_create(&tids[2], NULL, work3, NULL);
    sleep(1);
    pmap();
    
    pthread_exit(0);
}
```