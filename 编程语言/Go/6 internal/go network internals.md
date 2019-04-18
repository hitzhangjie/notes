# Preface

golang里面针对一个closed tcpconn执行写操作，可能会有不同的表现，先描述下场景，client通过连接池访问server：

- 假如server认为连接空闲，执行conn.Close()，此时client端写一次，再写一次，此时会报broken pipe；
- 假如server认为连接空间，执行conn.Close()，此时server端写一次或多次，此时会报use closed network connection；

第一种场景之前我们分析过了，client写第一次，server会FIN或RST，client刚刚感知到连接销毁，但是上层应用还没有调用conn.Close()对conn对应的fd进行销毁（详见下文How go handle conn.Closed()部分的mutexClosed标记位），第二次写会直接走到syscall.Write(...)返回EPIPE，上层表现就是err.Error()返回errors[EPIPE] = “broken pipe”；

第二种场景之前遇到过，但是没有仔细分析过，执行conn.Close()会对fd进行销毁，如fd的mutexClosed标记位，这时候fd已经无效了，上层应用下次conn.Write(...)的时候可以直接检测到此标记位的变化，返回错误信息use of closed connection，根本不会走到下层系统调用syscall.Write(...)的部分。

简言之就是，use of closed connection是显示地调用了conn.Close()销毁连接同时销毁fd，broken pipe则是操作系统执行实际发包逻辑协议栈发现连接已销毁，再返回给上层syscall.EPIPE错误码。

另外，golang里面对SIGPIPE信号进行了特殊处理，尽可能避免服务端因为write closed tcpconn这种情况挂掉的情况.

***signal/doc.go***

```go
SIGPIPE

When a Go program writes to a broken pipe, the kernel will raise a
SIGPIPE signal.

If the program has not called Notify to receive SIGPIPE signals, then
the behavior depends on the file descriptor number. A write to a
broken pipe on file descriptors 1 or 2 (standard output or standard
error) will cause the program to exit with a SIGPIPE signal. A write
to a broken pipe on some other file descriptor will take no action on
the SIGPIPE signal, and the write will fail with an EPIPE error.

If the program has called Notify to receive SIGPIPE signals, the file
descriptor number does not matter. The SIGPIPE signal will be
delivered to the Notify channel, and the write will fail with an EPIPE
error.

This means that, by default, command line programs will behave like
typical Unix command line programs, while other programs will not
crash with SIGPIPE when writing to a closed network connection.

```

其实上面use of closed network connection也是一种在连接关闭时避免写操作的情况，也避免了SIGPIPE而挂掉的场景，这么做的最大好处可能还是无需进入内核。

下面结合go源码简单分析了下：

- go是如何处理错误码EPIPE+SIGPIPE的？
- go是如何处理tcpconn.Write()的？
- go是如何处理tcpconn.Closed()的？

感兴趣的话，源码摘录部分是按照源码的关键执行流程进行摘录的，最好结合源码+跳转进行阅读。

# How go handle SIGPIPE？

***file_unix.go***

```go
// epipecheck raises SIGPIPE if we get an EPIPE error on standard
// output or standard error. See the SIGPIPE docs in os/signal, and
// issue 11845.
func epipecheck(file *File, e error) {
    // 如果write pipe时操作系统返回错误EPIPE，libc库会直接给进程发送SIGPIPE信号，
    // go比较特殊，针对现实应用场景做了些优化：
    // - 对于命令行程序可能会读写stdout/stderr，如果是写这个出现EPIPE，就挂掉进程，
    // - 如果是一个网络服务，写closed tcpconn返回EPIPE，如果直接发送SIGPIPE给进程，进程默认就挂了，
    //   go考虑到了这点，这种情况下write tcpconn操作会返回error：broken pipe，而不是发SIGPIPE。
    if e == syscall.EPIPE && file.stdoutOrErr {
       sigpipe()
    }
}
```

***file_posix.go***

```go
func sigpipe() // implemented in package runtime
```

***signal_unix.go***

```go
// sigpipe 先尝试将SIGPIPE发送给程序signal.Notify(ch,...)指定的chan，如果屏蔽了该信号的接收，
// 或者signal.Notify(ch, signals...)未指定SIGPIPE，则直接挂掉进程
func sigpipe() {
    if sigsend(_SIGPIPE) {
       return
    }
    dieFromSignal(_SIGPIPE)
}

// sigsend delivers a signal from sighandler to the internal signal delivery queue.
// It reports whether the signal was sent. If not, the caller typically crashes the program.
// It runs from the signal handler, so it's limited in what it can do.
func sigsend(s uint32) bool {
    // 如果信号被屏蔽，或者信号没有通过Notify接收，返回发送失败
	if !sig.inuse || s >= uint32(32*len(sig.wanted)) {
		return false
	}

	// Add signal to outgoing queue.
	...

	// Notify receiver that queue has new bit.
Send:
	...
	return true
}
```



