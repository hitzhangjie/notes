go里面的package time可以对日期时间进行操作，如将一个字符串形式的日期时间转换成time.Time，可以采用方法`time.Parse(layout, value string) (Time, error)`这里go的实现非常有趣，它为了纪念go的诞生，这里的layout必须采用“**2006-01-02 15:04:05**”或者“**2006-01-02 03:04:05**”，否则会导致解析失败。

首先来看一个解析的示例代码：

```go
func TestDateParse(t *testing.T) {

	t1 := time.Date(2018, time.April, 26, 12, 16, 50, 0, time.UTC)
	fmt.Println(t1)

	layout := "2006-01-02 15:04:05"
	t2, _ := time.Parse(layout, t1.Format(layout))
	fmt.Println(t2)

	xxxxx := "2006-03-02 01:04:05"
	t2, _ = time.Parse(xxxxx, t2.Format(layout))
	fmt.Println(t2)

	yyyyy := "2006-05-02 03:04:01"
	t2, err := time.Parse(yyyyy, t2.Format(layout))
	fmt.Println(err)
}
```

执行命令: `go test -run DateParse`

执行结果:

```sh
2018-04-26 12:16:50 +0000 UTC
2018-04-26 12:16:50 +0000 UTC
2018-12-26 04:16:50 +0000 UTC
parsing time "2018-12-26 04:16:50": month out of range
PASS
ok      _/E_/Gogland/LearnGo    0.203s
```

为什么会出现这样的问题呢？实现`time.Parse`的时候埋了一个“彩蛋”，如果layout没有定义成指定的格式，或者将06、01、02、03（也可以用15）、04、05交换顺序，则解析出来的时间是错误的，甚至会出现上述示例中“***month out of range***”的错误，是不是很奇怪？

其实这里并没有什么“彩蛋”，这里的数字06、01、02、03(15)、04、05也并非所谓的go诞生日时间，而只是程序员有意选择的一串数字，只不过在解析layout的过程中赋予了它们特定的含义，如：

- 06，年
- 01，月
- 02，日
- 03（15），时
- 04，分
- 05，秒

以上面的示例程序为例，当layout定义成错误的“2006-05-02 03:04:01”时，解析时间“2018-4-26 12:16:50”，layout中“05”会取“秒”的值，对应着50，但是50并不是一个有效的月份1~12，所以报错“month out of range”。

这里仔细一想，为什么layout不用“yyyy-MM-dd hh:mm:ss”这种更加常见的形式呢？确实，这里的time.Parse(layout, value)实现也确实遭到了很多人的非议，不过联想到萌萌的gopher，采用这个解析思路的同学，顿时感觉他也很萌呢！使用习惯了觉得这也算是一个“彩蛋”吧，反而觉得有点有趣了！
