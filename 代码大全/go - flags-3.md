今天写了个命令行工具，想支持子命令，比如 go build，针对build再提供对应的命令选项。

- 正常情况下flag.Parse()碰到不是`--flag`、`-f`这样的选项时就停止解析了。

- 如果子命令go build后面的选项列表包含了go test的选项，也确实不合理。

  

如何实现类似`go <subcmd> [option...]`命令这样为各个subcmd定制选项的能力呢？

1. 可以为每个子命令单独创建一个flag.FlagSet，先解析subcmd=os.Args[1]，比如是subcmd=build，再动态创建flagset，在flagset上创建subcmd对应的选项，比如flagset.Bool(.....)。

2. 最后再执行flagset的解析，flagset.Parse(os.Args[2：)。



有需要的可以这么尝试下，go这个命令也是这么实现的，也不用在github上淘奇奇怪怪的库。