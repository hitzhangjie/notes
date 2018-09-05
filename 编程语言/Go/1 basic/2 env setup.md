# Local Environment Setup

If you are still willing to set up your environment for Go programming language, you need the following two software available on your computer −

- A text editor
- Go compiler

# Text Editor

You will require a text editor to type your programs. Examples of text editors include Windows Notepad, OS Edit command, Brief, Epsilon, EMACS, and vim or vi.

The name and version of text editors can vary on different operating systems. For example, Notepad is used on Windows, and vim or vi is used on Windows as well as Linux or UNIX.

The files you create with the text editor are called source files. They contain program source code. The source files for Go programs are typically named with the extension ".go".

Before starting your programming, make sure you have a text editor in place and you have enough experience to write a computer program, save it in a file, compile it, and finally execute it.

# The Go Compiler

The source code written in source file is the human readable source for your program. It needs to be compiled and turned into machine language so that your CPU can actually execute the program as per the instructions given. The Go programming language compiler compiles the source code into its final executable program.

Go distribution comes as a binary installable for FreeBSD (release 8 and above), Linux, Mac OS X (Snow Leopard and above), and Windows operating systems with 32-bit (386) and 64-bit (amd64) x86 processor architectures.

The following section explains how to install Go binary distribution on various OS.

# Download Go Archive

Extract the download archive into the folder /usr/local, creating a Go tree in /usr/local/go. 

For example : ```tar -C /usr/local -xzf go1.4.linux-amd64.tar.gz```.

Add /usr/local/go/bin to the PATH environment variable.

For example : ```export PATH=$PATH:/usr/local/go/bin```

# Verifying the Installation

Create a go file named test.go in your workspace.

## File : test.go

```go
package main

import "fmt"

func main() {
   fmt.Println("Hello, World!")
}
```

test and run : ```go run test.go```

##  output

```Hello, World!```


