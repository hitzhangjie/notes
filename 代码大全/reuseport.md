```go
package network

import (
    "runtiem"
    "github.com/kavu/go_reuseport"
)

// golang标准库里面的net.Listen不支持端口重用，但是有些情况下我们有这样的使用场景，如
// goneat框架里面使用端口重用来增强udp服务在端口上的收发包能力，github上有多个开源项目
// 实现了端口重用，github.com/kavu/go_reuseport这个是比较精炼的一个！
func ReuseportListen(network, address string) {

    cpus := runtime.NumCPU()

	for i := 0; i < cpus; i++ {

		go func(idx int) {
			listener, err := reuseport.Listen(network, address)
			if err != nil {
				panic(err)
			}
			defer listener.Close()

			for {
				_, err := listener.Accept()
				if err != nil {
					panic(err)
				}
				fmt.Printf("listener:%v create conn\n", idx)
			}

		}(i)
	}

	select {}
}
```
