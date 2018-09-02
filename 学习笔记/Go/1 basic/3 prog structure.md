Before we study the basic building blocks of Go programming language, let us first discuss the bare minimum structure of Go programs so that we can take it as a reference in subsequent chapters.

# Hello World Example

A Go program basically consists of the following parts −

- Package Declaration
- Import Packages
- Functions
- Variables
- Statements and Expressions
- Comments

Let us look at a simple code that would print the words "Hello World" −

```go
package main

import "fmt"

func main() {
   /* This is my first sample program. */
   fmt.Println("Hello, World!")
}
```

Let us take a look at the various parts of the above program −

- The first line of the program package main defines the package name in which this program should lie. It is a mandatory statement, as Go programs run in packages. The main package is the starting point to run the program. Each package has a path and name associated with it.
- The next line import "fmt" is a preprocessor command which tells the Go compiler to include the files lying in the package fmt.
- The next line func main() is the main function where the program execution begins.
- The next line /*...*/ is ignored by the compiler and it is there to add comments in the program. Comments are also represented using // similar to Java or C++ comments.
- The next line fmt.Println(...) is another function available in Go which causes the message "Hello, World!" to be displayed on the screen. Here fmt package has exported Println method which is used to display the message on the screen.
- Notice the capital P of Println method. In Go language, a name is exported if it starts with capital letter. Exported means the function or variable/constant is accessible to the importer of the respective package.

# Executing a Go Program

Let us discuss how to save the source code in a file, compile it, and finally execute the program. Please follow the steps given below −

- Open a text editor and add the above-mentioned code.
- Save the file as hello.go
- Open the command prompt.
- Go to the directory where you saved the file.
- Type go run hello.go and press enter to run your code.

If there are no errors in your code, then you will see "Hello World!" printed on the screen.

```
$ go run hello.go
Hello, World!
```

Make sure the Go compiler is in your path and that you are running it in the directory containing the source file hello.go. 

