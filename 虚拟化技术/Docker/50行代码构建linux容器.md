Linux操作系统通过namespace对操作系统资源进行隔离，容器技术的底层技术支撑正是Linux的namespace！

学习golang的时候无意中接触到了一个视频教程 [Building a container from scratch in Go](https://www.youtube.com/watch?v=Utf-A4rODH8)，因为最近也对容器技术非常感兴趣，所以就学习了一下，使用go语言可以50行代码左右构建一个linux容器，个人觉得很有趣，这里总结下。

50行go代码（不包括注释）从零开始构建一个linux容器：

```go
package main

import (
	"fmt"
	"os"
	"os/exec"
	"syscall"
)

// go run main.go run cmd args
func main() {
	switch os.Args[1] {
	case "run":
		run()
	case "child":
		child()
	default:
		panic("what??")
	}
}

func run() {
	cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID,
	}
	must(cmd.Run())
}

func child() {
	fmt.Printf("running %v as pid:%v\n", os.Args[2:], os.Getpid())
	cmd := exec.Command(os.Args[2], os.Args[3:]...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.SysProcAttr = &syscall.SysProcAttr{
		// uts名字空间，隔离nodename和domainname
		// pid名字空间，隔离进程号
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID,
	}
	// mkdir /home/rootfs
	// cd /home/rootfs
	// cp -r /bin /dev /etc/ /lib /lib64 /sbin /usr /var ./
	// mkdir -p proc/self
	must(syscall.Chroot("/home/rootfs"))
	must(syscall.Chdir("/"))
	must(syscall.Mount("proc", "proc", "proc", 0, ""))
	must(cmd.Run())
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
```

上述代码利用了两个linux namespace，UTS来隔离nodename和domainname，PID来隔离进程pid空间。然后利用chroot切换rootfs并重新挂载proc虚拟文件系统，就这么几个简单的操作就实现了一个简单的linux容器。当然了这个里的示例代码只是一个容器技术实现的雏形，没有对容器进行资源限制、安全限制等等，但是它仍然是一个不错的介绍容器技术的示例demo。