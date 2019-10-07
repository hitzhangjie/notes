go flagset没有提供可以重复指定的选项类型，如`protoc --proto_path=dir1 --proto_path=dir2...`中的`--proto_path`选项，但是我们可以自定义这样的命令行选项。

下面是一个允许重复指定字符串选项`-list=xxx -list=yyy`的示例：


```go
package main

import "flag"

type arrayFlags []string

func (i *arrayFlags) String() string {
	return "my string representation"
}

func (i *arrayFlags) Set(value string) error {
	*i = append(*i, value)
	return nil
}

var myFlags arrayFlags

func main() {
	flag.Var(&myFlags, "list", "Some description for this param.")
	flag.Parse()
}
```

