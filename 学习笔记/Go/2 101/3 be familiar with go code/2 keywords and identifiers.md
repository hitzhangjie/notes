# Keywords And Identifiers

- keywords can be categorized as four groups

> "golang 1.10现在包括25个keywords，他们可以划分成如下4类。
> 1）const, func, import, package, type and var are used to declare all kinds of code elements in Go programs. 
> 2）chan, interface, map and struct are used as parts in some composite type denotations.
> 3）break, case, continue, default, else, fallthrough, for, goto, if, range, return, select and switch are used to control code flows.
> 4）defer and go can also be viewed as control flow keywords. But they are some special. They are modifiers of function calls."

- identifier naming and _ (underscore)

> "标识符命名规则，字母(unicode字符也可以)、数字、下划线，起始字符必须是字母或者下划线。注意blank identifier _ 是一个特殊的标识符，可以用于初始化包，也可以用于drop某个变量。"

- exported identifier

> "标识符首字母大写表示是一个导出的标识符，可以在外部package中被引用，类似于其他语言中的public访问修饰符，golang 1.10中东亚字符是非导出的。"