There may be a situation, when you need to **execute a block of code several number of times**. In general, statements are executed sequentially: The first statement in a function is executed first, followed by the second, and so on.

Programming languages provide various control structures that allow for more complicated execution paths.

A loop statement allows us to execute a statement or group of statements multiple times and following is the general form of a loop statement in most of the programming languages −


```plantuml
start
while (condition?)
    : condition code;
endwhile
stop
```

Go programming language provides the following types of loop to handle looping requirements.

| No. | Loop Types & Descriptions |
|:----:|:-------------------------------|
| 1 | **for loop**<br>It executes a sequence of statements multiple times and abbreviates the code that manages the loop variable.
| 2 | **nested loop**<br>These are one or multiple loops inside any for loop.

# Loop Control Statements

Loop control statements change an execution from its normal sequence. When an execution leaves its scope, all automatic objects that were created in that scope are destroyed.

Go supports the following control statements −

| No. | Control Statement & Description |
|:----:|:--------------------------------------|
| 1 | **break statement**<br>It terminates a for loop or switch statement and transfers execution to the statement immediately following the for loop or switch.
| 2 | **continue statement**<br>It causes the loop to skip the remainder of its body and immediately retest its condition prior to reiterating.
| 3 | **goto statement**<br>It transfers control to the labeled statement.

# The Infinite Loop

A loop becomes an infinite loop if its condition never becomes false. The for loop is traditionally used for this purpose. Since none of the three expressions that form the for loop are required, you can make an endless loop by leaving the conditional expression empty or by passing true to it.

```
package main

import "fmt"

func main() {
   for true  {
       fmt.Printf("This loop will run forever.\n");
   }
}
```

When the conditional expression is absent, it is assumed to be true. You may have an initialization and increment expression, but C programmers more commonly use the for(;;) construct to signify an infinite loop.