# How go handle tcpconn.Write()?

***file.go***

```go
// Write writes len(b) bytes to the File.
// It returns the number of bytes written and an error, if any.
// Write returns a non-nil error when n != len(b).
func (f *File) Write(b []byte) (n int, err error) {
	if err := f.checkValid("write"); err != nil {
		return 0, err
	}
    // 执行数据写操作
	n, e := f.write(b)
	if n < 0 {
		n = 0
	}
	if n != len(b) {
		err = io.ErrShortWrite
	}
	// 执行错误检查，检查系统调用是否返回了syscall.EPIPE，本文最开始介绍了epipecheck，则没有Notify收信号处理情况下：
    // - 如果f是stdout、stderr，则进程直接挂掉；
    // - 如果f不是stdout、stderr，则这里返回error：broken pipe！
	epipecheck(f, e)

	if e != nil {
		err = f.wrapErr("write", e)
	}

	return n, err
}
```

***file_unix.go***

```go
// write writes len(b) bytes to the File.
// It returns the number of bytes written and an error, if any.
func (f *File) write(b []byte) (n int, err error) {
	n, err = f.pfd.Write(b)
	runtime.KeepAlive(f)
	return n, err
}
```

***fd_unix.go***

```go
// Write implements io.Writer.
func (fd *FD) Write(p []byte) (int, error) {
    // 通过tcp连接执行写操作前，先尝试独占fd，保证当前要写的数据p []byte能连续地写出去，
    // syscall.Write(fd, p)不一定能一次性全写出（考虑tcp发送缓冲），这里要抢fd写锁！
	// 如果抢失败，表名什么呢？看下这个方法实现！
	if err := fd.writeLock(); err != nil {
		return 0, err
	}
	defer fd.writeUnlock()
	if err := fd.pd.prepareWrite(fd.isFile); err != nil {
		return 0, err
	}
	var nn int
	for {
		max := len(p)
		if fd.IsStream && max-nn > maxRW {
			max = nn + maxRW
		}
        // fd有效，进入到操作系统系统调用，执行实际的数据写操作，如果发现tcpconn或者文件流关闭，
        // 操作系统会返回错误码syscall.EPIPE，go里面syscall.Write()返回对应的error：broken pipe！
		n, err := syscall.Write(fd.Sysfd, p[nn:max])
		if n > 0 {
			nn += n
		}
		if nn == len(p) {
			return nn, err
		}
		if err == syscall.EAGAIN && fd.pd.pollable() {
			if err = fd.pd.waitWrite(fd.isFile); err == nil {
				continue
			}
		}
		if err != nil {
			return nn, err
		}
		if n == 0 {
			return nn, io.ErrUnexpectedEOF
		}
	}
}
```

***fd_mutex.go***

```go
// writeLock adds a reference to fd and locks fd for writing.
// It returns an error when fd cannot be used for writing.
func (fd *FD) writeLock() error {
    // 如果加锁失败返回了错误，返回error只有一种情况，那就是fd被关闭了
	if !fd.fdmu.rwlock(false) {
		return errClosing(fd.isFile)	
	}
	return nil
}

// lock adds a reference to mu and locks mu.
// It reports whether mu is available for reading or writing.
func (mu *fdMutex) rwlock(read bool) bool {
	var mutexBit, mutexWait, mutexMask uint64
	var mutexSema *uint32
	if read {						// 读锁相关
		...
	} else {						// 写锁相关
		mutexBit = mutexWLock
		mutexWait = mutexWWait
		mutexMask = mutexWMask
		mutexSema = &mu.wsema
	}
	for {							// 自旋方式加锁
		old := atomic.LoadUint64(&mu.state)
		if old&mutexClosed != 0 {	// fd已经关闭的标识mutexClosed
			return false
		}
		var new uint64
		if old&mutexBit == 0 {		// 期望加锁L，没有人持有该锁，尝试获取锁
			// Lock is free, acquire it.
			new = (old | mutexBit) + mutexRef
			...
		} else {					// 期望加锁L，被他人持有了，等待锁被释放
			// Wait for lock.
			new = old + mutexWait
			...
		}
        // CAS的方式尝试去获取锁，成功则返回true，失败等待下次获取
		if atomic.CompareAndSwapUint64(&mu.state, old, new) {
			if old&mutexBit == 0 {
				return true
			}
			runtime_Semacquire(mutexSema)
			// The signaller has subtracted mutexWait.
		}
	}
}
```

