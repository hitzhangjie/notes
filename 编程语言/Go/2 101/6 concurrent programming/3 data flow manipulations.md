# Data Flow Manipulations

这一部分介绍一些数据流操作示例，实践中存在很多数据流处理的场景，例如消息队列（发布、订阅），大数据处理（map、reduce）、负载均衡、作业拆分等等。

通常，一个数据流应用程序包括了很多模块，不同的模块负责拥有不同的职能，每一个模块可能都包括了一个worker组（这里的worker指的是goroutine），这些worker并发执行来处理模块任务。

下面给出了实践中一个数据流系统通常包括的模块作业：

- data generation/collecting/loading
- data serving/saving
- data calculation/analyzation
- data validation/filtering
- data aggregation/division
- data composition/decomposition
- data duplication/proliferation

模块既可能从其他模块接收数据，也可能向其他模块输出数据。也就是说，模块既可以是数据的消费者也可以是数据的生产者。如果一个模块只从其他块接收数据，那这个模块是consumer-only模块；如果一个模块只向其他模块输出数据，那这个模块是producer-only模块。

很多模块组合在一起就构成了一个数据流系统。

下面将给出一些数据流模块worker实现，这些实现它们可能既不高效也不灵活，仅用于教学目的。

## 1 data generating/collecting/loading

对于数据流系统中的producer-only模块，它们会数据流并输出给其他模块，这里的数据流可能：

- 通过文件加载、数据库加载，或者网络爬虫；
- 通过数据采集收集各种各样的硬件指标；
- 通过随机数生成器；
- 其他；
  这里我们使用一个随机数生成器来模拟一个producer-only模块，示例代码如下：

```go
func RandomGenerator() <-chan uint64 {
    c := make(chan uint64)
    go func() {
        rnds := make([]byte, 8)
        for {
            _, err := rand.Read(rnds)
            if err != nil {
                close(c)
            }
            c <- binary.BigEndian.Uint64(rnds)
        }
    }()
    return c
}
```

一个data producer可能会经过一段时间后就停止数据生成，或者不停生成，或者周期性生成。

## 2 data aggregation

一个数据聚合模块将来自多个不同模块的数据流聚合到同一个数据流里面，处理的多个数据流实现相同类型的。

示例代码如下：

```go
func Aggregator(inputs ...<-chan uint64) <-chan uint64 {
    output := make(chan uint64)
    for _, in := range inputs {
        in := in // this line is important
        go func() {
            for {
                x, ok := <-in
                if ok {
                    output <- x
                } else {
                    close(output)
                }
            }
        }()
    }
    return output
}
```

## 3 data division

一个数据拆分模块做的工作与data aggregation（数据汇总模块）干的活完全是相反的，它将同一个数据流拆分成多个不同的数据流。

示例代码如下：

```go
func Divisor(input <-chan uint64, outputs ...chan<- uint64) {
    for _, out := range outputs {
        out := out // this line is important
        go func() {
            for {
                out <- <-input // >=> out <- (<-input)
            }
        }()
    }
}
```

## 4 data composition

数据组合类似于数据聚合，只不过处理的数据类型不是相同类型的，而数据聚合处理的数据类型是相同的。

下面是是个示例，将两个数据流中的数据加工一下，将分属于两个数据流的uint64数组计算得到一个新数字写入最终的数据流。

```go
func Composor(inA <-chan uint64, inB <-chan uint64) <-chan uint64 {
    output := make(chan uint64)
    go func() {
        for {
            a1, b, a2 := <-inA, <-inB, <-inA
            output <- a1 ^ b &amp; a2
        }
    }()
    return output
}
```

## 5 data decomposition

数据取消组合操作，与4中描述的数据组合操作是完全相反的操作。示例代码略。

## 6 data duplication/proliferation

数据复制（激增）操作，是将一个数据流中的数据复制一份，然后写到不同的数据流中。

下面是一个示例：

```go
func Duplicator(in <-chan uint64) (<-chan uint64, <-chan uint64) {
    outA, outB := make(chan uint64), make(chan uint64)
    go func() {
        for {
            x := <-in
            outA <- x
            outB <- x
        }
    }()
    return outA, outB
}
```

## 7 data calculation/analyzation

数据计算模块、数据分析模块是将一种形式的数据流转换成另一种形式，然后输出到输出数据流。

这里的转换过程与具体的计算、分析任务息息相关。下面举个例子，将一个数据流中的数字bit求反，示例代码如下：

```go
func Calculator(input <-chan uint64) (<-chan uint64) {
    output := make(chan uint64)
    go func() {
        for {
            x := <-input
            output <- ^x
        }
    }()
    return output
}
```

## 8 data validation/filtering

数据验证模块、数据过滤模块，是对数据流中的数据进行校验，将不符合条件的数据丢弃。

如下示例代码中将数据流中的不是素数的数字丢弃，示例代码如下：

```go
func Filter(input <-chan uint64) (<-chan uint64) {
    output := make(chan uint64)
    go func() {
        bigInt := big.NewInt(0)
        for {
            x := <-input
            bigInt.SetUint64(x)
            if bigInt.ProbablyPrime(1) {
                output <- x
            }
        }
    }()
    return output
}
```

## 9 data serving/saving

数据serving、saving模块，往往是整个数据流系统中的最后一个模块。

下面这个示例只是打印出输入数据流中的数据，示例代码如下：

```go
func Printer(input <-chan uint64) {
    for {
        x, ok := <-input
        if ok {
            fmt.Println(x)
        } else {
            return
        }
    }
}
```

## 10 data flow system assembling

将上述模块组装成一个完整的数据流系统，就是创建每个数据流模块的worker实例，并为每个worker实例指定输入流、输出流。

```go
func main() {
    Printer(
        Filter(
            Calculator(
                RandomGenerator(),
            ),
        ),
    )
}
```

这样就构建了一个完整的数据流系统：RandomGenerator -> Calculator -> Filter -> Printer，当然还可以组件出一个更加复杂拓扑结构的数据流系统，这里就不介绍了。

