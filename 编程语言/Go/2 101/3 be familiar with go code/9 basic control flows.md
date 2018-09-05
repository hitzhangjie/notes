# Basic Control Flows

- The control flow code blocks in Go are much like other popular programming languages, but there are also many differences. This article will show these similarities and differences.  An Introduction Of Control Flows In Go  There are three kinds of basic control flow code blocks in Go: if-else two-way conditional execution block. for loop block. switch-case multi-way conditional execution block. There are also some control flow code blocks which are related to some certain kinds of types in Go. for-range loop block for container types. type-switch multi-way conditional execution block for interface types. select-case block for channel types. Like many other popular languages, Go also supports break, continue and goto code execution jump statements. Beside these, there is a special code jump statement in Go, fallthrough.  Among the six kinds of control flow blocks, execept the if-else control flow, the other five are call breakable control flow blocks. We can use break statements to make executions jump out of breakable control flow blocks.  for and for-range loop blocks are called loop control flow blocks. The other four kinds of control flow blocks can all be called as conditional execution control flow blocks. We can use continue statements to end a loop step in advance in a loop control flow block.    [go101.org]

  > "golang中提供了如下6种形式的控制流。 if-else分支控制，for循环，switch-case分支控制，还有三种与数据类型相关的，for-range遍历slice、map、chan，type-switch判断interface动态type，select-case判断chan读写就绪。除了if-else，其他5种都可以使用break跳出，但是对于switch-case、type-switch、select-case不需要显示地写break，这一点不同于c、c++。如果希望某个case的logic执行后，希望继续走到下一个case logic，可以使用fallthrough以达到类似c、c++的效果。"

- if InitSimpleStatement; Condition { 	// do something } else { // do something }  [go101.org]

- for InitSimpleStatement; Condition; PostSimpleStatement { // do something }  [go101.org]

- switch InitSimpleStatement; CompareOperand0 { case CompareOperandList1: 	// do something case CompareOperandList2: 	// do something ... case CompareOperandListN: 	// do something default: 	// do something }  [go101.org]

- a fallthrough statement must be the final statement in a branch. And a fallthrough statement can't show up in the final branch in a switch-case control flow block.  [go101.org]

> "fallthrough必须是case分支的最后一条语句，且不能在最后一个分支中出现（最后一个分支可能是case或者default）。"
>
> - Like many other languages, Go also supports goto statement. A goto keyword must be followed a label to form a statement. A label is declared with the form LabelName:, where LabelName must be an identifier. A label which name is not the blank identifier must be used at least once.  [go101.org]
>   "golang也支持goto，形式类似于c、c++，但是定义的label必须至少使用一次。"
> - A goto statement must contain a label. A break or continue statement can also contain a label, but the label is optional.  [go101.org]
>   "golang也支持break label、continue label这种形式。"