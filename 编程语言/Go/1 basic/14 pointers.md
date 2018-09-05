Pointers in Go are easy and fun to learn. Some Go programming tasks are performed more easily with pointers, and other tasks, such as call by reference, cannot be performed without using pointers. So it becomes necessary to learn pointers to become a perfect Go programmer.

As you know, every variable is a memory location and every memory location has its address defined which can be accessed using ampersand (&) operator, which denotes an address in memory. Consider the following example, which will print the address of the variables defined −

```go
package main

import "fmt"

func main() {
   var a int = 10   
   fmt.Printf("Address of a variable: %x\n", &a  )
}
```

When the above code is compiled and executed, it produces the following result −

`Address of a variable: 10328000`

So you understood what is memory address and how to access it. Now let us see what pointers are.

# What Are Pointers?

A pointer is a variable whose value is the address of another variable, i.e., direct address of the memory location. Like any variable or constant, you must declare a pointer before you can use it to store any variable address. The general form of a pointer variable declaration is −

`var var_name *var-type`

Here, type is the pointer's base type; it must be a valid C data type and var-name is the name of the pointer variable. The asterisk * you used to declare a pointer is the same asterisk that you use for multiplication. However, in this statement the asterisk is being used to designate a variable as a pointer. Following are the valid pointer declaration −

```
var ip *int        /* pointer to an integer */
var fp *float32    /* pointer to a float */
```
The actual data type of the value of all pointers, whether integer, float, or otherwise, is the same, a long hexadecimal number that represents a memory address. The only difference between pointers of different data types is the data type of the variable or constant that the pointer points to.

# How to Use Pointers?

There are a few important operations, which we frequently perform with pointers: (a) we define pointer variables, (b) assign the address of a variable to a pointer, and (c) access the value at the address stored in the pointer variable.

All these operations are carried out using the unary operator * that returns the value of the variable located at the address specified by its operand. The following example demonstrates how to perform these operations −

```
package main

import "fmt"

func main() {
   var a int = 20   /* actual variable declaration */
   var ip *int      /* pointer variable declaration */

   ip = &a  /* store address of a in pointer variable*/

   fmt.Printf("Address of a variable: %x\n", &a  )

   /* address stored in pointer variable */
   fmt.Printf("Address stored in ip variable: %x\n", ip )

   /* access the value using the pointer */
   fmt.Printf("Value of *ip variable: %d\n", *ip )
}
```

When the above code is compiled and executed, it produces the following result −

```
Address of var variable: 10328000
Address stored in ip variable: 10328000
Value of *ip variable: 20
```

# Nil Pointers in Go

Go compiler assign a Nil value to a pointer variable in case you do not have exact address to be assigned. This is done at the time of variable declaration. A pointer that is assigned nil is called a **nil** pointer.

The nil pointer is a constant with a value of zero defined in several standard libraries. Consider the following program −

```
package main

import "fmt"

func main() {
   var  ptr *int

   fmt.Printf("The value of ptr is : %x\n", ptr  )
}
```

When the above code is compiled and executed, it produces the following result −

`The value of ptr is 0`

**On most of the operating systems, programs are not permitted to access memory at address 0 because that memory is reserved by the operating system.** However, the memory address 0 has special significance; it signals that the pointer is not intended to point to an accessible memory location. But by convention, **if a pointer contains the nil (zero) value, it is assumed to point to nothing**.

To check for a nil pointer you can use an if statement as follows −

```
if(ptr != nil)     /* succeeds if p is not nil */
if(ptr == nil)    /* succeeds if p is null */
```

# Go Pointers in Detail

Pointers have many but easy concepts and they are very important to Go programming. The following concepts of pointers should be clear to a Go programmer −

| No. | Concept & Description |
|:----:|:---------------------------|
| 1 | **Go-Array of Pointers**<br>You can define arrays to hold a number of pointers.
| 2 | **Go-Pointer to pointer**<br>Go allows you to have pointer on a pointer and so on.
| 3 | **Passing pointers to functions in Go**<br>Passing an argument by reference or by address both enable the passed argument to be changed in the calling function by the called function.


