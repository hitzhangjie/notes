Go programming provides a pretty simple error handling framework with inbuilt error interface type of the following declaration −

```go
type error interface {
   Error() string
}
```

Functions normally return error as last return value. Use errors.New to construct a basic error message as following −

```go
func Sqrt(value float64)(float64, error) {
   if(value < 0){
      return 0, errors.New("Math: negative number passed to Sqrt")
   }
   return math.Sqrt(value)
}
```

Use return value and error message.

```go
result, err:= Sqrt(-1)

if err != nil {
   fmt.Println(err)
}
```

# Example

```go
package main

import "errors"
import "fmt"
import "math"

func Sqrt(value float64)(float64, error) {
   if(value < 0){
      return 0, errors.New("Math: negative number passed to Sqrt")
   }
   return math.Sqrt(value), nil
}
func main() {
   result, err:= Sqrt(-1)

   if err != nil {
      fmt.Println(err)
   } else {
      fmt.Println(result)
   }
   
   result, err = Sqrt(9)

   if err != nil {
      fmt.Println(err)
   } else {
      fmt.Println(result)
   }
}
```

When the above code is compiled and executed, it produces the following result −

```go
Math: negative number passed to Sqrt
3
```


