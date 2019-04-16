通常我们会在main package里面定义所有的flag，然后在其他的package里面引用，这样有个好处，就是所有的flag选项都在同一个地方定义，比分散到多个package里面定义要清晰。

如：

```go
var protodir = flag.String("protodir", ".", "protobuf file dir, please config ${GONEAT_TPL_ASSET_DIR}")
var protofile = flag.String("protofile", "any.proto", "protobuf filename")
var protocol = flag.String("protocol", "nrpc", "nrpc, simplesso, ilive")
var assetdir = flag.String("assetdir", "", "template asset dir")
var verbose = flag.Bool("verbose", false, "verbose logging info")
var httpon = flag.Bool("httpon", false, "enable http mode")

func init() {
	flag.Parse()
}

func main() {
    ...
}
```

但是当我想在其他的package里面引用上述flag的时候该怎么获取呢？也许可以将其定义为export variable。

这样就可以了吗？貌似也不行，假如定义成到处变量，访问这些变量的时候意味着其他package要import main！而通常main也会import其他package，假如存在环形依赖，编译的时候会报错！那怎么办呢？

假如有个包`package log`，在这个包里面向获取`package main`里面定义的flag verbose，我们可以根据flag verbose的类型信息这样获取其值，如：

```go
package log

func getVerboseFlag() bool {
	if f := flag.Lookup("verbose"); f == nil {
		return false
	} else {
		return f.Value.(flag.Getter).Get().(bool)
	}
}
```

