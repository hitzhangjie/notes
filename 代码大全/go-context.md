请求上下文，通常包含了超时控制、传递的值这两个重要信息，请求上下文一般会沿着处理链路层层传递，当上下文取消或者超时时，整个处理链路被取消。golang中提供了context这个包，借助这个包可以很方便地实现上下文超时控制，它也提供了一个传值的能力，也可以拿来传递一些必要的信息。

下面是一个演示context通过cancel操作来通知其他goroutine结束执行的例子。

```go
func testContext() {

	// background context returns an empty context, it's empty!
	ctx := context.Background()
	if ctx.Done() == nil {
		fmt.Println("parent context done chan is nil")
	}
	//<- ctx.Done() // wouldn't block, emptyCtx returns nil

	ctx1, cancel := context.WithCancel(ctx)
	ch := make(chan int, 10)

	go func(ch chan int, ctx context.Context) {
		for {
			select {
			case <-ctx.Done():
				fmt.Println("ctx is cancelled")
				break
			default:
				fmt.Println("ctx is not cancelled")
				ch <- 1
			}
			time.Sleep(time.Second)
		}
	}(ch, ctx1)

	count := 0
	for v := range ch {
		fmt.Println(v)
		count++
		if count > 5 {
			break
		}
	}

	defer func() {
		cancel()
		time.Sleep(time.Second * 2)
	}()
}
```

