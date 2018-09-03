A variable is nothing but a name given to a storage area that the programs can manipulate. Each variable in Go has a specific type, which determines the size and layout of the variable's memory, the range of values that can be stored within that memory, and the set of operations that can be applied to the variable.

The name of a variable can be composed of letters, digits, and the underscore character. It must begin with either a letter or an underscore. Upper and lowercase letters are distinct because Go is case-sensitive. Based on the basic types explained in the previous chapter, there will be the following basic variable types −

| No. | Type and Description |
|:----:|:-------------------------|
| 1	|**byte**<br>Typically a single octet(one byte). This is an byte type.|
| 2	|**int**<br>The most natural size of integer for the machine.|
| 3	|**float32**<br>A single-precision floating point value.|

Go programming language also allows to define various other types of variables such as Enumeration, Pointer, Array, Structure, and Union, which we will discuss in subsequent chapters. In this chapter, we will focus only basic variable types.

# Variable Definition in Go

A variable definition tells the compiler where and how much storage to create for the variable. A variable definition specifies a data type and contains a list of one or more variables of that type as follows −

`var variable_list optional_data_type;`

Here, **optional_data_type** is a valid Go data type including byte, int, float32, complex64, boolean or any user-defined object, etc., and **variable_list** may consist of one or more identifier names separated by commas. Some valid declarations are shown here −

```go
var  i, j, k int;
var  c, ch byte;
var  f, salary float32;
d =  42;
```

The statement “**var i, j, k;**” declares and defines the variables i, j and k; which instructs the compiler to create variables named i, j, and k of type int.

Variables can be initialized (assigned an initial value) in their declaration. The type of variable is automatically judged by the compiler based on the value passed to it. The initializer consists of an equal sign followed by a constant expression as follows −

`variable_name = value;`

For example -

`d = 3, f = 5;    // declaration of d and f. Here d and f are int `

For definition without an initializer: variables with static storage duration are implicitly initialized with nil (all bytes have the value 0); the initial value of all other variables is zero value of their data type.

# Static Type Declaration in Go

A static type variable declaration provides assurance to the compiler that there is one variable available with the given type and name so that the compiler can proceed for further compilation without requiring the complete detail of the variable. A variable declaration has its meaning at the time of compilation only, the compiler needs the actual variable declaration at the time of linking of the program.

**Example**
Try the following example, where the variable has been declared with a type and initialized inside the main function −

```
package main

import "fmt"

func main() {
   var x float64
   x = 20.0
   fmt.Println(x)
   fmt.Printf("x is of type %T\n", x)
}
```

When the above code is compiled and executed, it produces the following result −

```
20
x is of type float64
```

# Dynamic Type Declaration / Type Inference in Go

A dynamic type variable declaration requires the compiler to interpret the type of the variable based on the value passed to it. The compiler does not require a variable to have type statically as a necessary requirement.

**Example**
Try the following example, where the variables have been declared without any type. Notice, in case of type inference, we initialized the variable y with := operator, whereas x is initialized using = operator.

```
package main

import "fmt"

func main() {
   var x float64 = 20.0

   y := 42 
   fmt.Println(x)
   fmt.Println(y)
   fmt.Printf("x is of type %T\n", x)
   fmt.Printf("y is of type %T\n", y)	
}
```

When the above code is compiled and executed, it produces the following result −


```
20
42
x is of type float64
y is of type int
```

# Mixed Variable Declaration in Go

Variables of different types can be declared in one go using type inference.

**Example**

```
package main

import "fmt"

func main() {
   var a, b, c = 3, 4, "foo"  
	
   fmt.Println(a)
   fmt.Println(b)
   fmt.Println(c)
   fmt.Printf("a is of type %T\n", a)
   fmt.Printf("b is of type %T\n", b)
   fmt.Printf("c is of type %T\n", c)
}
```

When the above code is compiled and executed, it produces the following result −

```
3
4
foo
a is of type int
b is of type int
c is of type string
```

# The lvalues and the rvalues in Go

There are two kinds of expressions in Go −

- **lvalue** − Expressions that refer to a memory location is called "lvalue" expression. An lvalue may appear as either the left-hand or right-hand side of an assignment.

- **rvalue** − The term rvalue refers to a data value that is stored at some address in memory. An rvalue is an expression that cannot have a value assigned to it which means an rvalue may appear on the right- but not left-hand side of an assignment.

Variables are lvalues and so may appear on the left-hand side of an assignment. Numeric literals are rvalues and so may not be assigned and can not appear on the left-hand side.

The following statement is valid −

`x = 20.0`

The following statement is not valid. It would generate compile-time error −

`10 = 20`


