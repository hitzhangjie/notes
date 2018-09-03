# Introduction Of Source Code Elements

**1 Simply speaking, what is programming?**

编程，就是借助编程语言组合一系列的对计算机各种硬件设备的操作，来完成特定的任务。

**2 high-level programming, many words are reserved to prevent them being used as identifiers. Such words are called keywords.**

编程语言里面的keywords用来定义类型、函数等等，这些东西可以帮助编译器解析源代码。称这些特殊的word为关键字。

**3 golang semicolons ";" rules**

golang中很多时候是不需要手动插入分号';'的，这是因为golang编译器编译前会自动插入分号。插入分号是有两个规则的，仅当满足这两个规则时才会自动插入分号，否则不插入分号。

当输入字符序列被转换成token序列后，遇到如下情形时，会自动将一个分号插入到token stream中一行的结束位置：
- 遇到的token是一个integer、floating-point，imaginary，rune、string字面量或者关键字break、continue、fallthrough、return之一；
- 遇到的token是运算符或++ -- ) ] }标点之一；

有时复杂语句会写在一行中，这种情况下，需要忽略结束括号)或者}前面的分号，比如for `{fmt.Println("hello")}`，本来如果正常断行的情况下，编译器会自动在语句`fmt.Println("hello")`后面加一个分号，但是现在写在同一行的时候编译器不会自动插入，也不需要手动插入。

**4 Generally, we should only break a code line just after a binary operator, an assignment sign, a single dot (.), a comma, a semicolon, or any opening brace ({, [, ().  [go101.org]**

有的时候容易因为错误的换行导致编译器插入分号后编译失败，如何避免这个问题呢？有个简单的方法，我们平时换行的时候，**只在二元操作符、赋值符号、单元操作符'.'以及逗号、分号、{、[、（之后换行就可以了**。 有些人喜欢这种规则，有些人不喜欢，但是官方介绍这可以保证风格一致，也可以加快编译速度。