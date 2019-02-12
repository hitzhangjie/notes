Decision making structures require that the programmer specify **one or more conditions to be evaluated or tested by the program, along with a statement or statements to be executed** if the condition is determined to be true, and optionally, other statements to be executed if the condition is determined to be false.

Following is the general form of a typical decision making structure found in most of the programming languages −

```plantuml
start
if (condition?)  then (true) 
    : condition code;
else (false)
endif
stop
```

Go programming language provides the following types of decision making statements.

| No. | Statement & Description |
|:----:|:-----------------------------|
| 1 | **if statement**<br>An if statement consists of a boolean expression followed by one or more statements.|
| 2 | **if...else statement**<br>An if statement can be followed by an optional else statement, which executes when the boolean expression is false.|
| 3 | **nested if statements**<br>You can use one if or else if statement inside another if or else if statement(s).|
| 4 | **switch statement**<br>A switch statement allows a variable to be tested for equality against a list of values.|
| 5 | **select statement**<br>A select statement is similar to switch statement with difference that case statements refers to **channel** communications.|

> golang中switch-case不要求显示添加break操作（编译器会自动添加），每个分支逻辑执行完后不再执行后续的case分支，如果希望继续执行后续的case分支必须通过语句**fallthrough**，fallthrough必须是case分支的最后一行语句。golang中的单个case分支可以匹配多个条件，如:
>
```
switch(type) {
  case uint8,uint16,uint32:
    ...
  case ...:
  default:
}
```

