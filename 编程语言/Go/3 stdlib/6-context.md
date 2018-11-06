# 6 context

package context defines the Context type, which carries **deadlines, cancelation signals, and other request-scoped values** across API boundaries and between processes.

it is very useful to control the cancellation of flow based on deadline, timeout, it can also be used for passing parameters.

following is an example showing how to use context with deadline, timeout, cancel and value.

## 6.1 context.WithDeadline

```go
func testCtxWithDeadline() {

	if len(os.Args) < 2 {
		fmt.Println("./main <url>")
		os.Exit(1)
	}
	// test with dealine
	ctx, cancel := context.WithDeadline(context.Background(), time.Now().Add(time.Second*2))
	defer cancel()

	ok := make(chan int)

	go wget(ctx, os.Args[1], ok)

	select {
	case <-ctx.Done():
		fmt.Println(ctx.Err())
	case <-ok:
		fmt.Println("wget success")
	}
}

// utiliy function
func wget(ctx context.Context, url string, ok chan<- int) {
	rsp, err := http.Get(url)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(rsp)
	ok <- 1
}

// utility function
func doSomething(ctx context.Context, ok chan int) {
	fmt.Println("get value from ctx:", ctx.Value("msg"))
	close(ok)
}
```

## 6.2 context.WithTimeout

```go
func testCtxWithTimeout() {
	if len(os.Args) < 2 {
		fmt.Println("./main <url>")
		os.Exit(1)
	}
	// test with dealine
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*2)
	defer cancel()

	ok := make(chan int)

	go wget(ctx, os.Args[1], ok)

	select {
	case <-ctx.Done():
		fmt.Println(ctx.Err())
	case <-ok:
		fmt.Println("wget success")
	}
}
```

## 6.3 context.WithCancel

```go
func testCtxWithCancel() {
	if len(os.Args) < 2 {
		fmt.Println("./main <url>")
		os.Exit(1)
	}
	// test with dealine
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*2)
	ctx1, _ := context.WithCancel(ctx)

	defer cancel()

	select {
	case <-time.After(time.Second * 1):
		fmt.Println("timeout 1s")
		cancel()
	}

	ok := make(chan int)
	go wget(ctx1, os.Args[1], ok)

	select {
	case <-ctx.Done():
		fmt.Println(ctx.Err())
	case <-ok:
		fmt.Println("wget success")
	}
}
```

## 6.4 context.WithValue

```go
func testCtxWithValue() {

	ctx := context.WithValue(context.Background(), "msg", "hello world")

	ok := make(chan int)
	go doSomething(ctx, ok)

	select {
	case <-ctx.Done():
		fmt.Println(ctx.Err())
	case <-ok:
		fmt.Println("do something success")
	}
}

```

