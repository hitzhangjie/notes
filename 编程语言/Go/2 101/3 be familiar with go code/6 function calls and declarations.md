# Function Declarations And Calls

- Function calls can be deferred and invoked in new goroutines (green threads) in Go.  [go101.org]
- In Go, each function call has an exiting phase.

> golang里面可以每个func都有一个exit阶段，在这个阶段defer入栈的函数将被按照LIFO的顺序依次被调用。这个exit阶段进入之前，函数的返回值就已经设置好了，但是如果函数返回值是有名变量的话，defer函数里面依然可以对其进行修改。 比如如下示例函数：  

```go
func testDefer() (n int) { 	
    defer func() { 		
        fmt.Println(n) 		
        n = 2 	
     }()
    return 1; 
}
```

- Go support anonymous functions.  [go101.org]
- There are some built-in functions in Go, for example, the println and print functions. We can call these functions without importing any packages.  [go101.org]