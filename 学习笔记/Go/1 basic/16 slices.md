**Go Slice is an abstraction over Go Array**. Go Array allows you to define variables that can hold several data items of the same kind but it does not provide any inbuilt method to increase its size dynamically or get a sub-array of its own. Slices overcome this limitation. It provides many utility functions required on Array and is widely used in Go programming.

# Defining a slice

To define a slice, you can declare it as an array without specifying its size. Alternatively, you can use **make** function to create a slice.

```go
var numbers []int /* a slice of unspecified size */
/* numbers == []int{0,0,0,0,0}*/
numbers = make([]int,5,5) /* a slice of length 5 and capacity 5*/
```

# len() and cap() functions

A slice is an abstraction over array. It actually uses arrays as an underlying structure. The len() function returns the elements presents in the slice where cap() function returns the capacity of the slice (i.e., how many elements it can be accommodate). The following example explains the usage of slice −

```go
package main

import "fmt"

func main() {
   var numbers = make([]int,3,5)
   printSlice(numbers)
}
func printSlice(x []int){
   fmt.Printf("len=%d cap=%d slice=%v\n",len(x),cap(x),x)
}
```

When the above code is compiled and executed, it produces the following result −

`len = 3 cap = 5 slice = [0 0 0]`

# Nil slice

If a slice is declared with no inputs, then by default, it is initialized as nil. Its length and capacity are zero. For example −

```go
package main

import "fmt"

func main() {
   var numbers []int
   printSlice(numbers)
   
   if(numbers == nil){
      fmt.Printf("slice is nil")
   }
}
func printSlice(x []int){
   fmt.Printf("len = %d cap = %d slice = %v\n", len(x), cap(x),x)
}
```

When the above code is compiled and executed, it produces the following result −

```
len = 0 cap = 0 slice = []
slice is nil
```

# Subslicing

Slice allows lower-bound and upper bound to be specified to get the sub-slice of it using**[lower-bound:upper-bound]**. For example −

```go
package main

import "fmt"

func main() {
   /* create a slice */
   numbers := []int{0,1,2,3,4,5,6,7,8}   
   printSlice(numbers)
   
   /* print the original slice */
   fmt.Println("numbers ==", numbers)
   
   /* print the sub slice starting from index 1(included) to index 4(excluded)*/
   fmt.Println("numbers[1:4] ==", numbers[1:4])
   
   /* missing lower bound implies 0*/
   fmt.Println("numbers[:3] ==", numbers[:3])
   
   /* missing upper bound implies len(s)*/
   fmt.Println("numbers[4:] ==", numbers[4:])
   
   numbers1 := make([]int,0,5)
   printSlice(numbers1)
   
   /* print the sub slice starting from index 0(included) to index 2(excluded) */
   number2 := numbers[:2]
   printSlice(number2)
   
   /* print the sub slice starting from index 2(included) to index 5(excluded) */
   number3 := numbers[2:5]
   printSlice(number3)
}
func printSlice(x []int){
   fmt.Printf("len = %d cap = %d slice = %v\n", len(x), cap(x),x)
}
```

When the above code is compiled and executed, it produces the following result −

```
len = 9 cap = 9 slice = [0 1 2 3 4 5 6 7 8]
numbers == [0 1 2 3 4 5 6 7 8]
numbers[1:4] == [1 2 3]
numbers[:3] == [0 1 2]
numbers[4:] == [4 5 6 7 8]
len = 0 cap = 5 slice = []
len = 2 cap = 9  slice = [0 1]
len = 3 cap = 7 slice = [2 3 4]
```

# append() and copy() Functions

One can increase the capacity of a slice using the **append**() function. Using **copy**() function, the contents of a source slice are copied to a destination slice. For example −

```go
package main

import "fmt"

func main() {
   var numbers []int
   printSlice(numbers)
   
   /* append allows nil slice */
   numbers = append(numbers, 0)
   printSlice(numbers)
   
   /* add one element to slice*/
   numbers = append(numbers, 1)
   printSlice(numbers)
   
   /* add more than one element at a time*/
   numbers = append(numbers, 2,3,4)
   printSlice(numbers)
   
   /* create a slice numbers1 with double the capacity of earlier slice*/
   numbers1 := make([]int, len(numbers), (cap(numbers))*2)
   
   /* copy content of numbers to numbers1 */
   copy(numbers1,numbers)
   printSlice(numbers1)   
}
func printSlice(x []int){
   fmt.Printf("len=%d cap=%d slice=%v\n",len(x),cap(x),x)
}
```

When the above code is compiled and executed, it produces the following result −

```
len = 0 cap = 0 slice = []
len = 1 cap = 2 slice = [0]
len = 2 cap = 2 slice = [0 1]
len = 5 cap = 8 slice = [0 1 2 3 4]
len = 5 cap = 16 slice = [0 1 2 3 4]
```


