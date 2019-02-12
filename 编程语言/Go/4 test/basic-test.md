# golang test

golang提供了内置的test、benchmark测试能力，学会使用golang的test、benchmark test以及养成良好的测试习惯，是能写出健壮、高效的golang程序的前提。

这里对golang中常用的test、benchmark test进行了简单的总结，demo就以示例代码和注释说明的方式来演示，常用自然会习以为常！

# testing.T

```go
package test

import (
	"testing"
	"fmt"
	"sync"
)

// golang相关工具的使用：https://tip.golang.org/cmd/go
//
// go help test
// go help testflag
//
// go test
// go test .
// go test math
// go test ./...
//
// non-cachable test : go test / or combined with other options
// cachable test : go test -cpu / -list / -parallel / -run / -short/ -v
//
// go test -vet=<list>, if list=off, go vet is disabled

// go test -short
//
// tell long-running tests to shorten their run time, it is off by default.
func TestSimpleTask(t *testing.T) {
	if testing.Short() {
		fmt.Println("short mode")
		t.Skip("short mode: skipping following statements")
	}
	fmt.Println("never reached")
}
```

# testing.B

```go
package test

import (
	"testing"
	"fmt"
	"sync"
)

// go test -bench=. -run=none -benchmem
//
// -bench=. : runs benchmarks under current package besides TestXxxx routines,
// -run=none : exclude the test routine `TestXxxx`, so as to run BenchmarkXxx only.
// -benchmem : stat the memory allocation times and number of bytes each iteration.
//
// note: you must run your target code b.N times.
type Any struct {
	name string
}

var pool = sync.Pool{New: func() interface{} {
	return &Any{}
}}

func BenchmarkPrint(b *testing.B) {

	mm := &Any{}
	for i := 0; i < b.N; i++ {
		mm = pool.Get().(*Any)
		pool.Put(mm)
	}
	_ = mm
}

func ExampleHello() {
	fmt.Println("hello")
	// Output: hello world
}

func ExampleHelloWorld() {
	fmt.Println("hello world")
	// Output: hello world
}

// sub-test and sub-benchmarking
//
// go test -run ''
// go test -run Foo
// go test -run Foo/A
// go test -run Foo/A=
// go test -run Foo/A=1
// go test -run Foo/B
func TestFoo(t *testing.T) {
	// <setup code>
	t.Run("A=1", func(t *testing.T) { fmt.Println("A=1") })
	t.Run("A=2", func(t *testing.T) { fmt.Println("A=2") })
	t.Run("B=1", func(t *testing.T) { fmt.Println("B=1") })
	// <tear-down code>
}

func BenchmarkFoo(b *testing.B) {
	// <setup code>
	b.Run("A=1", func(b *testing.B) { fmt.Println("A=1") })
	b.Run("A=2", func(b *testing.B) { fmt.Println("A=2") })
	b.Run("B=1", func(b *testing.B) { fmt.Println("B=1") })
	// <tear-down code>
}
```

# testing.M

TestMain可以对测试进行控制，借助TestMain我们可以做到如下4点，伪代码如下：

```go
func TestMain(m *testing.M) {
    setup()
    code := m.Run() 
    shutdown()
    os.Exit(code)
}
```

- Setup
- How and when to run the tests
- Shutdown
- Exit behavior

下面是一个测试示例，在Setup部分我们用来解析命令行选项配置，接下来测试的时候我们可以给go test传递命令行选项-verbose，如`go test -run=$yourTestCase -verbose=false`.

```go
var verbose = flag.Bool("verbose", true, "verbose")

func TestMain(m *testing.M) {
	flag.Parse()
	ret := m.Run()
	os.Exit(ret)
}
```

