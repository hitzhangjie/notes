go里面因为某些异常导致程序panic的时候，如果只是recover捕获panic并没有特别大的意义，重要的是把panic的原因给暴露给开发者，在捕获panic的时候可以同时将panic信息以及具体的调用栈给打印出来。

```go
var RecoverStackSize 1024

go func() {
    defer func() {
       if e := recover(); e != nil {
          buf := make([]byte, RecoverStackSize)
          buf = buf[:runtime.Stack(buf, false)]
          log.Println("err:%v, call stack:%s", e, string(buf))
       }
    }
    ....
    panic("fatal error")
}()
```

j