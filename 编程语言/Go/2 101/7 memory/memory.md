# 1 Memory Blocks

# 2 Memory Layouts

# 3 Memory Leaking

go支持垃圾回收，多数情况下不需要关心内存泄露，但也有些情况确实会导致内存泄露，需要引起重视。

## 3.1 Kind-Of Memory Leaking Casued By Substrings

substring操作引起的内存泄露，golang spec里面没有要求string的substring操作是否允许共用相同的存储空间，不过现在的golang runtime确实是允许的。下面举个substring操作导致的内存泄露操作。

### 3.1.1 内存泄露示例

```go
var s0 string  // 包级别变量
func f(s1 string) {
	// 假定s1是一个长度远远大于50的字符串
	s0 = s1[:50]
}
```

因为s1中的内部存储结构与s0共用了，导致函数f结束时，虽然s1作用域结束了，但是其对应的内存却不会被释放，需要等到s0重新赋值的时候才能被释放。这就泄露了s1对应的内存。

下面讲几个解决substring导致的内存泄露的方法。

### 3.1.2 避免内存泄露

**1）方法一**

先将对应的substring转换为[]byte，这里会拷贝一次，然后再转成string，这样substring与原string不共用相同的内置存储空间，避免了内存泄露。但是内存回收也不是立即就进行的，这里相当于多开辟了50byte的内存空间。

```go
func f(s1 string) {
	s0 = string([]byte(s1[:50]))
}
```

**2）方法二**

利用编译器的优化策略进行优化，避免内存拷贝。如果是字符串连接操作，并且其中一个是非空的字符串常量，那么将[]byte转换为string进行连接时这里的[]byte不会进行拷贝。下面的示例相当于只浪费了1byte的内存空间。

```go
func f(s1 string) {
	s0 = (" " + s1[:50])[1:]
}
```

>这里的编译器优化策略，在后续go编译器版本中可能会失效。

**3）方法三**

go1.10里面添加了`strings.Builder`，可以避免内存拷贝，缺点是写法上不够简练。

```go
import "strings"

func f(s1 string) {
	var b strings.Builder
	b.Grow(50)
	b.WriteString(s1[:50])
	s0 = b.String()
	// b.Reset() 	// if b is used elsewhere,
					// it must be reset here.
}
```

## 3.2 Kind-Of Memory Leaking Casued By Subslices

subslice操作导致的内存泄露，与substring操作十分类似。

### 3.2.1 内存泄露示例

```go
var s0 []int
func g(s1 []int) {
	s0 = s1[len(s1)-30:]
}
```

假定s1是一个长度很大的slice，那么函数g调用后，s0将引用s1这个slice的部分内置空间，导致s1无法被回收，有相当一部分内存空间相当于被泄露掉了。

### 3.2.2 避免内存泄露

下面的方法通过将s1中对应slice的元素追加到s0中，开销是30个int大小的内存空间，但是避免了s1被泄露。

```go
func g(s1 []int) {
	s0 = append([]int(nil), s1[len(s1)-30:]...)
}
```

## 3.3 Kind-Of Memory Leaking Casued By Not Resetting Pointers In Dead Slice Elements

## 3.4 Real Memory Leaking Casued By Hanging Goroutines





