Recursion is the process of repeating items in a self-similar way. The same concept applies in programming languages as well. If a program allows to **call a function inside the same function**, then it is called a recursive function call. Take a look at the following example −


```go
func recursion() {
   recursion() /* function calls itself */
}
func main() {
   recursion()
}
```

The Go programming language supports recursion. That is, it allows a function to call itself. But while using recursion, programmers need to **be careful to define an exit condition from the function**, otherwise it will go on to become an infinite loop.

# Examples of Recursion in Go

Recursive functions are very useful to solve many mathematical problems such as calculating factorial of a number, generating a Fibonacci series, etc.

## Example 1: Calculating Factorial Using Recursion in Go

The following example calculates the factorial of a given number using a recursive function −

```go
package main

import "fmt"

func factorial(i int) int {
   if(i <= 1) {
      return 1
   }
   return i * factorial(i - 1)
}
func main() { 
   var i int = 15
   fmt.Printf("Factorial of %d is %d", i, factorial(i))
}
``` 

When the above code is compiled and executed, it produces the following result −

`Factorial of 15 is 2004310016`

## Example 2: Fibonacci Series Using Recursion in Go

The following example shows how to generate a Fibonacci series of a given number using a recursive function −

```go
package main

import "fmt"

func fibonaci(i int) (ret int) {
   if i == 0 {
      return 0
   }
   if i == 1 {
      return 1
   }
   return fibonaci(i-1) + fibonaci(i-2)
}
func main() {
   var i int
   for i = 0; i < 10; i++ {
      fmt.Printf("%d ", fibonaci(i))
   }
}
```

When the above code is compiled and executed, it produces the following result −

`0 1 1 2 3 5 8 13 21 34 `   

