### libmill.h

获取系统时间函数**gettimeofday**还是比较耗时的，对于频繁需要获取系统时间的情景下，需要对获取到的系统时间做一定的cache。为了保证时间精度，这里的cache更新时间必须要控制好。

如何决定何时更新cache的系统时间呢？**rdtsc**（read timestamp counter）指令执行只需要几个时钟周期，它返回系统启动后经过的时钟周期数。这里可以根据CPU频率指定一个时钟周期数量作为阈值，当前后两次rdtsc读取到的时钟周期数的差值超过这个阈值再调用gettimeofday来更新系统时间。这里libmill中的定时器timer就是这么实现的。

下面是**rdtsc**指令的简要说明，详情请查看：[wiki rdtsc](https://en.wikipedia.org/wiki/Time_Stamp_Counter)。

>The Time Stamp Counter (TSC) is a 64-bit register present on all x86 processors since the Pentium. It counts the number of cycles since reset. The instruction RDTSC returns the TSC in EDX:EAX. In x86-64 mode, RDTSC also clears the higher 32 bits of RAX and RDX. Its opcode is 0F 31.[1] Pentium competitors such as the Cyrix 6x86 did not always have a TSC and may consider RDTSC an illegal instruction. Cyrix included a Time Stamp Counter in their MII.


```c
......

// ABI应用程序二进制接口
#define MILL_VERSION_CURRENT 19         // 主版本
#define MILL_VERSION_REVISION 1         // 修订版本
#define MILL_VERSION_AGE 1              // 支持过去的几个版本

......

#define MILL_FDW_IN_ 1
#define MILL_FDW_OUT_ 2
#define MILL_FDW_ERR_ 4

#if defined(__x86_64__)
......
// 保存当前协程运行时的上下文信息（启示就是保存寄存器相关信息到ctx指定的内存区域中）
#define mill_setjmp_(ctx) ({\
    int ret;\
    asm("lea     LJMPRET%=(%%rip), %%rcx\n\t"\
        "xor     %%rax, %%rax\n\t"\
        "mov     %%rbx, (%%rdx)\n\t"\
        "mov     %%rbp, 8(%%rdx)\n\t"\
        "mov     %%r12, 16(%%rdx)\n\t"\
        "mov     %%rsp, 24(%%rdx)\n\t"\
        "mov     %%r13, 32(%%rdx)\n\t"\
        "mov     %%r14, 40(%%rdx)\n\t"\
        "mov     %%r15, 48(%%rdx)\n\t"\
        "mov     %%rcx, 56(%%rdx)\n\t"\
        "mov     %%rdi, 64(%%rdx)\n\t"\
        "mov     %%rsi, 72(%%rdx)\n\t"\
        "LJMPRET%=:\n\t"\
        : "=a" (ret)\
        : "d" (ctx)\
        : "memory", "rcx", "r8", "r9", "r10", "r11",\
          "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7",\
          "xmm8", "xmm9", "xmm10", "xmm11", "xmm12", "xmm13", "xmm14", "xmm15"\
          MILL_CLOBBER\
          );\
    ret;\
})

// 实现跳转到指定上下文信息
// 一般是要恢复执行某个协程时，先获取待运行协程的cr->ctx，然后mill_longjmp即可
#define mill_longjmp_(ctx) \
    asm("movq   (%%rax), %%rbx\n\t"\
	    "movq   8(%%rax), %%rbp\n\t"\
	    "movq   16(%%rax), %%r12\n\t"\
	    "movq   24(%%rax), %%rdx\n\t"\
	    "movq   32(%%rax), %%r13\n\t"\
	    "movq   40(%%rax), %%r14\n\t"\
	    "mov    %%rdx, %%rsp\n\t"\
	    "movq   48(%%rax), %%r15\n\t"\
	    "movq   56(%%rax), %%rdx\n\t"\
	    "movq   64(%%rax), %%rdi\n\t"\
	    "movq   72(%%rax), %%rsi\n\t"\
	    "jmp    *%%rdx\n\t"\
        : : "a" (ctx) : "rdx" \
    )
#else
// 非x86_64要借助sigsetjmp\siglongjmp来实现协程上下文切换
#define mill_setjmp_(ctx) \
    sigsetjmp(*ctx, 0)
#define mill_longjmp_(ctx) \
    siglongjmp(*ctx, 1)
#endif

// go()的实现
#define mill_go_(fn) \
    do {\
        void *mill_sp;\
        // 获取当前正在运行的协程上下文
        mill_ctx ctx = mill_getctx_();\
        // 记录当前协程上下文
        if(!mill_setjmp_(ctx)) {\
            // mill_prologue创建一个新协程，fn里需io操作进入mill_suspend，然后等待被resume唤醒
            mill_sp = mill_prologue_(MILL_HERE_);\
            int mill_anchor[mill_unoptimisable1_];\
            mill_unoptimisable2_ = &mill_anchor;\
            char mill_filler[(char*)&mill_anchor - (char*)(mill_sp)];\
            mill_unoptimisable2_ = &mill_filler;\
            // 被唤醒后在新协程中继续执行fn这个函数
            fn;\
            // 执行完后再次mill_suspend让出cpu
            mill_epilogue_();\
        }\
    } while(0)



#define mill_chs__(channel, type, value) \
    do {\
        type mill_val = (value);\
        mill_chs_((channel), &mill_val, sizeof(type), MILL_HERE_);\
    } while(0)

#define mill_chr__(channel, type) \
    (*(type*)mill_chr_((channel), sizeof(type), MILL_HERE_))

#define mill_chdone__(channel, type, value) \
    do {\
        type mill_val = (value);\
        mill_chdone_((channel), &mill_val, sizeof(type), MILL_HERE_);\
    } while(0)

#define mill_choose_init__ \
    {\
        mill_choose_init_(MILL_HERE_);\
        int mill_idx = -2;\
        while(1) {\
            if(mill_idx != -2) {\
                if(0)

#define mill_choose_in__(chan, type, name, idx) \
                    break;\
                }\
                goto mill_concat_(mill_label, idx);\
            }\
            char mill_concat_(mill_clause, idx)[MILL_CLAUSELEN_];\
            mill_choose_in_(\
                &mill_concat_(mill_clause, idx)[0],\
                (chan),\
                sizeof(type),\
                idx);\
            if(0) {\
                type name;\
                mill_concat_(mill_label, idx):\
                if(mill_idx == idx) {\
                    name = *(type*)mill_choose_val_(sizeof(type));\
                    goto mill_concat_(mill_dummylabel, idx);\
                    mill_concat_(mill_dummylabel, idx)

#define mill_choose_out__(chan, type, val, idx) \
                    break;\
                }\
                goto mill_concat_(mill_label, idx);\
            }\
            char mill_concat_(mill_clause, idx)[MILL_CLAUSELEN_];\
            type mill_concat_(mill_val, idx) = (val);\
            mill_choose_out_(\
                &mill_concat_(mill_clause, idx)[0],\
                (chan),\
                &mill_concat_(mill_val, idx),\
                sizeof(type),\
                idx);\
            if(0) {\
                mill_concat_(mill_label, idx):\
                if(mill_idx == idx) {\
                    goto mill_concat_(mill_dummylabel, idx);\
                    mill_concat_(mill_dummylabel, idx)

#define mill_choose_deadline__(ddline, idx) \
                    break;\
                }\
                goto mill_concat_(mill_label, idx);\
            }\
            mill_choose_deadline_(ddline);\
            if(0) {\
                mill_concat_(mill_label, idx):\
                if(mill_idx == -1) {\
                    goto mill_concat_(mill_dummylabel, idx);\
                    mill_concat_(mill_dummylabel, idx)

#define mill_choose_otherwise__(idx) \
                    break;\
                }\
                goto mill_concat_(mill_label, idx);\
            }\
            mill_choose_otherwise_();\
            if(0) {\
                mill_concat_(mill_label, idx):\
                if(mill_idx == -1) {\
                    goto mill_concat_(mill_dummylabel, idx);\
                    mill_concat_(mill_dummylabel, idx)

#define mill_choose_end__ \
                    break;\
                }\
            }\
            mill_idx = mill_choose_wait_();\
        }

```

