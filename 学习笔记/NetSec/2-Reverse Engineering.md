# 2 逆向工程

## 2.1 简介

逆向工程的概念是相对于正向工程的。正向工程指的是根据软件需求进行分析、设计、实现的过程，逆向工程指的是将可执行程序、库等进行反编译或者反汇编的过程。

- 反编译，指的是将可执行程序、库转换成可以阅读的代码（如c、java或者汇编）的过程；
- 反汇编，指的是将可执行程序、库转换成可以阅读的汇编代码的过程，反汇编属于反编译；

## 2.2 二进制工具

### 2.2.1 Linux平台下
The [GNU Binutils](http://www.gnu.org/s/binutils/) 是一个二进制工具大合集，主要包括：

|工具名称|用途|
|:---------|:-----|
|ld|the GNU linker|
|as|the GNU assembler|
|==|==============|
|addr2line|Converts addresses into filenames and line numbers|
|ar|A utility for creating, modifying and extracting from archives|
|c++filt|Filter to demangle encoded C++ symbols|
|dlltool|Creates files for building and using DLLs|
|gold|A new, faster, ELF only linker, still in beta test|
|gprof|Displays profiling information|
|nlmconv|Converts object code into an NLM|
|nm|Lists symbols from object files|
|objcopy|Copys and translates object files|
|objdump|Displays information from object files|
|ranlib|Generates an index to the contents of an archive|
|readelf|Displays information from any ELF format object file|
|size|Lists the section sizes of an object or archive file|
|strings|Lists printable strings from files|
|strip|Discards symbols|
|windmc|A Windows compatible message compiler|
|windres|A compiler for Windows resource files|

Most of these programs use **BFD (the Binary File Descriptor library)**, to do low-level manipulation. Many of them also use the **opcodes library** to assemble and disassemble machine instructions.

The binutils have been ported to most major Unix variants as well as Wintel systems, and their main reason for existence is to give the GNU system (and GNU/Linux) the facility to compile and link programs.

The detail introduction and use guide is [documentation for binutils 2.21](http://sourceware.org/binutils/docs-2.21) .
## 2.2 反汇编软件

- Windows下：IDA、OllyDebug、C32Dasm；




