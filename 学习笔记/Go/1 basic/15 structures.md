Go arrays allow you to define variables that can hold several data items of the same kind. **Structure** is another user-defined data type available in Go programming, which allows you to combine data items of different kinds.

Structures are used to represent a record. Suppose you want to keep track of the books in a library. You might want to track the following attributes of each book −

- Title
- Author
- Subject
- Book ID

In such a scenario, structures are highly useful.

# Defining a Structure

To define a structure, you must use **type** and **struct** statements. The struct statement defines a new data type, with multiple members for your program. The type statement binds a name with the type which is struct in our case. The format of the struct statement is as follows −

```go
type struct_variable_type struct {
   member definition;
   member definition;
   ...
   member definition;
}
```

Once a structure type is defined, it can be used to declare variables of that type using the following syntax.

`variable_name := structure_variable_type {value1, value2...valuen}`

# Accessing Structure Members

To access any member of a structure, we use the **member access operator (.)**. The member access operator is coded as a period between the structure variable name and the structure member that we wish to access. You would use struct keyword to define variables of structure type. The following example explains how to use a structure −

```go
package main

import "fmt"

type Books struct {
   title string
   author string
   subject string
   book_id int
}
func main() {
   var Book1 Books    /* Declare Book1 of type Book */
   var Book2 Books    /* Declare Book2 of type Book */
 
   /* book 1 specification */
   Book1.title = "Go Programming"
   Book1.author = "Mahesh Kumar"
   Book1.subject = "Go Programming Tutorial"
   Book1.book_id = 6495407

   /* book 2 specification */
   Book2.title = "Telecom Billing"
   Book2.author = "Zara Ali"
   Book2.subject = "Telecom Billing Tutorial"
   Book2.book_id = 6495700
 
   /* print Book1 info */
   fmt.Printf( "Book 1 title : %s\n", Book1.title)
   fmt.Printf( "Book 1 author : %s\n", Book1.author)
   fmt.Printf( "Book 1 subject : %s\n", Book1.subject)
   fmt.Printf( "Book 1 book_id : %d\n", Book1.book_id)

   /* print Book2 info */
   fmt.Printf( "Book 2 title : %s\n", Book2.title)
   fmt.Printf( "Book 2 author : %s\n", Book2.author)
   fmt.Printf( "Book 2 subject : %s\n", Book2.subject)
   fmt.Printf( "Book 2 book_id : %d\n", Book2.book_id)
}
```

When the above code is compiled and executed, it produces the following result −

```
Book 1 title      : Go Programming
Book 1 author     : Mahesh Kumar
Book 1 subject    : Go Programming Tutorial
Book 1 book_id    : 6495407
Book 2 title      : Telecom Billing
Book 2 author     : Zara Ali
Book 2 subject    : Telecom Billing Tutorial
Book 2 book_id    : 6495700
```

# Structures as Function Arguments

You can pass a structure as a function argument in very similar way as you pass any other variable or pointer. You would access structure variables in the same way as you did in the above example −

```go
package main

import "fmt"

type Books struct {
   title string
   author string
   subject string
   book_id int
}
func main() {
   var Book1 Books    /* Declare Book1 of type Book */
   var Book2 Books    /* Declare Book2 of type Book */
 
   /* book 1 specification */
   Book1.title = "Go Programming"
   Book1.author = "Mahesh Kumar"
   Book1.subject = "Go Programming Tutorial"
   Book1.book_id = 6495407

   /* book 2 specification */
   Book2.title = "Telecom Billing"
   Book2.author = "Zara Ali"
   Book2.subject = "Telecom Billing Tutorial"
   Book2.book_id = 6495700
 
   /* print Book1 info */
   printBook(Book1)

   /* print Book2 info */
   printBook(Book2)
}
func printBook( book Books ) {
   fmt.Printf( "Book title : %s\n", book.title);
   fmt.Printf( "Book author : %s\n", book.author);
   fmt.Printf( "Book subject : %s\n", book.subject);
   fmt.Printf( "Book book_id : %d\n", book.book_id);
}
```

When the above code is compiled and executed, it produces the following result −

```go
Book title     : Go Programming
Book author    : Mahesh Kumar
Book subject   : Go Programming Tutorial
Book book_id   : 6495407
Book title     : Telecom Billing
Book author    : Zara Ali
Book subject   : Telecom Billing Tutorial
Book book_id   : 6495700
```

# Pointers to Structures

You can define pointers to structures in the same way as you define pointer to any other variable as follows −

`var struct_pointer *Books`

Now, you can store the address of a structure variable in the above defined pointer variable. To find the address of a structure variable, place the & operator before the structure's name as follows −

`struct_pointer = &Book1;`

To access the members of a structure using a pointer to that structure, you must use the "." operator as follows −

`struct_pointer.title;`

>golang里面不管是通过struct value还是struct指针来访问成员，都通过成员访问修饰符(.)来访问，这与c、c++中又存在明显的不同，c、c++中struct value访问成员时通过(.)，struct指针则需通过(->)。

Let us re-write the above example using structure pointer −

```go
package main

import "fmt"

type Books struct {
   title string
   author string
   subject string
   book_id int
}
func main() {
   var Book1 Books   /* Declare Book1 of type Book */
   var Book2 Books   /* Declare Book2 of type Book */
 
   /* book 1 specification */
   Book1.title = "Go Programming"
   Book1.author = "Mahesh Kumar"
   Book1.subject = "Go Programming Tutorial"
   Book1.book_id = 6495407

   /* book 2 specification */
   Book2.title = "Telecom Billing"
   Book2.author = "Zara Ali"
   Book2.subject = "Telecom Billing Tutorial"
   Book2.book_id = 6495700
 
   /* print Book1 info */
   printBook(&Book1)

   /* print Book2 info */
   printBook(&Book2)
}
func printBook( book *Books ) {
   fmt.Printf( "Book title : %s\n", book.title);
   fmt.Printf( "Book author : %s\n", book.author);
   fmt.Printf( "Book subject : %s\n", book.subject);
   fmt.Printf( "Book book_id : %d\n", book.book_id);
}
```

When the above code is compiled and executed, it produces the following result −

```
Book title     : Go Programming
Book author    : Mahesh Kumar
Book subject   : Go Programming Tutorial
Book book_id   : 6495407
Book title     : Telecom Billing
Book author    : Zara Ali
Book subject   : Telecom Billing Tutorial
Book book_id   : 6495700
```

