Strings, which are widely used in Go programming, are a readonly slice of bytes. In the Go programming language, strings are slices. The Go platform provides various libraries to manipulate strings.

- unicode
- regexp
- strings

# Creating Strings

The most direct way to create a string is to write −

`var greeting = "Hello world!"`

Whenever it encounters a string literal in your code, the compiler creates a string object with its value in this case, "Hello world!'.

A string literal holds a valid UTF-8 sequences called runes. A String holds arbitrary bytes.

```go
package main

import "fmt"

func main() {
   var greeting =  "Hello world!"
   
   fmt.Printf("normal string: ")
   fmt.Printf("%s", greeting)
   fmt.Printf("\n")
   
   fmt.Printf("hex bytes: ")
   for i := 0; i < len(greeting); i++ {
       fmt.Printf("%x ", greeting[i])
   }
   fmt.Printf("\n")
   
   const sampleText = "\xbd\xb2\x3d\xbc\x20\xe2\x8c\x98" 
   /*q flag escapes unprintable characters, with + flag it escapses non-ascii 
   characters as well to make output unambigous */
   fmt.Printf("quoted string: ")
   fmt.Printf("%+q", sampleText)
   fmt.Printf("\n")  
}
```

This would produce the following result −

```go
normal string: Hello world!
hex bytes: 48 65 6c 6c 6f 20 77 6f 72 6c 64 21 
quoted string: "\xbd\xb2=\xbc \u2318"
```

**Note** − The string literal is immutable, so that once it is created a string literal cannot be changed.

# String Length

`len(str)` method returns the **number of bytes** contained in the string literal.

```go
package main

import "fmt"

func main() {
   var greeting =  "Hello world!"
   
   fmt.Printf("String Length is: ")
   fmt.Println(len(greeting))  
}
```

This would produce the following result −

`String Length is : 12`

# Concatenating Strings

The strings package includes a method join for concatenating multiple strings −

`strings.Join(sample, " ")`

Join **concatenates the elements of an array** to create a single string. Second parameter is **seperator** which is placed between element of the array.

Let us look at the following example −

```go
package main

import ("fmt" "math" )"fmt" "strings")

func main() {
   greetings :=  []string{"Hello","world!"}   
   fmt.Println(strings.Join(greetings, " "))
}
```

This would produce the following result −

`Hello world!`

