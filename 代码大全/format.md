```go
package format

//
func main() {
	PrintAlign(fmt.Sprintf("tcp.port = %v", 8000), "tcp port")
	PrintAlign(fmt.Sprintf("udp.port = %v", 8000), "tcp port")
}

// PrintAlign 打印输出conf、comment的时候，对输出内容进行对齐处理，生成配置文件时对配置
// 项进行说明时非常有用，使得配置项及其说明整齐、干净！
func PrintAlign(conf, comment string) {
	fmt.Printf("%-60s%s\n", conf, fmt.Sprintf("#%s", comment))
}
```
