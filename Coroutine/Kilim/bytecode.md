# 字节码

# ASM OW2

JVM字节码还是要好好研究一下的，不然要做字节码增强就无从谈起了。ASM字节码操作库只是用来方便我们修改字节码的，需要增加哪些字节码还是需要我们自己确定下来的。

[1]. [JVM byte code for dummies](https://www.youtube.com/watch?v=rPyqB1l4gko)

---

# Byte Code

## 什么是字节码指令？

- 一字节指令
- 256个opcode（unsigned byte）
- 当前JVM中使用了约200个

## 字节码指令的变化？

- JVM中目前只使用了200个opcode，剩余的留作备用
- 自Java 1.0诞生，有些opcode被废弃了，有些被新添加进来
- 但是自Java 7诞生至现在并没有增加多少指令opcode

---

# Microsoft's CLR

## CLR是一款JVM

- 它是基于栈的，不是基于解释器的
- 两字节的wordcodes
- 有与JVM类似的操作

## CLR优缺点

CLR直接将生成的中间代码当做字节码，然后编译成机器代码

- 刚启动时执行速度比较快
- 不能像大多数现有JVM一样进行运行时优化
  - 无法对运行时热点代码进行分析然后再次优化
  - 无法对运行时引用是否为null、数组是否越界进行检查
  - 等等

---

# Why Learn Byte Code

- 更好地了解平台相关的细节
  - from top to bottom
- 字节码生成，简单、有趣
  - 建立自己的语言？
- 将来可能遇到阅读字节码的场景
  - 很多第三方库都会生成字节码

---

# Hello world

```java
public class HelloWorld {
    public static void main(String ... args) {
        System.out.println("Hello World");
    }
}
```

```
// 编译代码生成字节码文件
javac HelloWorld.java
```

---

# javap

```
// 反汇编字节码文件
javap HelloWorld.class
```

```java
// 反汇编字节码文件得到的输出信息：
// - 可以看到字节码文件由哪个java文件生成
// - 可以看到原来的java文件中定义的类以及方法的签名
Compiled from "HelloWorld.java"
class HelloWorld {
  HelloWorld();
  public static void main(java.lang.String[]);
}
```

---

# javap -c

```
// 反汇编字节码文件
javap -c HelloWorld.class
```

```
// 反汇编字节码文件得到的输出信息：
// - 可以看到字节码文件由哪个java文件生成
// - 可以看到原来的java文件定义的类以及方法签名
// - 可以看到方法实现对应的字节码
Compiled from "HelloWorld.java"
class HelloWorld {
  HelloWorld();
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
       3: ldc           #3                  // String Hello World
       5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
       8: return
}
```

---

# javap -c -verbose

```
javap -c -verbose HelloWorld.class
```

```
Classfile /Users/zhangjie/tmp/java/HelloWorld.class
  Last modified Dec 9, 2017; size 425 bytes
  MD5 checksum f465bb41541f58af52b40e439fb8f065
  Compiled from "HelloWorld.java"
class HelloWorld
  minor version: 0
  major version: 52
  flags: ACC_SUPER
Constant pool:
   #1 = Methodref          #6.#15         // java/lang/Object."<init>":()V
   #2 = Fieldref           #16.#17        //
java/lang/System.out:Ljava/io/PrintStream;
   #3 = String             #18            // Hello World
   #4 = Methodref          #19.#20        // java/io/PrintStream.println:
```

---

```
(Ljava/lang/String;)V
   #5 = Class              #21            // HelloWorld
   #6 = Class              #22            // java/lang/Object
   #7 = Utf8               <init>
   #8 = Utf8               ()V
   #9 = Utf8               Code
  #10 = Utf8               LineNumberTable
  #11 = Utf8               main
  #12 = Utf8               ([Ljava/lang/String;)V
  #13 = Utf8               SourceFile
  #14 = Utf8               HelloWorld.java
  #15 = NameAndType        #7:#8          // "<init>":()V
  #16 = Class              #23            // java/lang/System
  #17 = NameAndType        #24:#25        // out:Ljava/io/PrintStream;
  #18 = Utf8               Hello World
  #19 = Class              #26            // java/io/PrintStream
  #20 = NameAndType        #27:#28        // println:(Ljava/lang/String;)V
  #21 = Utf8               HelloWorld
  #22 = Utf8               java/lang/Object
  #23 = Utf8               java/lang/System
  #24 = Utf8               out
  #25 = Utf8               Ljava/io/PrintStream;
  #26 = Utf8               java/io/PrintStream
  #27 = Utf8               println
  #28 = Utf8               (Ljava/lang/String;)V
```

---

```
{
  HelloWorld();
    descriptor: ()V
    flags:
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 3: 0

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=1, args_size=1
         0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
         3: ldc           #3                  // String Hello World
         5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
         8: return
      LineNumberTable:
        line 6: 0
        line 7: 8
}
SourceFile: "HelloWorld.java"
```

---

### javap -c -verbose

```
javap -c -verbose，-verbose选项使得输出的内容更加丰富

- constant pool
列出了包括方法引用、字段引用、字符串、整型等的常量

- 字节码信息更丰富
列出了descriptor、flags，code增加了stack、locals、args_size
```

<br>
<br>
**至此向大家介绍了javap的常见使用方式**  

- javap可以提取字节码中的所有信息
- 大家需要了解更多字节码指令的信息、Java内存模型(JMM)等，以便能理解字节码

---

# TraceClassVisitor

## 简介

- 可将class文件反汇编成字节码
- 还支持修改class文件

## 如何使用

下面将进行描述，ready？ go！

---