***fd.go***

```go
// ErrNetClosing is returned when a network descriptor is used after
// it has been closed. Keep this string consistent because of issue
// #4373: since historically programs have not been able to detect
// this error, they look for the string.
var ErrNetClosing = errors.New("use of closed network connection")

// ErrFileClosing is returned when a file descriptor is used after it
// has been closed.
var ErrFileClosing = errors.New("use of closed file")

// Return the appropriate closing error based on isFile.
func errClosing(isFile bool) error {
	if isFile {
		return ErrFileClosing
	}
	return ErrNetClosing
}
```

***syscall_unix.go***

```go
func Write(fd int, p []byte) (n int, err error) {
	if race.Enabled {
		race.ReleaseMerge(unsafe.Pointer(&ioSync))
	}
	n, err = write(fd, p)
	if race.Enabled && n > 0 {
		race.ReadRange(unsafe.Pointer(&p[0]), n)
	}
	if msanenabled && n > 0 {
		msanRead(unsafe.Pointer(&p[0]), n)
	}
	return
}
```

***zsyscall_linux_amd64.go***

```go
// THIS FILE IS GENERATED BY THE COMMAND AT THE TOP; DO NOT EDIT

func write(fd int, p []byte) (n int, err error) {
	var _p0 unsafe.Pointer
	if len(p) > 0 {
		_p0 = unsafe.Pointer(&p[0])
	} else {
		_p0 = unsafe.Pointer(&_zero)
	}
    //执行系统调用，会返回对应的错误码信息Errno，如EPIPE=0x20
	r0, _, e1 := Syscall(SYS_WRITE, uintptr(fd), uintptr(_p0), uintptr(len(p)))
	n = int(r0)
	if e1 != 0 {
		err = errnoErr(e1)
	}
	return
}
```

***syscall_unix.go***

```go
func Syscall(trap, a1, a2, a3 uintptr) (r1, r2 uintptr, err Errno)

// Errno最终打印出来的错误码描述信息是存储在一个map里面，即errors
var errors = [...]string{
    ...
    32 : "broken pipe",		// Write Closed Pipe
    ...
}

func (e Errno) Error() string {
	if 0 <= int(e) && int(e) < len(errors) {
		s := errors[e]
		if s != "" {
			return s
		}
	}
	return "errno " + itoa(int(e))
}
```



# How go handle  conn.Close()?

***fd_unix.go***

```go
// Close closes the FD. The underlying file descriptor is closed by the
// destroy method when there are no remaining references.
func (fd *FD) Close() error {
	if !fd.fdmu.increfAndClose() {
		return errClosing(fd.isFile)
	}

	// Unblock any I/O.  Once it all unblocks and returns,
	// so that it cannot be referring to fd.sysfd anymore,
	// the final decref will close fd.sysfd. This should happen
	// fairly quickly, since all the I/O is non-blocking, and any
	// attempts to block in the pollDesc will return errClosing(fd.isFile).
	fd.pd.evict()

	// The call to decref will call destroy if there are no other
	// references.
	err := fd.decref()

	...

	return err
}

// Shutdown wraps the shutdown network call.
func (fd *FD) Shutdown(how int) error {
	if err := fd.incref(); err != nil {
		return err
	}
	defer fd.decref()
	return syscall.Shutdown(fd.Sysfd, how)
}
```

***fd_mutex.go***

```go
// increfAndClose sets the state of mu to closed.
// It returns false if the file was already closed.
func (mu *fdMutex) increfAndClose() bool {
	for {
		old := atomic.LoadUint64(&mu.state)
        if old&mutexClosed != 0 {						// close()同一个fd不止一次，报错
			return false
		}
		// Mark as closed and acquire a reference.
		new := (old | mutexClosed) + mutexRef			// 标记fdMutex状态为mutexClosed，可据此判断fd关闭了
		...
		// Remove all read and write waiters.
		new &^= mutexRMask | mutexWMask
		if atomic.CompareAndSwapUint64(&mu.state, old, new) {
			// Wake all read and write waiters,
			// they will observe closed flag after wakeup.
           	...
			return true
		}
	}
}

// decref removes a reference from fd.
// It also closes fd when the state of fd is set to closed and there
// is no remaining reference.
func (fd *FD) decref() error {
	if fd.fdmu.decref() {
		return fd.destroy()
	}
	return nil
}
```

