Type casting is a way to convert a variable from one data type to another data type. For example, if you want to store a long value into a simple integer then you can type cast long to int. You can convert values from one type to another using the cast operator. Its syntax is as follows −

`type_name(expression)`

# Example

Consider the following example where the cast operator causes the division of one integer variable by another to be performed as a floating number operation.

```go
package main

import "fmt"

func main() {
   var sum int = 17
   var count int = 5
   var mean float32
   
   mean = float32(sum)/float32(count)
   fmt.Printf("Value of mean : %f\n",mean)
}
```

When the above code is compiled and executed, it produces the following result −

`Value of mean : 3.400000`


