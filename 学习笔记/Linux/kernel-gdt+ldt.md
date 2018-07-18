每个进程在gdt中存储两项，分别是tss和ldt，Linux源码中对两个结构体的定义如下。

### tss，任务状态段

tss中维持了与进程相关的处理器硬件上下文信息，主要是用于进程切换，其在内核源码中对应的数据结构为struct tss_struct，定义如下：

```
286 struct tss_struct {
287         /*
288          * The hardware state:
289          */
290         struct x86_hw_tss       x86_tss;
291 
292         /*
293          * The extra 1 is there because the CPU will access an
294          * additional byte beyond the end of the IO permission
295          * bitmap. The extra byte must be all 1 bits, and must
296          * be within the limit.
297          */
298         unsigned long           io_bitmap[IO_BITMAP_LONGS + 1];
299 
300 #ifdef CONFIG_X86_32
301         /*
302          * Space for the temporary SYSENTER stack.
303          */
304         unsigned long           SYSENTER_stack_canary;
305         unsigned long           SYSENTER_stack[64];
306 #endif
307 
308 } ____cacheline_aligned;
```

其中结构体struct x86_hw_tss x86_tss中存储的是处理器中各个寄存器的值（根据处理器架构不同定义的结构体内容也不同），定义如下：

```
213 #ifdef CONFIG_X86_32
214 /* This is the TSS defined by the hardware. */
215 struct x86_hw_tss {
216         unsigned short          back_link, __blh;
217         unsigned long           sp0;
218         unsigned short          ss0, __ss0h;
219         unsigned long           sp1;
220 
221         /*
222          * We don't use ring 1, so ss1 is a convenient scratch space in
223          * the same cacheline as sp0.  We use ss1 to cache the value in
224          * MSR_IA32_SYSENTER_CS.  When we context switch
225          * MSR_IA32_SYSENTER_CS, we first check if the new value being
226          * written matches ss1, and, if it's not, then we wrmsr the new
227          * value and update ss1.
228          *
229          * The only reason we context switch MSR_IA32_SYSENTER_CS is
230          * that we set it to zero in vm86 tasks to avoid corrupting the
231          * stack if we were to go through the sysenter path from vm86
232          * mode.
233          */
234         unsigned short          ss1;    /* MSR_IA32_SYSENTER_CS */
235 
236         unsigned short          __ss1h;
237         unsigned long           sp2;
238         unsigned short          ss2, __ss2h;
239         unsigned long           __cr3;
240         unsigned long           ip;
241         unsigned long           flags;
242         unsigned long           ax;
243         unsigned long           cx;
244         unsigned long           dx;
245         unsigned long           bx;
246         unsigned long           sp;
247         unsigned long           bp;
248         unsigned long           si;
249         unsigned long           di;
250         unsigned short          es, __esh;
251         unsigned short          cs, __csh;
252         unsigned short          ss, __ssh;
253         unsigned short          ds, __dsh;
254         unsigned short          fs, __fsh;
255         unsigned short          gs, __gsh;
256         unsigned short          ldt, __ldth;
257         unsigned short          trace;
258         unsigned short          io_bitmap_base;
259 
260 } __attribute__((packed));
261 #else
262 struct x86_hw_tss {
263         u32                     reserved1;
264         u64                     sp0;
265         u64                     sp1;
266         u64                     sp2;
267         u64                     reserved2;
268         u64                     ist[7];
269         u32                     reserved3;
270         u32                     reserved4;
271         u16                     reserved5;
272         u16                     io_bitmap_base;
273 
274 } __attribute__((packed)) ____cacheline_aligned;
275 #endif
```

### ldt，局部描述符表
ldt维护与进程相关的分段内存管理相关的信息，其对应的内核源码中的数据结构为struct ldt_struct，定义如下：

```
 36 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 37 /*
 38  * ldt_structs can be allocated, used, and freed, but they are never
 39  * modified while live.
 40  */
 41 struct ldt_struct {
 42         /*
 43          * Xen requires page-aligned LDTs with special permissions.  This is
 44          * needed to prevent us from installing evil descriptors such as
 45          * call gates.  On native, we could merge the ldt_struct and LDT
 46          * allocations, but it's not worth trying to optimize.
 47          */
 48         struct desc_struct *entries;
 49         int size;
 50 };
 ```
 
 其中desc_struct *entries指向一个desc_struct数组，数组长度为size，每一个desc_struct描述了一个段内存相关信息，其定义如下：
 
 ```
 14 /*
 15  * FIXME: Accessing the desc_struct through its fields is more elegant,
 16  * and should be the one valid thing to do. However, a lot of open code
 17  * still touches the a and b accessors, and doing this allow us to do it
 18  * incrementally. We keep the signature as a struct, rather than an union,
 19  * so we can get rid of it transparently in the future -- glommer
 20  */
 21 /* 8 byte segment descriptor */
 22 struct desc_struct {
 23         union {
 24                 struct {
 25                         unsigned int a;
 26                         unsigned int b;
 27                 };
 28                 struct {
 29                         u16 limit0;
 30                         u16 base0;
 31                         unsigned base1: 8, type: 4, s: 1, dpl: 2, p: 1;
 32                         unsigned limit: 4, avl: 1, l: 1, d: 1, g: 1, base2: 8;
 33                 };
 34         };
 35 } __attribute__((packed));
```

desc_struct中定义了内存的段起始地址、段长度、类型、特权级别等信息，对访存操作进行控制。

### 总结

每个进程在gdt中都占据两项，分别是tss、ldt，tss保存了进程的处理器相关的硬件上下文信息，ldt保存了进程的访存信息。
当某个进程被调度执行时，tss中记录的cr3寄存器用于设置进程特定的页表起始地址，代码中的访存信息将从逻辑地址（段选择符：偏移量）转换为线性地址（与逻辑地址完全相同），然后再通过内核的分页管理转换成物理内存地址，用于最终的内存访问。


