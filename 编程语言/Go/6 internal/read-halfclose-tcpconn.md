先描述下要讨论、验证的问题场景：

1. tcpclient 发请求给tcpserver，然后1分钟没活动，tcpserver认为连接空闲close掉，这个时候会发fin包给tcpclient
2. tcpclient收到后认为tcpserver 写端关闭，仍然正常发包给tcpserver
3. tcpserver这个时候认为连接已关闭，发送rst给tcpclient。
4. tcpclient这个时候，假如发现接收socket缓冲里面还有数据没读完，这个时候还是可以read成功的，直到读取到EOF！

验证代码：

```go
// tcp从连接读数据，假如这个时候对端关闭这个连接，
// 关闭这个动作之前的数据还能否读到呢？测试验证下！
package main

import (
	"bufio"
	"io"
	"log"
	"net"
	"os"
	"time"
)

func main() {

	go startEndpointA()
	go startEndPointB()

	for {
		time.Sleep(time.Microsecond * 10)
	}
}

// read
func startEndpointA() {
	defer log.Println("kill A")

	addr := &net.TCPAddr{IP: net.IPv4(127, 0, 0, 1), Port: 8000}
	listener, err := net.ListenTCP("tcp", addr)
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
	defer listener.Close()

	for {
		conn, err := listener.AcceptTCP()
		if err != nil {
			log.Println(err)
			continue
		}

		go func(conn net.Conn) {
			defer conn.Close()

			r := bufio.NewReader(conn)
			buf := [128]byte{}

			time.Sleep(time.Second * time.Duration(6))

			idx := 0
			for {
				n, err := r.Read(buf[idx:])
				if err != nil {
					log.Println(err)
					if err == io.EOF {
						log.Println("read EOF")
					}
					break
				}
				log.Println("read", n, "bytes:", string(buf[idx:]))
				idx += n
			}
			log.Println("peer write end close")
			time.Sleep(time.Second)
			conn.Write([]byte("how are you"))
			log.Println("response done")

		}(conn)
	}
}

func startEndPointB() {
	defer recover()

	defer log.Println("kill B")
	raddr := &net.TCPAddr{IP: net.IPv4(127, 0, 0, 1), Port: 8000}

	conn, err := net.DialTCP("tcp", nil, raddr)
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}

	buf := []byte("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	len := len(buf)
	cnt := 0
	conn.SetWriteDeadline(time.Now().Add(time.Second * 10))

	step := 5

	tick := time.Tick(time.Second * time.Duration(3))

	for {
		select {
		case <-tick:
			conn.CloseWrite()
			return
		default:
		}
		n, err := conn.Write(buf[cnt : cnt+step])
		if err != nil {
			log.Println(err)
			os.Exit(1)
		}
		cnt += n
		log.Println("write", n, "bytes")

		if cnt == len {
			break
		}

		time.Sleep(time.Second)
	}
}
```

运行结果：

```bash
zhangjie@kn ~/Projects/Goland/LearnGo/src/tcpdump/tcp_read_eof $ go run main.go
2019/02/28 20:54:29 write 5 bytes
2019/02/28 20:54:30 write 5 bytes
2019/02/28 20:54:31 write 5 bytes
2019/02/28 20:54:32 kill B
2019/02/28 20:54:35 read 15 bytes: abcdefghijklmno
2019/02/28 20:54:35 EOF
2019/02/28 20:54:35 read EOF
2019/02/28 20:54:35 peer write end close
2019/02/28 20:54:36 response done
^Csignal: interrupt
```

上面的示例可以验证我们开始场景中的结论：

server端启动监听之后故意等待6s之后才read数据，client连接上之后立即发送数据给server，并且在3s的时候关掉与server的连接。server端6s后读取时仍然能够读取到数据`abcdefghijklmno`，然后再读取到连接关闭标识`EOF`。