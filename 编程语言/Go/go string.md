# string为什么是utf8编码？

go源文件只能是utf8编码，因为源文件是utf8编码，源文件中的字符串本身肯定也是utf8编码后存储的。

程序编译的时候，会把这些utf8编码后的字符串数据存储起来。

# string中的字符与字节？

```go
var s := "你们好, friends"

// for range遍历的是“字符”
for _, c := range s {
  fmt.Printf("%c", c)
}
```

```go
var s := "你们好, friends"

// len(s)取的是slice的长度，通过索引方式遍历的是byte
for i:=0; i<len(s); i++ {
  fmt.Printf("%c", s[i])
}
```

