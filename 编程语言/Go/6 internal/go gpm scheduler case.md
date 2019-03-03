“**纸上得来终觉浅，绝知此事要躬行**”，相信很多人都听说过go runtime scheduler - G.P.M work-stealing scheduler，而且讲的头头是道，但是究竟理解多少呢，在实际工作中遇到相关问题又能否分析、定位准确，就又是另一回事了，“纸上谈兵”者自古有之，今天也一样。搞技术的，最好还是能够知根知底，别含糊。

举这么个示例，大家猜一猜输出结果会是什么。

```go
package main

import "sync"
import "fmt"
import "runtime"

func main() {
	runtime.GOMAXPROCS(1)
	wg := sync.WaitGroup{}
	wg.Add(10)
	
	for i := 0; i < 10; i++ {
		go func(i int) {
			fmt.Println("ii: ", i)
			wg.Done()
		}(i)
	}
	wg.Wait()
}
```

程序多次运行后，输出结果均如下：

```bash
ii: 9
ii: 0
ii: 1
ii: 2
ii: 3
ii: 4
ii: 5
ii: 6
ii: 7
ii: 8
```

为什么多次运行后的结果，结果都是一样的呢？按常理，多个goroutine被调度的顺序应该不是完全固定的，为什么执行顺序总是`9, 0, 1, 2, 3, …, 8`呢，好吧，可能是因为我们限制了`runtime.GOMAXPROCS(1)`的缘故，那么为什么总是先输出`9`呢，而后面的又是按照固定顺序`0, 1, 2, 3, …, 8`呢？

好吧，这是一个促使我们研究下go runtime scheduler的好例子。开始吧！

