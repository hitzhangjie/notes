go标准库支持命令行参数解析，支持多种类型的命令行参数，常见的就是int、string、bool，如下图所示：

```go
var age = flag.Int("age", 1000, "age")
var name = flag.String("name", "me", "name")
var handsome = flag.Bool("hansome", true, "hansome")
var married = flag.Bool("married", false, "married")

func init() {
    flag.Parse()
}

func main() {
    fmt.Printf("age=%v\n", *age)
    fmt.Printf("name=%s\n", *name)
    fmt.Printf("handsome=%v\n", *hansome)
    fmt.Printf("married=%v\n", *married)
}
```

使用还是比较简单的，但是要注意的是，go flag这个库对bool类型有特殊处理逻辑，首先我们`go build -o main main.go`完成编译，然后结合运行时指定参数来说明。

**对于int类型而言：**

- 如果运行`./main`，没有指定-age，则-age使用默认值1000；
- 如果运行`./main -age`，有指定-age但是没有指定值，此时会报错，提示参数usage信息；

**对于string类型而言：**

- 如果运行`./main`，没有指定-name，则-name使用默认值me；
- 如果运行`./main -name`，有指定-name但是没有指定值，此时会报错，提示参数usage信息；

string类型的处理与int类型是一样的，但是bool类型不一样！

**对于bool类型而言，不管flag.Bool()定义的时候指定的默认值是多少，都遵循如下处理逻辑：**

- 如果运行`./main`，没有指定-handsome/-married，则分别使用默认值true/false；
- 如果运行`./main -handsome`，-handsome的值为true；
- 如果运行`./main -married`，-married的值为？true！尽管默认值为false，记住是true！
- bool类型如果要赋值为false，对于默认值为false的-married参数，可以不指定-married或者指定married并设置为false（-married=false）；对于默认值为true的-handsome参数，只能通过-handsome=false来指定。

为什么要对bool类型进行特殊处理呢？为了方便使用！

比如程序运行期间打log，默认不打印详细日志，可以通过verbose来控制，并且默认值为false，但是当我指定-verbose的时候，内心里面是希望将其当做true来处理的。针对这个案例，实际应用中，可能很少会用到verbose=true/false这种用法，而对go flag的特殊处理逻辑，无疑是方便了我们的使用，更加符合大家的使用习惯。